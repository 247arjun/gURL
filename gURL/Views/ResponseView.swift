import SwiftUI

struct ResponseView: View {
    @EnvironmentObject var viewModel: RequestViewModel
    @State private var selectedTab: ResponseTab = .body
    
    enum ResponseTab: String, CaseIterable {
        case body = "Body"
        case headers = "Headers"
        case raw = "Raw"
        case error = "Error"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading {
                loadingView
            } else if let response = viewModel.response {
                responseContent(response)
            } else {
                emptyView
            }
        }
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Executing request...")
                .foregroundColor(.secondary)
            
            Button("Cancel") {
                viewModel.cancelRequest()
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty View
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.up.arrow.down.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("No response yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Enter a URL and click Send to make a request")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Response Content
    private func responseContent(_ response: CurlResponse) -> some View {
        VStack(spacing: 0) {
            // Tab Navigation
            HStack(spacing: 0) {
                ForEach(ResponseTab.allCases, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        HStack {
                            Text(tab.rawValue)
                            if tab == .error && !response.errorOutput.isEmpty {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .font(.system(size: 12, weight: selectedTab == tab ? .semibold : .regular))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(selectedTab == tab ? Color.accentColor.opacity(0.1) : Color.clear)
                        .foregroundColor(selectedTab == tab ? .accentColor : .primary)
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .padding(.horizontal)
            
            Divider()
            
            // Tab Content
            switch selectedTab {
            case .body:
                bodyView(response)
            case .headers:
                headersView(response)
            case .raw:
                rawView(response)
            case .error:
                errorView(response)
            }
        }
    }
    
    // MARK: - Body View
    private func bodyView(_ response: CurlResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if response.body.isEmpty {
                    Text("No response body")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    Text(formatBody(response.body))
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
    
    // MARK: - Headers View
    private func headersView(_ response: CurlResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if response.headers.isEmpty {
                    Text("No headers captured")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    ForEach(parseHeaders(response.headers), id: \.0) { header in
                        HStack(alignment: .top) {
                            Text(header.0)
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)
                            Text(": ")
                                .foregroundColor(.secondary)
                            Text(header.1)
                                .textSelection(.enabled)
                            Spacer()
                        }
                        .font(.system(.body, design: .monospaced))
                    }
                }
            }
            .padding()
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
    
    // MARK: - Raw View
    private func rawView(_ response: CurlResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                GroupBox("Headers") {
                    Text(response.headers.isEmpty ? "(none)" : response.headers)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                GroupBox("Body") {
                    Text(response.body.isEmpty ? "(none)" : response.body)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Error View
    private func errorView(_ response: CurlResponse) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                if response.errorOutput.isEmpty && response.success {
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 48))
                            .foregroundColor(.green)
                        Text("No errors")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    Text(response.errorOutput)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.red)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
    
    // MARK: - Helpers
    private func formatBody(_ body: String) -> String {
        // Try to format as JSON
        if let data = body.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }
        return body
    }
    
    private func parseHeaders(_ headers: String) -> [(String, String)] {
        headers.components(separatedBy: "\r\n")
            .filter { !$0.isEmpty }
            .compactMap { line -> (String, String)? in
                if let colonIndex = line.firstIndex(of: ":") {
                    let key = String(line[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                    let value = String(line[line.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                    return (key, value)
                }
                return (line, "")
            }
    }
}

#Preview {
    ResponseView()
        .environmentObject(RequestViewModel())
        .frame(width: 500, height: 600)
}
