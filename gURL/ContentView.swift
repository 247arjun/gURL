import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: RequestViewModel
    @State private var selectedTab: RequestTab = .basic
    @State private var showingHistory = false
    @State private var showingDiff = false
    
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
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    Task {
                        await viewModel.executeRequest()
                    }
                }) {
                    Label("Send", systemImage: "paperplane.fill")
                }
                .disabled(viewModel.options.url.isEmpty || viewModel.isLoading)
                .keyboardShortcut(.return, modifiers: .command)
                .help("Send Request (⌘↩)")
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { viewModel.duplicateRequest() }) {
                    Label("Duplicate", systemImage: "plus.square.on.square")
                }
                .help("Duplicate Request (⌘D)")
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { viewModel.copyCommand() }) {
                    Label("Copy cURL", systemImage: "doc.on.doc")
                }
                .help("Copy cURL Command (⇧⌘C)")
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { showingDiff = true }) {
                    Label("Diff", systemImage: "arrow.left.arrow.right")
                }
                .help("Response Diff (⇧⌘D)")
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { showingHistory.toggle() }) {
                    Label("History", systemImage: "clock")
                }
                .help("Show History (⌘Y)")
            }
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView()
                .environmentObject(viewModel)
                .frame(minWidth: 700, minHeight: 500)
        }
        .sheet(isPresented: $showingDiff) {
            ResponseDiffView()
                .environmentObject(viewModel)
                .frame(minWidth: 900, minHeight: 600)
        }
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
                    await viewModel.executeRequest()
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
                        viewModel.setDiffLeft()
                    }
                    Button("Set as Diff Right") {
                        viewModel.setDiffRight()
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
    ContentView()
        .environmentObject(RequestViewModel())
        .frame(width: 1200, height: 800)
}
