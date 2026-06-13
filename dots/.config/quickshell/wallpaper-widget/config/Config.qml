pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel

Singleton {
    id: root

    // Configuration file path
    property string configPath: "~/.config/quickshell/wallpaper-widget/config.json"

    // Default configuration
    readonly property var defaultConfig: ({
        sources: {
            wallhaven: {
                enabled: true,
                apiKey: "",
                allowNsfw: false,
                defaultTags: "",
                sorting: "toplist",
                topRange: "1M",
                limit: 24
            },
            waifuim: {
                enabled: true,
                allowNsfw: false,
                defaultTags: ["waifu"],
                excludedTags: [],
                limit: 30,
                orientation: "landscape",
                orderBy: "random"
            },
            danbooru: {
                enabled: true,
                apiKey: "",
                username: "",
                allowNsfw: false,
                defaultTags: "",
                limit: 20
            },
            gelbooru: {
                enabled: true,
                apiKey: "",
                userId: "",
                allowNsfw: false,
                defaultTags: "",
                limit: 20
            },
            konachan: {
                enabled: true,
                apiKey: "",
                username: "",
                allowNsfw: false,
                defaultTags: "",
                limit: 20,
                useSafe: false
            },
            yandere: {
                enabled: true,
                apiKey: "",
                username: "",
                allowNsfw: false,
                defaultTags: "",
                limit: 20
            },
            safebooru: {
                enabled: true,
                apiKey: "",
                userId: "",
                allowNsfw: false,
                defaultTags: "rating:general",
                limit: 20
            }
        },
        ui: {
            sidebarWidth: 280,
            thumbnailSize: 200,
            gridSpacing: 8,
            enableBlur: true,
            blurRadius: 20,
            dimOverlay: 0.3
        },
        download: {
            path: "~/Pictures/Wallpapers/Downloaded/",
            setAsWallpaper: false,
            wallpaperCommand: "swww img %1 -t grow --transition-duration 1"
        }
    })

    // Runtime configuration (loaded from file)
    property var config: ({})

    // Get source configuration
    function getSourceConfig(sourceId) {
        if (!config.sources || !config.sources[sourceId]) return ({})
        return config.sources[sourceId]
    }

    // Update source configuration
    function updateSourceConfig(sourceId, updates) {
        if (!config.sources) config.sources = {}
        if (!config.sources[sourceId]) config.sources[sourceId] = {}
        for (var key in updates) {
            config.sources[sourceId][key] = updates[key]
        }
        saveConfig()
    }

    // Get UI configuration
    function getUIConfig() {
        return config.ui || defaultConfig.ui
    }

    // Get download configuration
    function getDownloadConfig() {
        return config.download || defaultConfig.download
    }

    // Resolve config path (expand ~)
    property string resolvedConfigPath: {
        var p = "~/.config/quickshell/wallpaper-widget/config.json"
        if (p.charAt(0) === "~") {
            var home = Quickshell.env("HOME") || "/home/duckyonquack999"
            p = home + p.substring(1)
        }
        return p
    }

    signal configReady()

    // Load configuration from file
    function loadConfig() {
        loadProc.running = true
    }

    // Save configuration to file
    function saveConfig() {
        var json = JSON.stringify(config, null, 2)
        saveProc.stdinEnabled = true
        saveProc.running = true
        // Will be written in onRunningChanged
        saveProc.pendingData = json
    }

    property string pendingData: ""

    Process {
        id: loadProc
        command: ["cat", resolvedConfigPath]
        stdout: StdioCollector {
            id: loadCollector
            onStreamFinished: {
                var text = loadCollector.text
                if (text.length > 0) {
                    try {
                        var parsed = JSON.parse(text)
                        config = mergeDeep(defaultConfig, parsed)
                        configReady()
                        return
                    } catch (e) {
                        console.warn("Config parse error:", e)
                    }
                }
                config = JSON.parse(JSON.stringify(defaultConfig))
                saveConfig()
                configReady()
            }
        }
        onExited: (code, status) => {
            if (code !== 0) {
                config = JSON.parse(JSON.stringify(defaultConfig))
                saveConfig()
                configReady()
            }
        }
    }

    Process {
        id: saveProc
        command: ["sh", "-c", "cat > " + resolvedConfigPath]
        property string pendingData: ""
        onRunningChanged: {
            if (running && pendingData.length > 0) {
                saveProc.write(pendingData)
                pendingData = ""
                stdinEnabled = false
            }
        }
    }

    // Deep merge two objects
    function mergeDeep(target, source) {
        var result = JSON.parse(JSON.stringify(target))
        for (var key in source) {
            if (source[key] && typeof source[key] === 'object' && !Array.isArray(source[key])) {
                result[key] = mergeDeep(target[key] || {}, source[key])
            } else {
                result[key] = source[key]
            }
        }
        return result
    }

    Component.onCompleted: {
        loadConfig()
    }
}
