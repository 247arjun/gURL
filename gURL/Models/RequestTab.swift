import SwiftUI

/// Represents a single request tab with its own view model
@MainActor
struct RequestTabItem: Identifiable {
    let id: UUID
    let viewModel: RequestViewModel
    
    init(viewModel: RequestViewModel) {
        self.id = UUID()
        self.viewModel = viewModel
    }
    
    init() {
        self.id = UUID()
        self.viewModel = RequestViewModel()
    }
    
    init(from options: CurlOptions) {
        self.id = UUID()
        let vm = RequestViewModel()
        vm.options = options.copy()
        self.viewModel = vm
    }
    
    /// Returns a truncated title based on the cURL command
    var title: String {
        let method = viewModel.options.method.rawValue
        let url = viewModel.options.url
        
        if url.isEmpty {
            return "New Request"
        }
        
        // Truncate URL if too long
        let maxLength = 40
        var displayUrl = url
        
        // Remove protocol for brevity
        if displayUrl.hasPrefix("https://") {
            displayUrl = String(displayUrl.dropFirst(8))
        } else if displayUrl.hasPrefix("http://") {
            displayUrl = String(displayUrl.dropFirst(7))
        }
        
        // Truncate if needed
        if displayUrl.count > maxLength {
            displayUrl = String(displayUrl.prefix(maxLength)) + "..."
        }
        
        return "\(method) \(displayUrl)"
    }
}

extension RequestTabItem: Equatable {
    nonisolated static func == (lhs: RequestTabItem, rhs: RequestTabItem) -> Bool {
        lhs.id == rhs.id
    }
}

/// Manages multiple request tabs
@MainActor
class TabManager: ObservableObject {
    @Published var tabs: [RequestTabItem] = []
    @Published var selectedTabId: UUID?
    
    // Shared state
    @Published var history: [HistoryItem] = []
    @Published var diffLeftResponse: CurlResponse?
    @Published var diffRightResponse: CurlResponse?
    
    private let historyKey = "gURL.history"
    private let maxHistoryItems = 100
    
    var selectedTab: RequestTabItem? {
        tabs.first { $0.id == selectedTabId }
    }
    
    var selectedViewModel: RequestViewModel? {
        selectedTab?.viewModel
    }
    
    var pinnedItems: [HistoryItem] {
        history.filter { $0.isPinned }
    }
    
    var unpinnedItems: [HistoryItem] {
        history.filter { !$0.isPinned }
    }
    
    var sortedHistory: [HistoryItem] {
        pinnedItems + unpinnedItems
    }
    
    init() {
        loadHistory()
        // Create initial tab
        let initialTab = RequestTabItem()
        tabs.append(initialTab)
        selectedTabId = initialTab.id
    }
    
    // MARK: - Tab Management
    func newTab() {
        let newTab = RequestTabItem()
        tabs.append(newTab)
        selectedTabId = newTab.id
    }
    
    func duplicateCurrentTab() {
        guard let currentTab = selectedTab else {
            newTab()
            return
        }
        
        let duplicatedTab = RequestTabItem(from: currentTab.viewModel.options)
        tabs.append(duplicatedTab)
        selectedTabId = duplicatedTab.id
    }
    
    func closeTab(_ tab: RequestTabItem) {
        guard tabs.count > 1 else { return } // Keep at least one tab
        
        if let index = tabs.firstIndex(of: tab) {
            tabs.remove(at: index)
            
            // Select adjacent tab if closing current
            if selectedTabId == tab.id {
                let newIndex = min(index, tabs.count - 1)
                selectedTabId = tabs[newIndex].id
            }
        }
    }
    
    func closeOtherTabs(_ keepTab: RequestTabItem) {
        tabs = tabs.filter { $0.id == keepTab.id }
        selectedTabId = keepTab.id
    }
    
    func selectTab(_ tab: RequestTabItem) {
        selectedTabId = tab.id
    }
    
    // MARK: - History Management (shared across tabs)
    func addToHistory(_ response: CurlResponse, url: String, method: String) {
        let item = HistoryItem(from: response, url: url, method: method)
        history.insert(item, at: 0)
        
        // Limit history size (but don't remove pinned items)
        let unpinned = history.filter { !$0.isPinned }
        let pinned = history.filter { $0.isPinned }
        if unpinned.count > maxHistoryItems {
            let trimmedUnpinned = Array(unpinned.prefix(maxHistoryItems))
            history = pinned + trimmedUnpinned
        }
        
        saveHistory()
    }
    
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
    
    func clearUnpinnedHistory() {
        history = history.filter { $0.isPinned }
        saveHistory()
    }
    
    func togglePin(for item: HistoryItem) {
        if let index = history.firstIndex(where: { $0.id == item.id }) {
            history[index].isPinned.toggle()
            saveHistory()
        }
    }
    
    func deleteHistoryItem(_ item: HistoryItem) {
        history.removeAll { $0.id == item.id }
        saveHistory()
    }
    
    func loadFromHistory(_ item: HistoryItem) {
        guard let viewModel = selectedViewModel else { return }
        viewModel.options.url = item.url
        if let method = HTTPMethod(rawValue: item.method) {
            viewModel.options.method = method
        }
        viewModel.objectWillChange.send()
    }
    
    func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([HistoryItem].self, from: data) {
            history = decoded
        }
    }
    
    // MARK: - Response Diff (shared across tabs)
    func setDiffLeft() {
        diffLeftResponse = selectedViewModel?.response
    }
    
    func setDiffRight() {
        diffRightResponse = selectedViewModel?.response
    }
    
    func setDiffLeftFromHistory(_ item: HistoryItem) {
        if let body = item.responseBody {
            diffLeftResponse = CurlResponse(
                timestamp: item.timestamp,
                command: item.command,
                statusCode: item.statusCode,
                headers: item.responseHeaders ?? "",
                body: body,
                errorOutput: "",
                duration: item.duration,
                success: true
            )
        }
    }
    
    func setDiffRightFromHistory(_ item: HistoryItem) {
        if let body = item.responseBody {
            diffRightResponse = CurlResponse(
                timestamp: item.timestamp,
                command: item.command,
                statusCode: item.statusCode,
                headers: item.responseHeaders ?? "",
                body: body,
                errorOutput: "",
                duration: item.duration,
                success: true
            )
        }
    }
    
    func clearDiff() {
        diffLeftResponse = nil
        diffRightResponse = nil
    }
    
    // MARK: - Clipboard Operations
    func copyCommand() {
        guard let viewModel = selectedViewModel else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(viewModel.generatedCommand, forType: .string)
    }
    
    func copyResponse() {
        guard let response = selectedViewModel?.response else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(response.body, forType: .string)
    }
    
    func copyResponseHeaders() {
        guard let response = selectedViewModel?.response else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(response.headers, forType: .string)
    }
}
