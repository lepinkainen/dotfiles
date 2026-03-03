import Foundation
import CoreLocation

final class Delegate: NSObject, CLLocationManagerDelegate {
    let m = CLLocationManager()

    override init() {
        super.init()
        m.delegate = self
        m.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func start() {
        let status = m.authorizationStatus

        if status == .notDetermined {
            m.requestLocation()
        } else {
            handleAuth(status)
        }
    }

    private func handleAuth(_ status: CLAuthorizationStatus) {
        if status == .authorized {
            m.requestLocation()
        } else if status == .denied || status == .restricted {
            jsonError("Location permission denied or restricted")
            exit(2)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuth(manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else {
            jsonError("No location available")
            exit(1)
        }

        let json: [String: Any] = [
            "lat": loc.coordinate.latitude,
            "lon": loc.coordinate.longitude,
            "accuracy_m": loc.horizontalAccuracy
        ]

        output(json)
        exit(0)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        jsonError(error.localizedDescription)
        exit(1)
    }

    private func jsonError(_ message: String) {
        output(["error": message])
    }

    private func output(_ obj: [String: Any]) {
        if let data = try? JSONSerialization.data(withJSONObject: obj),
           let str = String(data: data, encoding: .utf8) {
            print(str)
        } else {
            print("{\"error\":\"Failed to encode JSON\"}")
        }
    }
}

let d = Delegate()
d.start()
RunLoop.main.run()

