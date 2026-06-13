import QtQuick
import Quickshell
import Quickshell.Io
import "../config"

QtObject {
    id: root

    // Configuration

    // Signals
    signal responseFinished()
    signal error(string message)

    // State
    property var responses: []
    property int runningRequests: 0
    property bool isRateLimited: false
    property string rateLimitUntil: ""

    // Booru configuration
    readonly property var sourceConfig: Config.getSourceConfig(root.sourceId)
    readonly property string apiKey: sourceConfig.apiKey || ""
    readonly property string username: sourceConfig.username || ""
    readonly property string userId: sourceConfig.userId || ""
    readonly property bool allowNsfw: sourceConfig.allowNsfw || false
    readonly property string defaultTags: sourceConfig.defaultTags || ""
    readonly property int limit: sourceConfig.limit || 20

    // Rate limiting
    readonly property int minSearchIntervalMs: 1200
    readonly property int minTagIntervalMs: 1200
    property var pendingSearch: null
    property var pendingTag: null
    property string lastSearchTime: ""
    property string lastTagTime: ""

    // Booru API endpoints
    readonly property string baseUrl: ""
    readonly property string apiEndpoint: ""
    readonly property string sourceId: ""

    // Build search URL
    function buildSearchUrl(tags, nsfw, page) {
        var params = []

        // Add tags
        var allTags = []
        if (defaultTags && defaultTags.length > 0) {
            allTags = allTags.concat(defaultTags.split(" "))
        }
        if (tags && tags.length > 0) {
            allTags = allTags.concat(tags)
        }

        if (allTags.length > 0) {
            params.push("tags=" + encodeURIComponent(allTags.join(" ")))
        }

        // Add NSFW filtering
        if (!allowNsfw && !nsfw) {
            // Add SFW-only tags based on booru type
            if (sourceId === "danbooru" || sourceId === "safebooru") {
                params.push("rating=general")
            } else if (sourceId === "gelbooru") {
                params.push("rating=general")
            } else if (sourceId === "konachan") {
                params.push("rating:s=general")
            } else if (sourceId === "yandere") {
                params.push("rating:general")
            }
        } else if (nsfw && apiKey && apiKey.length > 0) {
            // NSFW with API key
            if (sourceId === "danbooru") {
                params.push("rating:general")
            } else if (sourceId === "gelbooru") {
                params.push("rating:general")
            } else if (sourceId === "konachan") {
                params.push("rating:s=general")
            } else if (sourceId === "yandere") {
                params.push("rating:general")
            }
        }

        // Add API key if available
        if (apiKey && apiKey.length > 0) {
            if (sourceId === "danbooru") {
                params.push("api_key=" + encodeURIComponent(apiKey))
            } else if (sourceId === "gelbooru") {
                params.push("api_key=" + encodeURIComponent(apiKey))
                params.push("user_id=" + encodeURIComponent(userId || ""))
            } else if (sourceId === "konachan") {
                params.push("api_key=" + encodeURIComponent(apiKey))
            } else if (sourceId === "yandere") {
                params.push("api_key=" + encodeURIComponent(apiKey))
            } else if (sourceId === "safebooru") {
                params.push("api_key=" + encodeURIComponent(apiKey))
            }
        }

        // Add username if available
        if (username && username.length > 0) {
            if (sourceId === "konachan") {
                params.push("username=" + encodeURIComponent(username))
            } else if (sourceId === "yandere") {
                params.push("username=" + encodeURIComponent(username))
            }
        }

        // Add limit
        params.push("limit=" + limit)

        // Add page
        if (page > 1) {
            params.push("page=" + page)
        }

        return apiEndpoint + "?" + params.join("&")
    }

    // Make search request
    function makeRequest(tags, nsfw, limit, page) {
        // Check rate limiting
        var now = Date.now()
        var lastTime = lastSearchTime ? new Date(lastSearchTime).getTime() : 0
        if (now - lastTime < minSearchIntervalMs && runningRequests > 0) {
            // Queue the request
            pendingSearch = { tags, nsfw, limit, page }
            return
        }

        lastSearchTime = new Date().toISOString()
        runningRequests++

        var url = buildSearchUrl(tags, nsfw, page)

        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.responseType = "json"

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) {
                return
            }

            runningRequests = Math.max(0, runningRequests - 1)

            if (xhr.status >= 200 && xhr.status < 300) {
                var response = xhr.response
                if (response && response.length > 0) {
                    responses = [...responses, ...response]
                }
                root.responseFinished()

                // Handle queued requests
                if (pendingSearch && !isRateLimited) {
                    var next = pendingSearch
                    pendingSearch = null
                    Qt.callLater(() => root.makeRequest(next.tags, next.nsfw, next.limit, next.page))
                }
            } else if (xhr.status === 429) {
                // Rate limited
                isRateLimited = true
                rateLimitUntil = new Date(Date.now() + 30000).toISOString() // 30 seconds

                // Retry after rate limit
                Qt.callLater(() => {
                    if (pendingSearch) {
                        var next = pendingSearch
                        pendingSearch = null
                        root.makeRequest(next.tags, next.nsfw, next.limit, next.page)
                    }
                })

                root.error("Rate limited. Waiting 30 seconds...")
            } else {
                root.error("Request failed with status " + xhr.status)
            }
        }

        xhr.send()
    }

    // Ensure wallpaper tags (for hover tooltips)
    function ensureWallpaperTags(wallpaperId) {
        // Check if tags already exist
        for (var i = 0; i < responses.length; i++) {
            if (responses[i].id === wallpaperId && responses[i].tags && responses[i].tags.length > 0) {
                return
            }
        }

        // Fetch tags for this wallpaper
        var url = apiEndpoint + "/" + wallpaperId

        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.responseType = "json"

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) {
                return
            }

            if (xhr.status >= 200 && xhr.status < 300) {
                var wallpaper = xhr.response
                if (wallpaper && wallpaper.tags && wallpaper.tags.length > 0) {
                    // Update the response with tags
                    for (var i = 0; i < responses.length; i++) {
                        if (responses[i].id === wallpaperId) {
                            responses[i] = wallpaper
                            break
                        }
                    }
                }
            }
        }

        xhr.send()
    }

    // Public API
    function search(tags, nsfw) {
        if (!tags) tags = []
        makeRequest(tags, nsfw, limit, 1)
    }

    function clearResponses() {
        responses = []
    }

    function getResponses() {
        return responses
    }

    function isPending() {
        return pendingSearch !== null
    }

    function isRateLimitedNow() {
        return isRateLimited && new Date() < new Date(rateLimitUntil)
    }

    // Initialize
    Component.onCompleted: {
        Config.loadConfig()
    }
}