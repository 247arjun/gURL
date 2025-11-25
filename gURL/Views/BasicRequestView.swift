import SwiftUI

struct BasicRequestView: View {
    @EnvironmentObject var viewModel: RequestViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // HTTP Version
            GroupBox("HTTP Version") {
                VStack(alignment: .leading, spacing: 12) {
                    Picker("HTTP Version", selection: $viewModel.options.httpVersion) {
                        ForEach(HTTPVersion.allCases) { version in
                            Text(version.rawValue).tag(version)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Text("Select the HTTP protocol version to use")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            // User Agent
            GroupBox("User Agent") {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Custom User-Agent string", text: $viewModel.options.userAgent)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                    
                    Text("-A, --user-agent <name>")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Button("Chrome") {
                            setUserAgent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
                        }
                        Button("Firefox") {
                            setUserAgent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:121.0) Gecko/20100101 Firefox/121.0")
                        }
                        Button("Safari") {
                            setUserAgent("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2 Safari/605.1.15")
                        }
                        Button("curl") {
                            setUserAgent("curl/8.4.0")
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 8)
            }
            
            // Referer
            GroupBox("Referer") {
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Referer URL", text: $viewModel.options.referer)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                    
                    HStack {
                        Text("-e, --referer <URL>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Toggle("Auto Referer", isOn: $viewModel.options.autoReferer)
                            .toggleStyle(.checkbox)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Connection Options
            GroupBox("Connection") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Toggle("Compressed", isOn: $viewModel.options.compressed)
                            .toggleStyle(.checkbox)
                        Text("--compressed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("TCP No Delay", isOn: $viewModel.options.tcpNoDelay)
                            .toggleStyle(.checkbox)
                        Text("--tcp-nodelay")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("TCP Fast Open", isOn: $viewModel.options.tcpFastOpen)
                            .toggleStyle(.checkbox)
                        Text("--tcp-fastopen")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("No Keep-Alive", isOn: $viewModel.options.noKeepalive)
                            .toggleStyle(.checkbox)
                        Text("--no-keepalive")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // IP Version
            GroupBox("IP Version") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 20) {
                        Toggle("IPv4 Only", isOn: $viewModel.options.ipv4Only)
                            .toggleStyle(.checkbox)
                            .onChange(of: viewModel.options.ipv4Only) { _, newValue in
                                if newValue {
                                    viewModel.options.ipv6Only = false
                                }
                            }
                        
                        Text("-4, --ipv4")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 20) {
                        Toggle("IPv6 Only", isOn: $viewModel.options.ipv6Only)
                            .toggleStyle(.checkbox)
                            .onChange(of: viewModel.options.ipv6Only) { _, newValue in
                                if newValue {
                                    viewModel.options.ipv4Only = false
                                }
                            }
                        
                        Text("-6, --ipv6")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
        }
    }
    
    private func setUserAgent(_ value: String) {
        viewModel.options.userAgent = value
        viewModel.objectWillChange.send()
    }
}

#Preview {
    BasicRequestView()
        .environmentObject(RequestViewModel())
        .padding()
        .frame(width: 500, height: 700)
}
