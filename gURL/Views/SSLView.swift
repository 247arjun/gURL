import SwiftUI

struct SSLView: View {
    @EnvironmentObject var viewModel: RequestViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // SSL/TLS Version
            GroupBox("SSL/TLS Version") {
                VStack(alignment: .leading, spacing: 12) {
                    Picker("Version", selection: $viewModel.options.sslVersion) {
                        ForEach(SSLVersion.allCases) { version in
                            Text(version.rawValue).tag(version)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if let flag = viewModel.options.sslVersion.curlFlag {
                        Text(flag)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Security Options
            GroupBox("Security Options") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Toggle("Insecure (Skip SSL verification)", isOn: $viewModel.options.insecure)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("-k, --insecure")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if viewModel.options.insecure {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Warning: This option makes the connection insecure!")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Toggle("Allow BEAST vulnerability", isOn: $viewModel.options.sslAllowBeast)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("--ssl-allow-beast")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("Skip certificate revocation check", isOn: $viewModel.options.sslNoRevoke)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("--ssl-no-revoke")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Client Certificate
            GroupBox("Client Certificate") {
                VStack(alignment: .leading, spacing: 12) {
                    // Certificate
                    HStack {
                        Text("Certificate:")
                            .frame(width: 80, alignment: .trailing)
                        TextField("Path to certificate file", text: $viewModel.options.certPath)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                        Button("Browse") {
                            browseCert()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 80)
                        Text("--cert <certificate[:password]>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Picker("Type:", selection: $viewModel.options.certType) {
                            Text("PEM").tag("PEM")
                            Text("DER").tag("DER")
                            Text("ENG").tag("ENG")
                            Text("P12").tag("P12")
                        }
                        .frame(width: 100)
                    }
                    
                    Divider()
                    
                    // Private Key
                    HStack {
                        Text("Private Key:")
                            .frame(width: 80, alignment: .trailing)
                        TextField("Path to private key file", text: $viewModel.options.keyPath)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                        Button("Browse") {
                            browseKey()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 80)
                        Text("--key <key>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Picker("Type:", selection: $viewModel.options.keyType) {
                            Text("PEM").tag("PEM")
                            Text("DER").tag("DER")
                            Text("ENG").tag("ENG")
                        }
                        .frame(width: 100)
                    }
                    
                    Divider()
                    
                    // Key Password
                    HStack {
                        Text("Key Password:")
                            .frame(width: 80, alignment: .trailing)
                        SecureField("Password for private key", text: $viewModel.options.keyPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 80)
                        Text("--pass <phrase>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // CA Certificate
            GroupBox("CA Certificate") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("CA Cert:")
                            .frame(width: 80, alignment: .trailing)
                        TextField("CA certificate bundle", text: $viewModel.options.cacertPath)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                        Button("Browse") {
                            browseCACert()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 80)
                        Text("--cacert <file>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("CA Path:")
                            .frame(width: 80, alignment: .trailing)
                        TextField("Directory with CA certificates", text: $viewModel.options.caPath)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                        Button("Browse") {
                            browseCAPath()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 80)
                        Text("--capath <dir>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Additional SSL Options
            GroupBox("Additional SSL Options") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("CRL File:")
                            .frame(width: 100, alignment: .trailing)
                        TextField("Certificate revocation list", text: $viewModel.options.crlFile)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 100)
                        Text("--crlfile <file>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Pinned Key:")
                            .frame(width: 100, alignment: .trailing)
                        TextField("SHA256 hash or path to public key", text: $viewModel.options.pinnedPublicKey)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 100)
                        Text("--pinnedpubkey <hashes>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
        }
    }
    
    // MARK: - File Browsers
    private func browseCert() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.options.certPath = url.path
            viewModel.objectWillChange.send()
        }
    }
    
    private func browseKey() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.options.keyPath = url.path
            viewModel.objectWillChange.send()
        }
    }
    
    private func browseCACert() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.options.cacertPath = url.path
            viewModel.objectWillChange.send()
        }
    }
    
    private func browseCAPath() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.options.caPath = url.path
            viewModel.objectWillChange.send()
        }
    }
}

#Preview {
    SSLView()
        .environmentObject(RequestViewModel())
        .padding()
        .frame(width: 600, height: 900)
}
