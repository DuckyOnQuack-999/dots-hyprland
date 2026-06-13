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

    // Waifu.im configuration
    readonly property var sourceConfig: Config.getSourceConfig("waifuim")
    readonly property bool allowNsfw: sourceConfig.allowNsfw || false
    readonly property var defaultTags: sourceConfig.defaultTags || ["waifu"]
    readonly property var excludedTags: sourceConfig.excludedTags || []
    readonly property int limit: sourceConfig.limit || 30
    readonly property string orientation: sourceConfig.orientation || "landscape"
    readonly property string orderBy: sourceConfig.orderBy || "random"

    // Rate limiting
    readonly property int minSearchIntervalMs: 1200
    readonly property int minTagIntervalMs: 1200
    property var pendingSearch: null
    property var pendingTag: null
    property string lastSearchTime: ""
    property string lastTagTime: ""

    // Waifu.im API endpoints
    readonly property string baseUrl: "https://api.waifu.im"

    // Build search URL
    function buildSearchUrl(tags, nsfw, page) {
        var params = []

        // Add included tags
        var includedTags = []
        if (defaultTags && defaultTags.length > 0) {
            includedTags = includedTags.concat(defaultTags)
        }
        if (tags && tags.length > 0) {
            includedTags = includedTags.concat(tags)
        }

        if (includedTags.length > 0) {
            params.push("IncludedTags=" + encodeURIComponent(includedTags.join(",")))
        }

        // Add excluded tags
        if (excludedTags.length > 0) {
            params.push("ExcludedTags=" + encodeURIComponent(excludedTags.join(",")))
        }

        // Add NSFW setting
        var isNsfw = nsfw || allowNsfw
        params.push("is_nsfw=" + (isNsfw ? "null" : "false"))

        // Add orientation
        params.push("orientation=" + orientation)

        // Add order by
        params.push("order_by=" + orderBy)

        // Add page
        if (page > 1) {
            params.push("page=" + page)
        }

        // Add page size
        params.push("page_size=" + Math.min(limit, 30))

        return baseUrl + "/images?" + params.join("&")
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
                if (response && response.items && response.items.length > 0) {
                    responses = [...responses, ...response.items]
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
        var url = baseUrl + "/images/" + wallpaperId

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