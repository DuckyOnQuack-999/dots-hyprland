import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../config"

QtObject {
    id: root

    // Properties from parent
    property bool isVisible: false
    property string activeTab: "wallhaven"
    property var currentSource: null
    property string searchQuery: ""
    property bool isLoading: false
    property bool isRateLimited: false
    property string rateLimitMessage: ""

    // Sources
    readonly property var sources: [
        { id: "wallhaven", name: "Wallhaven", icon: "🌐", enabled: true },
        { id: "waifuim", name: "Waifu.im", icon: "🎌", enabled: true },
        { id: "danbooru", name: "Danbooru", icon: "🐉", enabled: true },
        { id: "gelbooru", name: "Gelbooru", icon: "🐸", enabled: true },
        { id: "konachan", name: "Konachan", icon: "🐰", enabled: true },
        { id: "yandere", name: "Yande.re", icon: "💗", enabled: true },
        { id: "safebooru", name: "Safebooru", icon: "🛡️", enabled: true }
    ]

    // Signals
    signal wallpaperSelected(string url)
    signal searchRequested(string sourceId, string query, bool nsfw)
    signal randomRequested(string sourceId, bool nsfw)

    // Services (will be injected)
    property var wallhavenService: Wallhaven {}
    property var waifuimService: Waifuim {}
    property var danbooruService: Danbooru {}
    property var gelbooruService: Gelbooru {}
    property var konachanService: Konachan {}
    property var yandereService: Yandere {}
    property var safebooruService: Safebooru {}

    // Helper functions
    function getSourceService(sourceId) {
        switch (sourceId) {
            case "wallhaven": return wallhavenService
            case "waifuim": return waifuimService
            case "danbooru": return danbooruService
            case "gelbooru": return gelbooruService
            case "konachan": return konachanService
            case "yandere": return yandereService
            case "safebooru": return safebooruService
            default: return null
        }
    }

    function getSourceConfig(sourceId) {
        return Config.getSourceConfig(sourceId) || {}
    }

    function getSourceName(sourceId) {
        for (var i = 0; i < sources.length; i++) {
            if (sources[i].id === sourceId) {
                return sources[i].name
            }
        }
        return sourceId
    }

    function getSourceIcon(sourceId) {
        for (var i = 0; i < sources.length; i++) {
            if (sources[i].id === sourceId) {
                return sources[i].icon
            }
        }
        return "📷"
    }

    // Search function
    function performSearch() {
        if (!currentSource) return

        isLoading = true
        var service = getSourceService(currentSource)
        if (service) {
            service.clearResponses()
            service.search(searchQuery.split(" "), getSourceConfig(currentSource).allowNsfw || false)
        }
    }

    // Random function
    function performRandom() {
        if (!currentSource) return

        isLoading = true
        var service = getSourceService(currentSource)
        if (service) {
            service.clearResponses()
            service.search([], getSourceConfig(currentSource).allowNsfw || false)
        }
    }

    // Update source configuration
    function updateSourceConfig(sourceId, updates) {
        Config.updateSourceConfig(sourceId, updates)
    }

    // Initialize
    Component.onCompleted: {
        Config.loadConfig()
        currentSource = sources[0].id
    }
}