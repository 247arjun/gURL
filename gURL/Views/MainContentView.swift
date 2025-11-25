import SwiftUI

struct MainContentView: View {
    @StateObject private var tabManager = TabManager()
    @State private var showingHistory = false
    @State private var showingDiff = false
    
    var body: some View {
        MainContentInner(
            tabManager: tabManager,
            showingHistory: $showingHistory,
            showingDiff: $showingDiff
        )
    }
}

// Separate view to avoid type-check complexity
struct MainContentInner: View {
    @ObservedObject var tabManager: TabManager
    @Binding var showingHistory: Bool
    @Binding var showingDiff: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            TabBarView(tabManager: tabManager)
            Divider()
            if let selectedTab = tabManager.selectedTab {
                RequestContentView(showingHistory: $showingHistory, showingDiff: $showingDiff)
                    .environmentObject(selectedTab.viewModel)
                    .environmentObject(tabManager)
                    .id(selectedTab.id)
            }
        }
        .frame(minWidth: 1000, minHeight: 700)
        .sheet(isPresented: $showingHistory) {
            HistoryView()
                .environmentObject(tabManager)
                .frame(minWidth: 700, minHeight: 500)
        }
        .sheet(isPresented: $showingDiff) {
            ResponseDiffView()
                .environmentObject(tabManager)
                .frame(minWidth: 900, minHeight: 600)
        }
        .modifier(NotificationHandlers(tabManager: tabManager, showingHistory: $showingHistory, showingDiff: $showingDiff))
    }
}

// ViewModifier to handle notifications - Part 1
struct NotificationHandlers: ViewModifier {
    @ObservedObject var tabManager: TabManager
    @Binding var showingHistory: Bool
    @Binding var showingDiff: Bool
    
    func body(content: Content) -> some View {
        content
            .modifier(NotificationHandlers2(tabManager: tabManager, showingHistory: $showingHistory, showingDiff: $showingDiff))
            .onReceive(NotificationCenter.default.publisher(for: .newTab)) { _ in 
                tabManager.newTab() 
            }
            .onReceive(NotificationCenter.default.publisher(for: .newRequest)) { _ in 
                tabManager.selectedViewModel?.options.reset()
                tabManager.selectedViewModel?.response = nil
                tabManager.selectedViewModel?.objectWillChange.send()
            }
            .onReceive(NotificationCenter.default.publisher(for: .duplicateRequest)) { _ in 
                tabManager.duplicateCurrentTab() 
            }
            .onReceive(NotificationCenter.default.publisher(for: .closeTab)) { _ in 
                if let tab = tabManager.selectedTab {
                    tabManager.closeTab(tab)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .copyCommand)) { _ in 
                tabManager.copyCommand() 
            }
            .onReceive(NotificationCenter.default.publisher(for: .copyResponse)) { _ in 
                tabManager.copyResponse() 
            }
            .onReceive(NotificationCenter.default.publisher(for: .copyResponseHeaders)) { _ in 
                tabManager.copyResponseHeaders() 
            }
    }
}

// ViewModifier to handle notifications - Part 2
struct NotificationHandlers2: ViewModifier {
    @ObservedObject var tabManager: TabManager
    @Binding var showingHistory: Bool
    @Binding var showingDiff: Bool
    
    func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: .setMethod)) { notification in
                if let method = notification.object as? HTTPMethod {
                    tabManager.selectedViewModel?.options.method = method
                    tabManager.selectedViewModel?.objectWillChange.send()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .toggleFollowRedirects)) { _ in
                tabManager.selectedViewModel?.options.followRedirects.toggle()
                tabManager.selectedViewModel?.objectWillChange.send()
            }
            .onReceive(NotificationCenter.default.publisher(for: .toggleIncludeHeaders)) { _ in
                tabManager.selectedViewModel?.options.includeHeaders.toggle()
                tabManager.selectedViewModel?.objectWillChange.send()
            }
            .onReceive(NotificationCenter.default.publisher(for: .toggleVerbose)) { _ in
                tabManager.selectedViewModel?.options.verbose.toggle()
                tabManager.selectedViewModel?.objectWillChange.send()
            }
            .onReceive(NotificationCenter.default.publisher(for: .toggleInsecure)) { _ in
                tabManager.selectedViewModel?.options.insecure.toggle()
                tabManager.selectedViewModel?.objectWillChange.send()
            }
            .onReceive(NotificationCenter.default.publisher(for: .toggleCompressed)) { _ in
                tabManager.selectedViewModel?.options.compressed.toggle()
                tabManager.selectedViewModel?.objectWillChange.send()
            }
            .onReceive(NotificationCenter.default.publisher(for: .setDiffLeft)) { _ in 
                tabManager.setDiffLeft() 
            }
            .onReceive(NotificationCenter.default.publisher(for: .setDiffRight)) { _ in 
                tabManager.setDiffRight() 
            }
            .onReceive(NotificationCenter.default.publisher(for: .openDiffView)) { _ in 
                showingDiff = true 
            }
            .onReceive(NotificationCenter.default.publisher(for: .clearDiff)) { _ in 
                tabManager.clearDiff() 
            }
            .onReceive(NotificationCenter.default.publisher(for: .showHistory)) { _ in 
                showingHistory = true 
            }
            .onReceive(NotificationCenter.default.publisher(for: .clearUnpinnedHistory)) { _ in 
                tabManager.clearUnpinnedHistory() 
            }
            .onReceive(NotificationCenter.default.publisher(for: .clearAllHistory)) { _ in 
                tabManager.clearHistory() 
            }
    }
}

