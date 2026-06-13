//@ pragma Env QS_NO_RELOAD_POPUP=1

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell

import "config"
import "modules/sidebarLeft"

ShellRoot {
    id: root

    Window {
        id: mainWindow
        width: 900
        height: 640
        minimumWidth: 640
        minimumHeight: 400
        title: "Online Wallpapers"
        visible: true
        flags: Qt.FramelessWindowHint | Qt.Window
        color: "#0d1117"

        // Title bar drag region
        MouseArea {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 32
            property variant previousPosition: Qt.point(0, 0)
            onPressed: { previousPosition = Qt.point(mouseX, mouseY) }
            onPositionChanged: {
                mainWindow.x += mouseX - previousPosition.x
                mainWindow.y += mouseY - previousPosition.y
            }
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ── Sidebar ──
            Sidebar {
                id: sidebar
                Layout.preferredWidth: Config.getUIConfig().sidebarWidth || 260
                Layout.fillHeight: true

                onResponseUpdated: {
                    wallpaperModel.clear()
                    var service = getCurrentService()
                    if (!service) return
                    var items = service.responses || []
                    for (var i = 0; i < items.length; i++) {
                        var item = items[i]
                        wallpaperModel.append({
                            imageUrl: item.file_url || item.path || item.large_file_url || item.sample || item.url || "",
                            thumbnailUrl: item.preview_url || item.thumbnail || (item.thumbs ? item.thumbs.small : "") || item.file_url || "",
                            pageUrl: item.url || "",
                            id: item.id || "",
                            rating: item.rating || item.purity || "",
                            tags: extractTags(item),
                            source: sidebar.activeTab
                        })
                    }
                }
            }

            // ── Main content ──
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#161b22"
                radius: 12

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    // ── Top bar: search + actions ──
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        color: "#21262d"
                        radius: 10

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 8
                            spacing: 8

                            Rectangle {
                                width: 28
                                height: 28
                                radius: 6
                                color: "#30363d"

                                Text {
                                    anchors.centerIn: parent
                                    text: "🔍"
                                    font.pixelSize: 14
                                }
                            }

                            TextField {
                                id: searchField
                                Layout.fillWidth: true
                                placeholderText: "Search wallpapers..."
                                color: "#e6edf3"
                                font.pixelSize: 13
                                font.family: "JetBrains Mono, monospace"
                                background: Item {}
                                leftPadding: 4

                                onAccepted: {
                                    sidebar.searchQuery = text
                                    sidebar.performSearch()
                                }
                            }

                            Button {
                                text: "Random"
                                implicitWidth: 90
                                implicitHeight: 32
                                palette.button: "#1f6feb"
                                palette.buttonText: "#ffffff"
                                font.pixelSize: 12
                                font.bold: true

                                contentItem: Text {
                                    text: parent.text
                                    color: parent.palette.buttonText
                                    font: parent.font
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                background: Rectangle {
                                    radius: 8
                                    color: parent.pressed ? "#388bfd" : "#1f6feb"
                                }

                                onClicked: sidebar.performRandom()
                            }
                        }
                    }

                    // ── Thumbnail grid ──
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        GridView {
                            id: resultsGrid
                            anchors.fill: parent
                            cellWidth: 200
                            cellHeight: 180
                            model: wallpaperModel
                            delegate: wallpaperDelegate
                            boundsBehavior: Flickable.StopAtBounds
                            flickableDirection: Flickable.VerticalFlick

                            // Empty state
                            Text {
                                anchors.centerIn: parent
                                text: "Select a source and search for wallpapers"
                                color: "#484f58"
                                font.pixelSize: 14
                                font.family: "JetBrains Mono, monospace"
                                visible: wallpaperModel.count === 0 && !sidebar.isLoading
                            }
                        }
                    }

                    // ── Status bar ──
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: "#21262d"
                        radius: 8

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: sidebar.isLoading ? "#d29922" :
                                       sidebar.isRateLimited ? "#f85149" : "#3fb950"
                            }

                            Text {
                                Layout.fillWidth: true
                                text: sidebar.isLoading ? "Loading wallpapers..." :
                                      sidebar.isRateLimited ? "Rate limited: " + sidebar.rateLimitMessage :
                                      wallpaperModel.count + " wallpapers loaded"
                                color: sidebar.isRateLimited ? "#f85149" : "#8b949e"
                                font.pixelSize: 11
                                font.family: "JetBrains Mono, monospace"
                                elide: Text.ElideRight
                            }

                            Text {
                                text: "×"
                                color: "#484f58"
                                font.pixelSize: 16
                                visible: wallpaperModel.count > 0

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        wallpaperModel.clear()
                                        var svc = getCurrentService()
                                        if (svc) svc.clearResponses()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Reactive model for thumbnails ──
    ListModel {
        id: wallpaperModel
    }

    // ── Grid delegate ──
    Component {
        id: wallpaperDelegate

        Rectangle {
            width: resultsGrid.cellWidth - 8
            height: resultsGrid.cellHeight - 8
            color: "#21262d"
            radius: 10

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 4

                // Image thumbnail area
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    radius: 8

                    // Thumbnail image
                    Image {
                        id: thumbImage
                        anchors.fill: parent
                        anchors.margins: 2
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        source: model.imageUrl
                        visible: status === Image.Ready
                    }

                    // Loading spinner
                    BusyIndicator {
                        anchors.centerIn: parent
                        running: thumbImage.status === Image.Loading
                        visible: thumbImage.status === Image.Loading
                        width: 24
                        height: 24
                    }

                    // Error / no-image fallback
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: 6
                        color: "#0d1117"
                        visible: thumbImage.status === Image.Error || thumbImage.status === Image.Null

                        Text {
                            anchors.centerIn: parent
                            text: "🎨"
                            font.pixelSize: 28
                            opacity: 0.5
                        }
                    }

                    // Hover overlay
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 2
                        radius: 6
                        color: "#000000"
                        opacity: mouseArea.containsMouse ? 0.3 : 0
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    // Download/Apply action overlay
                    Rectangle {
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 6
                        width: 28
                        height: 28
                        radius: 14
                        color: "#238636"
                        opacity: mouseArea.containsMouse ? 1.0 : 0.0
                        Behavior on opacity { NumberAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "↵"
                            color: "#ffffff"
                            font.pixelSize: 14
                            font.bold: true
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onClicked: {
                            var url = model.file_url || model.path || model.imageUrl || model.large || ""
                            if (url) {
                                sidebar.wallpaperSelected(url)
                            }
                        }
                    }
                }

                // Tags line
                Text {
                    Layout.fillWidth: true
                    Layout.leftMargin: 4
                    Layout.rightMargin: 4
                    text: {
                        var tags = model.tags
                        if (Array.isArray(tags)) return tags.slice(0, 4).join(", ")
                        if (typeof tags === "string") return tags.substring(0, 40)
                        return model.id || ""
                    }
                    color: "#8b949e"
                    font.pixelSize: 10
                    font.family: "JetBrains Mono, monospace"
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                // Rating badge
                Text {
                    Layout.leftMargin: 4
                    text: {
                        var r = model.rating || ""
                        if (r === "safe" || r === "general" || r === "s") return "🟢 Safe"
                        if (r === "questionable" || r === "q") return "🟡 Sketchy"
                        if (r === "explicit" || r === "e") return "🔴 NSFW"
                        return r
                    }
                    color: "#484f58"
                    font.pixelSize: 9
                    font.family: "JetBrains Mono, monospace"
                    visible: text.length > 0
                }
            }
        }
    }

    // ── Helper functions ──

    function getCurrentService() {
        var active = sidebar.activeTab
        if (active === "wallhaven") return sidebar.wallhavenService
        if (active === "waifuim") return sidebar.waifuimService
        if (active === "danbooru") return sidebar.danbooruService
        if (active === "gelbooru") return sidebar.gelbooruService
        if (active === "konachan") return sidebar.konachanService
        if (active === "yandere") return sidebar.yandereService
        if (active === "safebooru") return sidebar.safebooruService
        return null
    }

    // Normalize tags from various API formats
    function extractTags(item) {
        if (!item) return ""
        if (Array.isArray(item.tags)) {
            if (item.tags.length === 0) return ""
            // Check if tags are strings or objects with name
            if (typeof item.tags[0] === "string") return item.tags.slice(0, 6).join(", ")
            if (item.tags[0].name) return item.tags.slice(0, 6).map(function(t) { return t.name }).join(", ")
            return item.tags.join(", ")
        }
        if (typeof item.tags === "string") return item.tags
        if (item.tag_string) return item.tag_string
        if (item.tag_string_cn) return item.tag_string_cn
        if (item.tag_string_artists) return item.tag_string_artists
        return item.id || ""
    }
}
