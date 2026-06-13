import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../config"
import "../../services"

Item {
    id: root

    // Services
    property var wallhavenService: Wallhaven {}
    property var waifuimService: Waifuim {}
    property var danbooruService: Danbooru {}
    property var gelbooruService: Gelbooru {}
    property var konachanService: Konachan {}
    property var yandereService: Yandere {}
    property var safebooruService: Safebooru {}

    // State
    property bool isVisible: true
    property string activeTab: "wallhaven"
    property var currentSource: null
    property string searchQuery: ""
    property bool isLoading: false
    property bool isRateLimited: false
    property string rateLimitMessage: ""

    // Source list
    readonly property var sources: [
        { id: "wallhaven", name: "Wallhaven", icon: "W" },
        { id: "waifuim", name: "Waifu.im", icon: "M" },
        { id: "danbooru", name: "Danbooru", icon: "D" },
        { id: "gelbooru", name: "Gelbooru", icon: "G" },
        { id: "konachan", name: "Konachan", icon: "K" },
        { id: "yandere", name: "Yande.re", icon: "Y" },
        { id: "safebooru", name: "Safebooru", icon: "S" }
    ]
    readonly property var enabledSources: {
        var result = []
        for (var i = 0; i < sources.length; i++) {
            var cfg = Config.getSourceConfig(sources[i].id)
            if (cfg && cfg.enabled !== false) {
                result.push(sources[i])
            }
        }
        if (result.length === 0) result = sources
        return result
    }

    // Signals
    signal wallpaperSelected(string url)
    signal searchRequested(string sourceId, string query, bool nsfw)
    signal randomRequested(string sourceId, bool nsfw)
    signal responseUpdated()

    // Background
    Rectangle {
        anchors.fill: parent
        color: "#1a1a2e"
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        // Title
        Text {
            Layout.fillWidth: true
            text: "Sources"
            color: "#e94560"
            font.pixelSize: 16
            font.bold: true
            leftPadding: 8
            bottomPadding: 4
        }

        // Source list buttons
        ListView {
            id: sourceList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 2
            model: enabledSources
            clip: true

            delegate: Rectangle {
                width: sourceList.width
                height: 36
                radius: 6
                color: activeTab === modelData.id ? "#e94560" : "#0f3460"
                opacity: activeTab === modelData.id ? 1.0 : 0.7

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    Text {
                        text: modelData.icon
                        color: "#ffffff"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Text {
                        Layout.fillWidth: true
                        text: modelData.name
                        color: "#ffffff"
                        font.pixelSize: 13
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        activeTab = modelData.id
                        currentSource = modelData.id
                        getSourceService(modelData.id).clearResponses()
                        root.responseUpdated()
                    }
                }
            }
        }

        // Quick action buttons
        Button {
            Layout.fillWidth: true
            text: "Search Current"
            palette.button: "#0f3460"
            palette.buttonText: "#e0e0e0"
            onClicked: performSearch()
        }

        Button {
            Layout.fillWidth: true
            text: "Random"
            palette.button: "#e94560"
            palette.buttonText: "#ffffff"
            onClicked: performRandom()
        }
    }

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

    function getSourceName(sourceId) {
        for (var i = 0; i < sources.length; i++) {
            if (sources[i].id === sourceId) return sources[i].name
        }
        return sourceId
    }

    function getSourceIcon(sourceId) {
        for (var i = 0; i < sources.length; i++) {
            if (sources[i].id === sourceId) return sources[i].icon
        }
        return "?"
    }

    function getSourceConfig(sourceId) {
        return Config.getSourceConfig(sourceId) || ({})
    }

    function performSearch() {
        if (!currentSource) return
        isLoading = true
        responseUpdated() // clear grid immediately
        var service = getSourceService(currentSource)
        if (service) {
            service.clearResponses()
            service.search(
                searchQuery.length > 0 ? searchQuery.split(" ") : [],
                getSourceConfig(currentSource).allowNsfw || false
            )
        }
    }

    function performRandom() {
        if (!currentSource) return
        isLoading = true
        responseUpdated() // clear grid immediately
        var service = getSourceService(currentSource)
        if (service) {
            service.clearResponses()
            service.search([], getSourceConfig(currentSource).allowNsfw || false)
        }
    }

    function updateSourceConfig(sourceId, updates) {
        Config.updateSourceConfig(sourceId, updates)
    }

    // Connect service response signals to update grid
    Connections { target: wallhavenService; function onResponseFinished() { root.responseUpdated(); root.isLoading = false; } }
    Connections { target: waifuimService; function onResponseFinished() { root.responseUpdated(); root.isLoading = false; } }
    Connections { target: danbooruService; function onResponseFinished() { root.responseUpdated(); root.isLoading = false; } }
    Connections { target: gelbooruService; function onResponseFinished() { root.responseUpdated(); root.isLoading = false; } }
    Connections { target: konachanService; function onResponseFinished() { root.responseUpdated(); root.isLoading = false; } }
    Connections { target: yandereService; function onResponseFinished() { root.responseUpdated(); root.isLoading = false; } }
    Connections { target: safebooruService; function onResponseFinished() { root.responseUpdated(); root.isLoading = false; } }

    Component.onCompleted: {
        currentSource = sources[0].id
        activeTab = sources[0].id
    }
}
