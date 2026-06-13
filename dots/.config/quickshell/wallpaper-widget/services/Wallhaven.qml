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

    // Wallhaven configuration
    readonly property var sourceConfig: Config.getSourceConfig("wallhaven")
    readonly property string apiKey: sourceConfig.apiKey || ""
    readonly property bool allowNsfw: sourceConfig.allowNsfw || false
    readonly property string defaultTags: sourceConfig.defaultTags || ""
    readonly property string sortingMode: sourceConfig.sorting || "toplist"
    readonly property string topRange: sourceConfig.topRange || "1M"
    readonly property int limit: sourceConfig.limit || 24

    // Rate limiting
    readonly property int minSearchIntervalMs: 1200
    readonly property int minTagIntervalMs: 1200
    property var pendingSearch: null
    property var pendingTag: null
    property string lastSearchTime: ""
    property string lastTagTime: ""

    // Wallhaven API endpoints
    readonly property string baseUrl: "https://wallhaven.cc/api/v1"

    // Build search URL
    function buildSearchUrl(tags, nsfw, page) {
        var params = []

        // Add tags
        if (tags && tags.length > 0) {
            params.push("q=" + encodeURIComponent(tags.join(" ")))
        }

        // Add default tags
        if (defaultTags && defaultTags.length > 0) {
            if (tags && tags.length > 0) {
                params.push("q=" + encodeURIComponent(defaultTags + " " + tags.join(" ")))
            } else {
                params.push("q=" + encodeURIComponent(defaultTags))
            }
        }

        // Add categories (general, anime, people)
        params.push("categories=111")

        // Add purity (SFW, sketchy, NSFW)
        var purity = "100" // SFW only by default
        if (nsfw && apiKey && apiKey.length > 0) {
            purity = "111" // SFW + sketchy + NSFW
        } else if (nsfw) {
            purity = "110" // SFW + sketchy
        }
        params.push("purity=" + purity)

        // Add sorting
        var sorting = sortingMode
        params.push("sorting=" + sorting)
        params.push("order=desc")
        if (sorting === "toplist" && topRange.length > 0) {
            params.push("topRange=" + topRange)
        }

        // Add API key if available
        if (apiKey && apiKey.length > 0) {
            params.push("apikey=" + encodeURIComponent(apiKey))
        }

        // Add page
        if (page > 1) {
            params.push("page=" + page)
        }

        // Add seed for random
        if (sorting === "random") {
            params.push("seed=" + Math.random().toString(36).substring(2, 15))
        }

        return baseUrl + "/search?" + params.join("&")
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
                if (response && response.data && response.data.length > 0) {
                    responses = [...responses, ...response.data]
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
        var url = baseUrl + "/w/" + wallpaperId
        if (apiKey && apiKey.length > 0) {
            url += "?apikey=" + encodeURIComponent(apiKey)
        }

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