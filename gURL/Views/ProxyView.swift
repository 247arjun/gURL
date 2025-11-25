import SwiftUI

struct ProxyView: View {
    @EnvironmentObject var viewModel: RequestViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Enable Proxy
            GroupBox("Proxy Configuration") {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Use Proxy", isOn: $viewModel.options.useProxy)
                        .toggleStyle(.checkbox)
                    
                    if viewModel.options.useProxy {
                        Divider()
                        
                        // Proxy Type
                        HStack {
                            Text("Type:")
                                .frame(width: 80, alignment: .trailing)
                            Picker("", selection: $viewModel.options.proxyType) {
                                ForEach(ProxyType.allCases) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .frame(width: 150)
                            
                            Text(viewModel.options.proxyType.curlFlag)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // Proxy Host
                        HStack {
                            Text("Host:")
                                .frame(width: 80, alignment: .trailing)
                            TextField("proxy.example.com", text: $viewModel.options.proxyHost)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(.body, design: .monospaced))
                        }
                        
                        // Proxy Port
                        HStack {
                            Text("Port:")
                                .frame(width: 80, alignment: .trailing)
                            TextField("8080", text: $viewModel.options.proxyPort)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                        }
                        
                        HStack {
                            Text("")
                                .frame(width: 80)
                            Text("-x, --proxy [protocol://]host[:port]")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Proxy Authentication
            if viewModel.options.useProxy {
                GroupBox("Proxy Authentication") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Username:")
                                .frame(width: 80, alignment: .trailing)
                            TextField("Proxy username", text: $viewModel.options.proxyUsername)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        HStack {
                            Text("Password:")
                                .frame(width: 80, alignment: .trailing)
                            SecureField("Proxy password", text: $viewModel.options.proxyPassword)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        HStack {
                            Text("")
                                .frame(width: 80)
                            Text("-U, --proxy-user <user:password>")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // Proxy Options
                GroupBox("Proxy Options") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Toggle("Proxy Tunnel (HTTP CONNECT)", isOn: $viewModel.options.proxyTunnel)
                                .toggleStyle(.checkbox)
                            Spacer()
                            Text("-p, --proxytunnel")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Makes curl tunnel through the proxy using HTTP CONNECT")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
                
                // No Proxy
                GroupBox("Proxy Bypass") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("No Proxy:")
                                .frame(width: 80, alignment: .trailing)
                            TextField("localhost,127.0.0.1,.local", text: $viewModel.options.noProxy)
                                .textFieldStyle(.roundedBorder)
                                .font(.system(.body, design: .monospaced))
                        }
                        
                        HStack {
                            Text("")
                                .frame(width: 80)
                            Text("--noproxy <no-proxy-list>")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Comma-separated list of hosts that should not use the proxy")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // Common Proxy Presets
            GroupBox("Quick Setup") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Common proxy configurations")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Button("HTTP Proxy (8080)") {
                            viewModel.options.useProxy = true
                            viewModel.options.proxyType = .http
                            viewModel.options.proxyHost = "127.0.0.1"
                            viewModel.options.proxyPort = "8080"
                            viewModel.objectWillChange.send()
                        }
                        
                        Button("SOCKS5 (1080)") {
                            viewModel.options.useProxy = true
                            viewModel.options.proxyType = .socks5
                            viewModel.options.proxyHost = "127.0.0.1"
                            viewModel.options.proxyPort = "1080"
                            viewModel.objectWillChange.send()
                        }
                        
                        Button("Charles (8888)") {
                            viewModel.options.useProxy = true
                            viewModel.options.proxyType = .http
                            viewModel.options.proxyHost = "127.0.0.1"
                            viewModel.options.proxyPort = "8888"
                            viewModel.objectWillChange.send()
                        }
                        
                        Button("Clear") {
                            viewModel.options.useProxy = false
                            viewModel.options.proxyHost = ""
                            viewModel.options.proxyPort = ""
                            viewModel.options.proxyUsername = ""
                            viewModel.options.proxyPassword = ""
                            viewModel.objectWillChange.send()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
        }
    }
}

#Preview {
    ProxyView()
        .environmentObject(RequestViewModel())
        .padding()
        .frame(width: 600, height: 700)
}
