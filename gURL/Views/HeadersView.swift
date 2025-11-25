import SwiftUI

struct HeadersView: View {
    @EnvironmentObject var viewModel: RequestViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Headers Section
            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Request Headers")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: addHeader) {
                            Label("Add Header", systemImage: "plus")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Text("-H, --header <header/@file>")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    // Header List
                    ForEach($viewModel.options.headers) { $header in
                        HStack(spacing: 8) {
                            Toggle("", isOn: $header.isEnabled)
                                .toggleStyle(.checkbox)
                                .labelsHidden()
                            
                            TextField("Header Name", text: $header.key)
                                .textFieldStyle(.roundedBorder)
                                .frame(minWidth: 150)
                            
                            Text(":")
                                .foregroundColor(.secondary)
                            
                            TextField("Value", text: $header.value)
                                .textFieldStyle(.roundedBorder)
                            
                            Button(action: {
                                removeHeader(header)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Common Headers
            GroupBox("Quick Add Common Headers") {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(commonHeaders, id: \.0) { header in
                        Button(action: {
                            addCommonHeader(name: header.0, value: header.1)
                        }) {
                            HStack {
                                Text(header.0)
                                    .font(.system(size: 11, design: .monospaced))
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
        }
    }
    
    private let commonHeaders: [(String, String)] = [
        ("Content-Type", "application/json"),
        ("Accept", "application/json"),
        ("Accept-Language", "en-US,en;q=0.9"),
        ("Accept-Encoding", "gzip, deflate, br"),
        ("Cache-Control", "no-cache"),
        ("Connection", "keep-alive"),
        ("Origin", ""),
        ("X-Requested-With", "XMLHttpRequest"),
    ]
    
    private func addHeader() {
        viewModel.options.headers.append(KeyValuePair())
        viewModel.objectWillChange.send()
    }
    
    private func removeHeader(_ header: KeyValuePair) {
        viewModel.options.headers.removeAll { $0.id == header.id }
        if viewModel.options.headers.isEmpty {
            viewModel.options.headers.append(KeyValuePair())
        }
        viewModel.objectWillChange.send()
    }
    
    private func addCommonHeader(name: String, value: String) {
        // Check if header already exists
        if let index = viewModel.options.headers.firstIndex(where: { $0.key.lowercased() == name.lowercased() }) {
            viewModel.options.headers[index].value = value
            viewModel.options.headers[index].isEnabled = true
        } else {
            // Find first empty header or add new
            if let emptyIndex = viewModel.options.headers.firstIndex(where: { $0.key.isEmpty && $0.value.isEmpty }) {
                viewModel.options.headers[emptyIndex] = KeyValuePair(key: name, value: value)
            } else {
                viewModel.options.headers.append(KeyValuePair(key: name, value: value))
            }
        }
        viewModel.objectWillChange.send()
    }
}

#Preview {
    HeadersView()
        .environmentObject(RequestViewModel())
        .padding()
        .frame(width: 600, height: 600)
}
