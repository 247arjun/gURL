import SwiftUI
import Combine

@MainActor
class RequestViewModel: ObservableObject {
    @Published var options = CurlOptions()
    @Published var response: CurlResponse?
    @Published var isLoading = false
    @Published var history: [HistoryItem] = []
    @Published var diffLeftResponse: CurlResponse?
    @Published var diffRightResponse: CurlResponse?
    @Published var showingDiffView = false
    
    private let curlService = CurlService.shared
    private let historyKey = "gURL.history"
    private let maxHistoryItems = 100
    
    var generatedCommand: String {
        curlService.generateCommand(from: options)
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
    }
    
    // MARK: - Request Execution
    func executeRequest() async {
        guard !options.url.isEmpty else { return }
        
        isLoading = true
        response = nil
        
        do {
            // Add -i flag to capture headers for display
            let commandOptions = options.copy()
            if !commandOptions.includeHeaders && !commandOptions.headOnly {
                commandOptions.includeHeaders = true
            }
            
            let command = curlService.generateCommand(from: commandOptions)
            let result = try await curlService.execute(command: command)
            
            response = result
            
            // Add to history
            addToHistory(result)
        } catch {
            response = CurlResponse(
                timestamp: Date(),
                command: generatedCommand,
                statusCode: nil,
                headers: "",
                body: "",
                errorOutput: error.localizedDescription,
                duration: 0,
                success: false
            )
        }
        
        isLoading = false
    }
    
    func cancelRequest() {
        curlService.cancel()
        isLoading = false
    }
    
    // MARK: - Command Operations
    func copyCommand() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(generatedCommand, forType: .string)
    }
    
    func copyResponse() {
        guard let response = response else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(response.body, forType: .string)
    }
    
    func copyResponseHeaders() {
        guard let response = response else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(response.headers, forType: .string)
    }
    
    // MARK: - Request Management
    func newRequest() {
        options.reset()
        response = nil
    }
    
    func duplicateRequest() {
        // Options are already in the current state, just clear the response
        // The user can modify and resend
        response = nil
    }
    
    // MARK: - History Management
    func addToHistory(_ response: CurlResponse) {
        let item = HistoryItem(from: response, url: options.url, method: options.method.rawValue)
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
        options.url = item.url
        if let method = HTTPMethod(rawValue: item.method) {
            options.method = method
        }
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
    
    // MARK: - Response Diff
    func setDiffLeft() {
        diffLeftResponse = response
    }
    
    func setDiffRight() {
        diffRightResponse = response
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
    
    func openDiffView() {
        showingDiffView = true
    }
}
