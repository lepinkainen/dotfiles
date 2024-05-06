local hyper = {"cmd", "alt", "ctrl", "shift"}

local pasteboard = require("hs.pasteboard")
local http = require("hs.http")
local json = require("hs.json")

local log = hs.logger.new('urlstore', 'debug')

local function isURL(str)
    -- Diz no worky, way too complex
    -- local match = "^(https?://[%w-]+.%w+([%.%w-]+)*(:(%d+))*(/%.*)*)$"

    -- Grug brain work
    local match = "^http.*"

    if str:match(match) then
        return true
    else
        return false
    end
end

function PostURLtoWebService()
    local currentPBoardURL = pasteboard.getContents() -- get the URL from the pasteboard

    log.d("URL on clipboard", currentPBoardURL)
    if isURL(currentPBoardURL) then
        local postDataURL = "http://localhost:8080/api/download"

        local headers = {["Content-Type"] = "application/json"}
        local postData = json.encode({link = currentPBoardURL}) -- Encode data as JSON 

        http.asyncPost(postDataURL, postData, headers,
                       function(status, body, headers)
            if status then
                log.i("Successfully posted URL to web service")
                log.d("Status: ", status)
                log.d("Headers: ", hs.inspect(headers))
                log.d("Body: ", body)
            else
                log.e(
                    "Failed to post URL, please check your Internet connection or web service status")
                log.e("Status: ", status)
                log.et("Headers: ", hs.inspect(headers))
                log.et("Body: ", body)
            end
        end)
    else
        print("No URL in clipboard")
    end
end