// MARK: - Tab Bar View
struct TabBarView: View {
    @ObservedObject var tabManager: TabManager
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(tabManager.tabs) { tab in
                    TabItemView(
                        tab: tab,
                        isSelected: tab.id == tabManager.selectedTabId,
                        tabManager: tabManager
                    )
                }
                
                // New Tab Button
                Button(action: { tabManager.newTab() }) {
                    Image(systemName: "plus")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .help("New Tab (⌘T)")
                
                Spacer()
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 36)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

// MARK: - Tab Item View
struct TabItemView: View {
    let tab: RequestTabItem
    let isSelected: Bool
    @ObservedObject var tabManager: TabManager
    @ObservedObject var viewModel: RequestViewModel
    @State private var isHovering = false
    
    init(tab: RequestTabItem, isSelected: Bool, tabManager: TabManager) {
        self.tab = tab
        self.isSelected = isSelected
        self.tabManager = tabManager
        self.viewModel = tab.viewModel
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // Loading indicator or method badge
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.5)
                    .frame(width: 14, height: 14)
            } else {
                methodBadge
            }
            
            // Title
            Text(tab.title)
                .font(.system(size: 11))
                .lineLimit(1)
                .foregroundColor(isSelected ? .primary : .secondary)
            
            // Close button
            if tabManager.tabs.count > 1 && (isSelected || isHovering) {
                Button(action: { tabManager.closeTab(tab) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .frame(width: 16, height: 16)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isSelected ? Color.accentColor.opacity(0.15) : (isHovering ? Color.secondary.opacity(0.1) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isSelected ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .onTapGesture {
            tabManager.selectTab(tab)
        }
        .onHover { hovering in
            isHovering = hovering
        }
        .contextMenu {
            Button("Close Tab") {
                tabManager.closeTab(tab)
            }
            .disabled(tabManager.tabs.count <= 1)
            
            Button("Close Other Tabs") {
                tabManager.closeOtherTabs(tab)
            }
            .disabled(tabManager.tabs.count <= 1)
            
            Divider()
            
            Button("Duplicate Tab") {
                tabManager.selectTab(tab)
                tabManager.duplicateCurrentTab()
            }
            
            Divider()
            
            Button("New Tab") {
                tabManager.newTab()
            }
        }
    }
    
    private var methodBadge: some View {
        Text(viewModel.options.method.rawValue.prefix(3))
            .font(.system(size: 8, weight: .bold, design: .monospaced))
            .foregroundColor(methodColor)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(methodColor.opacity(0.15))
            .cornerRadius(3)
    }
    
    private var methodColor: Color {
        switch viewModel.options.method {
        case .GET: return .green
        case .POST: return .blue
        case .PUT: return .orange
        case .PATCH: return .purple
        case .DELETE: return .red
        case .HEAD: return .gray
        case .OPTIONS: return .cyan
        case .TRACE: return .mint
        case .CONNECT: return .indigo
        }
    }
}

// MARK: - Request Content View (the actual request UI)
struct RequestContentView: View {
    @EnvironmentObject var viewModel: RequestViewModel
    @EnvironmentObject var tabManager: TabManager
    @Binding var showingHistory: Bool
    @Binding var showingDiff: Bool
    
    @State private var selectedTab: RequestTab = .basic
    
    enum RequestTab: String, CaseIterable {
        case basic = "Basic"
        case headers = "Headers"
        case body = "Body"
        case auth = "Auth"
        case cookies = "Cookies"
        case ssl = "SSL/TLS"
        case proxy = "Proxy"
        case advanced = "Advanced"
        case output = "Output"
    }
    
    var body: some View {
        HSplitView {
            // Left Panel - Request Configuration
            VStack(spacing: 0) {
                // URL Bar
                urlBar
                    .padding()
                
                Divider()
                
                // Tab Navigation
                tabNavigation
                
                Divider()
                
                // Tab Content
                ScrollView {
                    tabContent
                        .padding()
                }
                
                Divider()
                
                // Command Preview
                CommandPreviewView()
                    .frame(height: 120)
            }
            .frame(minWidth: 500)
            
            // Right Panel - Response
            VStack(spacing: 0) {
                // Response Header
                responseHeader
                
                Divider()
                
                // Response Content
                ResponseView()
            }
            .frame(minWidth: 400)
        }
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Text("")
                    .frame(width: 0)
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    Task {
                        await executeRequest()
                    }
                }) {
                    Label("Send", systemImage: "paperplane.fill")
                }
                .disabled(viewModel.options.url.isEmpty || viewModel.isLoading)
                .keyboardShortcut(.return, modifiers: .command)
                .help("Send Request (⌘↩)")
                
                Button(action: { tabManager.duplicateCurrentTab() }) {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }
                .help("Duplicate Request in New Tab (⌘D)")
                
                Button(action: { tabManager.copyCommand() }) {
                    Label("Copy cURL", systemImage: "doc.on.doc")
                }
                .help("Copy cURL Command (⇧⌘C)")
                
                Button(action: { showingDiff = true }) {
                    Label("Diff", systemImage: "arrow.left.arrow.right")
                }
                .help("Response Diff (⇧⌘D)")
                
                Button(action: { showingHistory.toggle() }) {
                    Label("History", systemImage: "clock")
                }
                .help("Show History (⌘Y)")
            }
        }
    }
    
    // MARK: - Execute Request
    private func executeRequest() async {
        guard !viewModel.options.url.isEmpty else { return }
        
        viewModel.isLoading = true
        viewModel.response = nil
        
        do {
            // Add -i flag to capture headers for display
            let commandOptions = viewModel.options.copy()
            if !commandOptions.includeHeaders && !commandOptions.headOnly {
                commandOptions.includeHeaders = true
            }
            
            let command = CurlService.shared.generateCommand(from: commandOptions)
            let result = try await CurlService.shared.execute(command: command)
            
            viewModel.response = result
            
            // Add to shared history
            tabManager.addToHistory(result, url: viewModel.options.url, method: viewModel.options.method.rawValue)
        } catch {
            viewModel.response = CurlResponse(
                timestamp: Date(),
                command: viewModel.generatedCommand,
                statusCode: nil,
                headers: "",
                body: "",
                errorOutput: error.localizedDescription,
                duration: 0,
                success: false
            )
        }
        
        viewModel.isLoading = false
    }
    
    // MARK: - URL Bar
    private var urlBar: some View {
        HStack(spacing: 12) {
            // Method Picker
            Picker("", selection: $viewModel.options.method) {
                ForEach(HTTPMethod.allCases) { method in
                    Text(method.rawValue)
                        .tag(method)
                }
            }
            .frame(width: 100)
            .labelsHidden()
            
            // URL Field
            TextField("Enter URL (e.g., https://api.example.com/endpoint)", text: $viewModel.options.url)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
            
            // Send Button
            Button(action: {
                Task {
                    await executeRequest()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 60)
                } else {
                    Text("Send")
                        .frame(width: 60)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.options.url.isEmpty || viewModel.isLoading)
        }
    }
    
    // MARK: - Tab Navigation
    private var tabNavigation: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(RequestTab.allCases, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        Text(tab.rawValue)
                            .font(.system(size: 12, weight: selectedTab == tab ? .semibold : .regular))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedTab == tab ? Color.accentColor.opacity(0.1) : Color.clear)
                            .foregroundColor(selectedTab == tab ? .accentColor : .primary)
                    }
                    .buttonStyle(.plain)
                    
                    if tab != RequestTab.allCases.last {
                        Divider()
                            .frame(height: 20)
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 36)
    }
    
    // MARK: - Tab Content
    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .basic:
            BasicRequestView()
        case .headers:
            HeadersView()
        case .body:
            BodyView()
        case .auth:
            AuthenticationView()
        case .cookies:
            CookiesView()
        case .ssl:
            SSLView()
        case .proxy:
            ProxyView()
        case .advanced:
            AdvancedOptionsView()
        case .output:
            OutputOptionsView()
        }
    }
    
    // MARK: - Response Header
    private var responseHeader: some View {
        HStack {
            Text("Response")
                .font(.headline)
            
            Spacer()
            
            if let response = viewModel.response {
                // Diff buttons
                Menu {
                    Button("Set as Diff Left") {
                        tabManager.setDiffLeft()
                    }
                    Button("Set as Diff Right") {
                        tabManager.setDiffRight()
                    }
                    Divider()
                    Button("Open Diff View") {
                        showingDiff = true
                    }
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                }
                .menuStyle(.borderlessButton)
                .frame(width: 30)
                .help("Response Diff Options")
                
                HStack(spacing: 16) {
                    // Status
                    Text(response.statusText)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(statusColor(for: response.statusCode))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(for: response.statusCode).opacity(0.1))
                        .cornerRadius(4)
                    
                    // Duration
                    Text(response.formattedDuration)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
    
    private func statusColor(for code: Int?) -> Color {
        guard let code = code else { return .red }
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
    MainContentView()
        .frame(width: 1200, height: 800)
}
