import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var tabManager: TabManager
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedMethod: HTTPMethod?
    @State private var showPinnedOnly = false
    
    var filteredHistory: [HistoryItem] {
        let baseHistory = showPinnedOnly ? tabManager.pinnedItems : tabManager.sortedHistory
        return baseHistory.filter { item in
            let matchesSearch = searchText.isEmpty || 
                item.url.localizedCaseInsensitiveContains(searchText) ||
                item.method.localizedCaseInsensitiveContains(searchText)
            let matchesMethod = selectedMethod == nil || item.method == selectedMethod?.rawValue
            return matchesSearch && matchesMethod
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Request History")
                    .font(.headline)
                
                Spacer()
                
                Button("Clear Unpinned") {
                    tabManager.clearUnpinnedHistory()
                }
                .buttonStyle(.bordered)
                .disabled(tabManager.unpinnedItems.isEmpty)
                
                Button("Clear All") {
                    tabManager.clearHistory()
                }
                .buttonStyle(.bordered)
                .disabled(tabManager.history.isEmpty)
                
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            Divider()
            
            // Search & Filter
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search history...", text: $searchText)
                    .textFieldStyle(.plain)
                
                Toggle(isOn: $showPinnedOnly) {
                    Label("Pinned Only", systemImage: "pin.fill")
                }
                .toggleStyle(.button)
                .buttonStyle(.bordered)
                
                Picker("Method", selection: $selectedMethod) {
                    Text("All Methods").tag(nil as HTTPMethod?)
                    ForEach(HTTPMethod.allCases) { method in
                        Text(method.rawValue).tag(method as HTTPMethod?)
                    }
                }
                .frame(width: 120)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // History List
            if filteredHistory.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: showPinnedOnly ? "pin.slash" : "clock")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(showPinnedOnly ? "No pinned requests" : "No history")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(showPinnedOnly ? "Pin requests to keep them accessible" : "Your request history will appear here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredHistory) { item in
                        HistoryItemRow(item: item) {
                            loadHistoryItem(item)
                        }
                        .contextMenu {
                            Button {
                                loadHistoryItem(item)
                            } label: {
                                Label("Load Request", systemImage: "arrow.down.doc")
                            }
                            
                            Button {
                                tabManager.togglePin(for: item)
                            } label: {
                                Label(item.isPinned ? "Unpin" : "Pin", systemImage: item.isPinned ? "pin.slash" : "pin")
                            }
                            
                            Divider()
                            
                            Button {
                                tabManager.setDiffLeftFromHistory(item)
                            } label: {
                                Label("Set as Diff Left", systemImage: "arrow.left.square")
                            }
                            .disabled(item.responseBody == nil)
                            
                            Button {
                                tabManager.setDiffRightFromHistory(item)
                            } label: {
                                Label("Set as Diff Right", systemImage: "arrow.right.square")
                            }
                            .disabled(item.responseBody == nil)
                            
                            Divider()
                            
                            Button {
                                copyCommand(item.command)
                            } label: {
                                Label("Copy cURL Command", systemImage: "doc.on.doc")
                            }
                            
                            Divider()
                            
                            Button(role: .destructive) {
                                tabManager.deleteHistoryItem(item)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
        }
    }
    
    private func loadHistoryItem(_ item: HistoryItem) {
        tabManager.loadFromHistory(item)
        dismiss()
    }
    
    private func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { filteredHistory[$0] }
        for item in itemsToDelete {
            tabManager.deleteHistoryItem(item)
        }
    }
    
    private func copyCommand(_ command: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(command, forType: .string)
    }
}

// MARK: - History Item Row
struct HistoryItemRow: View {
    let item: HistoryItem
    let onSelect: () -> Void
    @EnvironmentObject var tabManager: TabManager
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Pin indicator
                if item.isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
                
                // Method Badge
                Text(item.method)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(methodColor)
                    .cornerRadius(4)
                
                // URL
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.url)
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                    
                    HStack {
                        Text(item.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(String(format: "%.0fms", item.duration * 1000))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Pin button
                Button {
                    tabManager.togglePin(for: item)
                } label: {
                    Image(systemName: item.isPinned ? "pin.fill" : "pin")
                        .foregroundColor(item.isPinned ? .orange : .secondary)
                }
                .buttonStyle(.plain)
                .help(item.isPinned ? "Unpin" : "Pin")
                
                // Status Code
                if let statusCode = item.statusCode {
                    Text("\(statusCode)")
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(statusColor(for: statusCode))
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var methodColor: Color {
        switch item.method {
        case "GET": return .blue
        case "POST": return .green
        case "PUT": return .orange
        case "DELETE": return .red
        case "PATCH": return .purple
        default: return .gray
        }
    }
    
    private func statusColor(for code: Int) -> Color {
        switch code {
        case 200..<300: return .green
        case 300..<400: return .orange
        case 400..<500: return .red
        case 500..<600: return .red
        default: return .secondary
        }
    }
}

#Preview {
    HistoryView()
        .environmentObject(TabManager())
        .frame(width: 700, height: 500)
}
