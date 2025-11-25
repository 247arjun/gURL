import SwiftUI

@main
struct gURLApp: App {
    @StateObject private var tabManager = TabManager()
    @State private var showingHistory = false
    @State private var showingDiff = false
    
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .frame(minWidth: 1000, minHeight: 700)
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.unified)
        .commands {
            // MARK: - File Menu
            CommandGroup(replacing: .newItem) {
                Button("New Tab") {
                    NotificationCenter.default.post(name: .newTab, object: nil)
                }
                .keyboardShortcut("t", modifiers: .command)
                
                Button("New Request") {
                    NotificationCenter.default.post(name: .newRequest, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)
                
                Button("Duplicate Request") {
                    NotificationCenter.default.post(name: .duplicateRequest, object: nil)
                }
                .keyboardShortcut("d", modifiers: .command)
                
                Divider()
                
                Button("Close Tab") {
                    NotificationCenter.default.post(name: .closeTab, object: nil)
                }
                .keyboardShortcut("w", modifiers: .command)
            }
            
            // MARK: - Edit Menu additions
            CommandGroup(after: .pasteboard) {
                Divider()
                
                Button("Copy cURL Command") {
                    NotificationCenter.default.post(name: .copyCommand, object: nil)
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
                
                Button("Copy Response Body") {
                    NotificationCenter.default.post(name: .copyResponse, object: nil)
                }
                .keyboardShortcut("c", modifiers: [.command, .option])
                
                Button("Copy Response Headers") {
                    NotificationCenter.default.post(name: .copyResponseHeaders, object: nil)
                }
            }
            
            // MARK: - Request Menu
            CommandMenu("Request") {
                Button("Send Request") {
                    NotificationCenter.default.post(name: .sendRequest, object: nil)
                }
                .keyboardShortcut(.return, modifiers: .command)
                
                Button("Cancel Request") {
                    NotificationCenter.default.post(name: .cancelRequest, object: nil)
                }
                .keyboardShortcut(".", modifiers: .command)
                
                Divider()
                
                Menu("HTTP Method") {
                    ForEach(HTTPMethod.allCases) { method in
                        Button(method.rawValue) {
                            NotificationCenter.default.post(name: .setMethod, object: method)
                        }
                    }
                }
                
                Divider()
                
                Button("Toggle Follow Redirects") {
                    NotificationCenter.default.post(name: .toggleFollowRedirects, object: nil)
                }
                .keyboardShortcut("l", modifiers: [.command, .option])
                
                Button("Toggle Include Headers") {
                    NotificationCenter.default.post(name: .toggleIncludeHeaders, object: nil)
                }
                .keyboardShortcut("h", modifiers: [.command, .option])
                
                Button("Toggle Verbose") {
                    NotificationCenter.default.post(name: .toggleVerbose, object: nil)
                }
                .keyboardShortcut("v", modifiers: [.command, .option])
                
                Button("Toggle Insecure") {
                    NotificationCenter.default.post(name: .toggleInsecure, object: nil)
                }
                .keyboardShortcut("k", modifiers: [.command, .option])
                
                Button("Toggle Compressed") {
                    NotificationCenter.default.post(name: .toggleCompressed, object: nil)
                }
            }
            
            // MARK: - Response Menu
            CommandMenu("Response") {
                Button("Set as Diff Left") {
                    NotificationCenter.default.post(name: .setDiffLeft, object: nil)
                }
                .keyboardShortcut("[", modifiers: [.command, .option])
                
                Button("Set as Diff Right") {
                    NotificationCenter.default.post(name: .setDiffRight, object: nil)
                }
                .keyboardShortcut("]", modifiers: [.command, .option])
                
                Button("Open Diff View") {
                    NotificationCenter.default.post(name: .openDiffView, object: nil)
                }
                .keyboardShortcut("d", modifiers: [.command, .option])
                
                Button("Clear Diff Selections") {
                    NotificationCenter.default.post(name: .clearDiff, object: nil)
                }
                
                Divider()
                
                Button("Copy Response Body") {
                    NotificationCenter.default.post(name: .copyResponse, object: nil)
                }
                
                Button("Copy Response Headers") {
                    NotificationCenter.default.post(name: .copyResponseHeaders, object: nil)
                }
            }
            
            // MARK: - History Menu
            CommandMenu("History") {
                Button("Show History") {
                    NotificationCenter.default.post(name: .showHistory, object: nil)
                }
                .keyboardShortcut("y", modifiers: .command)
                
                Divider()
                
                Button("Clear Unpinned History") {
                    NotificationCenter.default.post(name: .clearUnpinnedHistory, object: nil)
                }
                
                Button("Clear All History") {
                    NotificationCenter.default.post(name: .clearAllHistory, object: nil)
                }
                .keyboardShortcut(.delete, modifiers: [.command, .shift])
            }
            
            // MARK: - View Menu additions
            CommandGroup(after: .toolbar) {
                Divider()
                
                Button("Show Response Diff") {
                    NotificationCenter.default.post(name: .openDiffView, object: nil)
                }
                .keyboardShortcut("d", modifiers: [.command, .shift])
            }
        }
        
        Settings {
            SettingsView()
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let newTab = Notification.Name("newTab")
    static let newRequest = Notification.Name("newRequest")
    static let duplicateRequest = Notification.Name("duplicateRequest")
    static let closeTab = Notification.Name("closeTab")
    static let sendRequest = Notification.Name("sendRequest")
    static let cancelRequest = Notification.Name("cancelRequest")
    static let copyCommand = Notification.Name("copyCommand")
    static let copyResponse = Notification.Name("copyResponse")
    static let copyResponseHeaders = Notification.Name("copyResponseHeaders")
    static let setMethod = Notification.Name("setMethod")
    static let toggleFollowRedirects = Notification.Name("toggleFollowRedirects")
    static let toggleIncludeHeaders = Notification.Name("toggleIncludeHeaders")
    static let toggleVerbose = Notification.Name("toggleVerbose")
    static let toggleInsecure = Notification.Name("toggleInsecure")
    static let toggleCompressed = Notification.Name("toggleCompressed")
    static let setDiffLeft = Notification.Name("setDiffLeft")
    static let setDiffRight = Notification.Name("setDiffRight")
    static let openDiffView = Notification.Name("openDiffView")
    static let clearDiff = Notification.Name("clearDiff")
    static let showHistory = Notification.Name("showHistory")
    static let clearUnpinnedHistory = Notification.Name("clearUnpinnedHistory")
    static let clearAllHistory = Notification.Name("clearAllHistory")
}

// MARK: - Settings View
struct SettingsView: View {
    @AppStorage("defaultUserAgent") private var defaultUserAgent: String = ""
    @AppStorage("defaultTimeout") private var defaultTimeout: String = "30"
    @AppStorage("followRedirectsByDefault") private var followRedirectsByDefault: Bool = true
    @AppStorage("curlPath") private var curlPath: String = "/usr/bin/curl"
    @AppStorage("maxHistoryItems") private var maxHistoryItems: Int = 100
    @AppStorage("saveResponsesInHistory") private var saveResponsesInHistory: Bool = true
    
    var body: some View {
        TabView {
            // General Tab
            Form {
                Section("Request Defaults") {
                    TextField("Default User Agent", text: $defaultUserAgent)
                    TextField("Default Timeout (seconds)", text: $defaultTimeout)
                    Toggle("Follow Redirects by Default", isOn: $followRedirectsByDefault)
                }
                
                Section("cURL") {
                    TextField("cURL Path", text: $curlPath)
                    Text("Default: /usr/bin/curl")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(width: 450, height: 250)
            .tabItem {
                Label("General", systemImage: "gear")
            }
            
            // History Tab
            Form {
                Section("History") {
                    Stepper("Max History Items: \(maxHistoryItems)", value: $maxHistoryItems, in: 10...500, step: 10)
                    Toggle("Save Response Bodies in History", isOn: $saveResponsesInHistory)
                    Text("Enables response diff from history. May use more disk space.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .frame(width: 450, height: 200)
            .tabItem {
                Label("History", systemImage: "clock")
            }
        }
    }
}
