# Quickshell Wallpaper Widget

A comprehensive wallpaper manager for Quickshell with multiple sources, NSFW support, and a modern sidebar interface.

## Features

### 🎨 Multiple Wallpaper Sources
- **Wallhaven** - Curated wallpapers with API key support for NSFW content
- **Waifu.im** - Anime wallpapers with tag filtering and orientation options
- **Danbooru** - Large anime imageboard with SFW/NSFW support
- **Gelbooru** - Hentai imageboard with API key authentication
- **Konachan** - Anime wallpapers with safe mode options
- **Yande.re** - Anime imageboard with premium features
- **Safebooru** - SFW-only Gelbooru variant

### 🖼️ Rich Features
- **Tag Search** - Search wallpapers by tags across all sources
- **NSFW Toggle** - Per-source NSFW content control with API key requirements
- **Random Wallpapers** - Get random wallpapers from any source
- **Image Preview** - Hover to preview images with tag information
- **Lazy Loading** - Efficient loading of large image sets
- **Rate Limiting** - Built-in rate limiting to respect API limits
- **Configuration** - Persistent settings for API keys and preferences
- **Responsive UI** - Modern, clean interface with smooth animations

### 🎛️ Configuration
- **API Keys** - Store API keys securely for NSFW content
- **Default Tags** - Set default search tags for each source
- **Limits** - Configure result limits per source
- **UI Settings** - Customize sidebar width, thumbnail size, and visual effects
- **Download Options** - Configure wallpaper download and application

## Installation

### Prerequisites
- Quickshell installed
- Hyprland or other Wayland compositor
- swww or hyprpaper for wallpaper application (recommended)

### Setup

1. Clone this repository into your Quickshell config directory:
   ```bash
   git clone https://github.com/yourusername/wallpaper-widget ~/.config/quickshell/wallpaper-widget
   ```

2. Add the wallpaper widget to your shell configuration:
   ```qml
   import "wallpaper-widget"

   WallpaperWidget {}
   ```

3. Bind a key in your Hyprland config:
   ```hypr
   bind = $mainMod, W, exec, quickshell -c wallpaper-widget
   ```

## Configuration

The widget uses a configuration file at `~/.config/quickshell/wallpaper-widget/config.json`. You can edit this file directly or use the configuration UI in the sidebar.

### Example Configuration
```json
{
    "sources": {
        "wallhaven": {
            "enabled": true,
            "apiKey": "your-wallhaven-api-key",
            "allowNsfw": false,
            "defaultTags": "nature,landscape",
            "sorting": "toplist",
            "topRange": "1M",
            "limit": 24
        },
        "waifuim": {
            "enabled": true,
            "allowNsfw": false,
            "defaultTags": ["waifu", "maid"],
            "excludedTags": [],
            "limit": 30,
            "orientation": "landscape",
            "orderBy": "random"
        }
    },
    "ui": {
        "sidebarWidth": 380,
        "thumbnailSize": 280,
        "gridSpacing": 8,
        "enableBlur": true,
        "blurRadius": 20,
        "dimOverlay": 0.3
    },
    "download": {
        "path": "~/Pictures/Wallpapers/Downloaded/",
        "setAsWallpaper": false,
        "wallpaperCommand": "swww img %1 -t grow --transition-duration 1"
    }
}
```

## Usage

### Basic Operations

1. **Open the Wallpaper Widget**: Press your configured key (default: Super + W)

2. **Switch Sources**: Click on any source in the sidebar to switch between Wallhaven, Waifu.im, Danbooru, etc.

3. **Search Wallpapers**: Type your search query in the search bar and press Enter

4. **Get Random Wallpapers**: Click the "Random" button to get random wallpapers from the current source

5. **Toggle NSFW**: Enable NSFW content for sources that support it (requires API key)

6. **Preview Images**: Hover over images to preview them with tag information

7. **Apply Wallpapers**: Click on any image to apply it as your desktop wallpaper

### Advanced Features

#### API Key Setup
For sources that support NSFW content, you'll need to provide API keys:

1. **Wallhaven**: Get your API key from [wallhaven.cc/account](https://wallhaven.cc/account)
2. **Danbooru**: Get your API key from [danbooru.donmai.us/wiki/show.php?wiki=API+keys](https://danbooru.donmai.us/wiki/show.php?wiki=API+keys)
3. **Gelbooru**: Get your API key from [gelbooru.com/wiki/Help:API](https://gelbooru.com/wiki/Help:API)
4. **Konachan**: Get your API key from [konachan.com/wiki/Help:API](https://konachan.com/wiki/Help:API)
5. **Yande.re**: Get your API key from [yande.re/wiki/Help:API](https://yande.re/wiki/Help:API)

#### Custom Tags
Set default tags for each source to always include them in searches:
- Wallhaven: Comma-separated tags (e.g., "nature,landscape,water")
- Waifu.im: Array of tags (e.g., ["waifu", "maid", "school"])

#### Wallpaper Commands
Configure how wallpapers are applied:
- **swww**: Modern wallpaper utility with smooth transitions
- **hyprpaper**: Hyprland's built-in wallpaper utility
- **Custom commands**: Any command that accepts a wallpaper path as an argument

## Development

### Project Structure
```
wallpaper-widget/
├── config/                    # Configuration system
│   └── Config.qml
├── services/                  # API services
│   ├── Wallhaven.qml
│   ├── Waifuim.qml
│   ├── Danbooru.qml
│   ├── Gelbooru.qml
│   ├── Konachan.qml
│   ├── Yandere.qml
│   └── Safebooru.qml
├── modules/                   # UI components
│   ├── sidebarLeft/
│   │   ├── Sidebar.qml
│   │   └── SidebarUI.qml
│   └── components/            # Reusable components
├── assets/                    # Icons and assets
├── shell.qml                 # Main entry point
└── README.md                 # This file
```

### Adding New Sources

To add a new wallpaper source:

1. Create a new service file in `services/` (e.g., `NewSource.qml`)
2. Implement the API integration following the patterns in existing services
3. Add the source to the configuration in `config/Config.qml`
4. Update the sidebar UI to include the new source

### API Integration

Each service follows a similar pattern:
- **Configuration**: Read from the config file
- **Rate Limiting**: Built-in rate limiting to respect API limits
- **Error Handling**: Graceful error handling with user feedback
- **Tag Support**: Support for tags and filtering
- **NSFW Support**: Optional NSFW content with API key requirements

## Troubleshooting

### Common Issues

#### API Key Not Working
- Ensure your API key is correctly entered in the configuration
- Check that the API key is valid and not expired
- Verify that the API key has the required permissions

#### Rate Limiting
- The widget implements rate limiting to respect API limits
- If you hit the rate limit, wait a few minutes before trying again
- You can increase the rate limit interval in the service configuration

#### Images Not Loading
- Check your internet connection
- Verify that the source is enabled in the configuration
- Try refreshing the widget by closing and reopening it

#### Wallpaper Not Applying
- Ensure your wallpaper command is correct
- Check that the wallpaper file exists and is accessible
- Verify that your compositor supports the wallpaper format

### Getting Help

For issues and questions:
1. Check the GitHub issues for known problems
2. Search for existing discussions
3. Create a new issue with detailed information about your problem

## License

This project is licensed under the MIT License. See the LICENSE file for more information.

## Acknowledgements

- **Quickshell**: The shell framework that makes this possible
- **Wallhaven**: For providing a vast collection of wallpapers
- **Waifu.im**: For providing anime wallpapers
- **Danbooru, Gelbooru, Konachan, Yande.re, Safebooru**: For providing anime imageboard content
- **All contributors**: For their contributions and feedback