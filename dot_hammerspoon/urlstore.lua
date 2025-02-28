local config = require("config")
local hyper = config.hyper

local pasteboard = require("hs.pasteboard")
local http = require("hs.http")
local json = require("hs.json")
local notify = require("hs.notify")

local log = hs.logger.new('urlstore', config.debug.urlstore and 'debug' or 'info')

-- Improved URL validation
local function isURL(str)
    if type(str) ~= "string" then return false end

    -- More comprehensive URL pattern matching
    local pattern = "^https?://[%w-_%.%?%.:/%+=&%%]+$"
    return str:match(pattern) ~= nil
end

-- Show notification with result
local function showNotification(title, message, withdrawAfter)
    notify.new({
        title = title,
        informativeText = message,
        withdrawAfter = withdrawAfter or 3
    }):send()
end

function PostURLtoWebService()
    local currentPBoardURL = pasteboard.getContents() -- get the URL from the pasteboard

    log.d("URL on clipboard", currentPBoardURL)

    if not currentPBoardURL then
        showNotification("URL Error", "No content in clipboard")
        return
    end

    if isURL(currentPBoardURL) then
        local postDataURL = config.urlService.endpoint
        local headers = { ["Content-Type"] = "application/json" }
        local postData = json.encode({ link = currentPBoardURL }) -- Encode data as JSON

        showNotification("URL Download", "Sending URL to download service...", 2)

        http.asyncPost(postDataURL, postData, headers,
            function(status, body, headers)
                if status == 200 then
                    log.i("Successfully posted URL to web service")
                    log.d("Status: ", status)
                    log.d("Headers: ", hs.inspect(headers))
                    log.d("Body: ", body)

                    -- Parse response if it's JSON
                    local success, response = pcall(function() return json.decode(body) end)
                    local message = success and response.message or "URL sent successfully"

                    showNotification("URL Download", message)
                else
                    log.e("Failed to post URL to service")
                    log.e("Status: ", status)
                    log.d("Headers: ", hs.inspect(headers))
                    log.d("Body: ", body)

                    showNotification("URL Download Failed",
                        "Error: " .. (status and tostring(status) or "Connection failed"),
                        5)
                end
            end)
    else
        showNotification("URL Error", "Invalid URL in clipboard", 3)
        log.w("Invalid URL in clipboard: " .. (currentPBoardURL or "nil"))
    end
end

-- Add a function to download multiple URLs from clipboard
function PostMultipleURLsToWebService()
    local clipboardContent = pasteboard.getContents()
    if not clipboardContent then
        showNotification("URL Error", "No content in clipboard")
        return
    end

    -- Split by newlines and process each line
    local urls = {}
    for line in clipboardContent:gmatch("[^\r\n]+") do
        if isURL(line) then
            table.insert(urls, line)
        end
    end

    if #urls == 0 then
        showNotification("URL Error", "No valid URLs found in clipboard")
        return
    end

    showNotification("URL Download", "Sending " .. #urls .. " URLs to download service...", 2)

    -- Process each URL
    local successCount = 0
    for _, url in ipairs(urls) do
        local postDataURL = config.urlService.endpoint
        local headers = { ["Content-Type"] = "application/json" }
        local postData = json.encode({ link = url })

        http.asyncPost(postDataURL, postData, headers,
            function(status, body, headers)
                if status == 200 then
                    successCount = successCount + 1
                    log.i("Successfully posted URL to web service: " .. url)
                else
                    log.e("Failed to post URL: " .. url)
                end

                -- Show final notification after all requests complete
                if successCount == #urls then
                    showNotification("URL Download Complete", "Successfully sent " .. successCount .. " URLs")
                end
            end)
    end
end

-- Register hotkey for multiple URL download
hs.hotkey.bind(hyper, "u", PostMultipleURLsToWebService)

return {
    PostURLtoWebService = PostURLtoWebService,
    PostMultipleURLsToWebService = PostMultipleURLsToWebService
}
