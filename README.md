# gURL

A native macOS GUI for cURL, built with SwiftUI. Every cURL command-line option exposed as an intuitive graphical interface.

![macOS](https://img.shields.io/badge/macOS-14.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.0-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

### Complete cURL Coverage
- **All HTTP methods**: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS, TRACE, CONNECT
- **Request body**: Raw (JSON, XML, Text, HTML), Form Data, URL-encoded, Binary files
- **Authentication**: Basic, Bearer Token, Digest, NTLM, Negotiate, AWS Signature v4
- **Headers**: Custom headers with common presets (Content-Type, Accept, etc.)
- **Cookies**: Manual cookies, cookie files, and cookie jars
- **SSL/TLS**: Certificates, keys, CA bundles, SSL versions, insecure mode
- **Proxy**: HTTP, HTTPS, SOCKS4, SOCKS4a, SOCKS5 with authentication
- **Advanced**: Timeouts, retries, redirects, compression, DNS options, and more

### Modern macOS Experience
- **Multi-tab interface**: Work on multiple requests simultaneously
- **Request history**: Search, filter, and pin important requests
- **Response diff**: Compare two responses side-by-side or unified
- **Live command preview**: See the generated cURL command in real-time
- **Keyboard shortcuts**: Full keyboard navigation support

### Response Handling
- **Syntax highlighting**: JSON auto-formatting and display
- **Headers view**: Parsed response headers
- **Status indicators**: Color-coded HTTP status codes
- **Timing information**: Request duration tracking

## Screenshots

<!-- Add screenshots here -->

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0+ (for building from source)

## Installation

### From Source

1. Clone the repository:
   ```bash
   git clone https://github.com/247arjun/gURL.git
   cd gURL
   ```

2. Open in Xcode:
   ```bash
   open gURL.xcodeproj
   ```

3. Build and run (⌘R) or archive for distribution (Product → Archive)

### Pre-built Binary

Download the latest release from the [Releases](https://github.com/247arjun/gURL/releases) page.

## Usage

### Basic Request
1. Select HTTP method from the dropdown
2. Enter the URL
3. Click "Send" or press ⌘↩

### Adding Headers
1. Navigate to the "Headers" tab
2. Add key-value pairs or use common header presets
3. Toggle headers on/off without deleting them

### Request Body
1. Navigate to the "Body" tab
2. Select body type (Raw, Form Data, URL-encoded, Binary)
3. For raw body, choose content type and enter data
4. JSON is auto-formatted when you click "Format JSON"

### Authentication
1. Navigate to the "Auth" tab
2. Select authentication type
3. Enter credentials as required

### Working with Tabs
- **New Tab**: ⌘T
- **Close Tab**: ⌘W  
- **Duplicate Request**: ⌘D (opens in new tab)

### Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Send Request | ⌘↩ |
| New Tab | ⌘T |
| Close Tab | ⌘W |
| Duplicate Request | ⌘D |
| Copy cURL Command | ⇧⌘C |
| Show History | ⌘Y |
| Response Diff | ⇧⌘D |

## Architecture

```
gURL/
├── gURLApp.swift           # App entry point, menus, settings
├── ContentView.swift       # Legacy single-tab view
├── Models/
│   ├── CurlOptions.swift   # All cURL options as SwiftUI @Published properties
│   └── RequestTab.swift    # Tab management and history
├── ViewModels/
│   └── RequestViewModel.swift  # Request state and execution logic
├── Views/
│   ├── MainContentView.swift   # Multi-tab container
│   ├── BasicRequestView.swift  # URL and method options
│   ├── HeadersView.swift       # HTTP headers
│   ├── BodyView.swift          # Request body (raw, form, etc.)
│   ├── AuthenticationView.swift # Auth options
│   ├── SSLView.swift           # SSL/TLS settings
│   ├── ProxyView.swift         # Proxy configuration
│   ├── CookiesView.swift       # Cookie management
│   ├── AdvancedOptionsView.swift # Advanced cURL flags
│   ├── OutputOptionsView.swift # Output and verbosity
│   ├── ResponseView.swift      # Response display
│   ├── CommandPreviewView.swift # Live cURL command
│   ├── HistoryView.swift       # Request history
│   └── ResponseDiffView.swift  # Response comparison
└── Services/
    └── CurlService.swift       # cURL command generation and execution
```

## How It Works

gURL generates cURL commands based on your GUI selections and executes them using the system's `/bin/zsh` shell. This means:

- ✅ Uses your system's actual cURL binary
- ✅ Supports all cURL features your system supports
- ✅ Commands can be copied and run in terminal
- ✅ No network library dependencies

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by tools like Postman, Insomnia, and HTTPie
- Built with SwiftUI for native macOS performance
- cURL by Daniel Stenberg and contributors

---

**gURL** - Because sometimes you just need a GUI for cURL. 🚀
