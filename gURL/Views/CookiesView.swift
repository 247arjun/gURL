import SwiftUI

struct CookiesView: View {
    @EnvironmentObject var viewModel: RequestViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Manual Cookies
            GroupBox {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Cookies")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: addCookie) {
                            Label("Add Cookie", systemImage: "plus")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Text("-b, --cookie <data|filename>")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    ForEach($viewModel.options.cookies) { $cookie in
                        HStack(spacing: 8) {
                            Toggle("", isOn: $cookie.isEnabled)
                                .toggleStyle(.checkbox)
                                .labelsHidden()
                            
                            TextField("Name", text: $cookie.name)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                            
                            Text("=")
                                .foregroundColor(.secondary)
                            
                            TextField("Value", text: $cookie.value)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("Domain", text: $cookie.domain)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 120)
                                .help("Optional domain")
                            
                            TextField("Path", text: $cookie.path)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 60)
                                .help("Path (default: /)")
                            
                            Button(action: { removeCookie(cookie) }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Cookie File
            GroupBox("Cookie File") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Read cookies from a Netscape cookie file")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("-b, --cookie")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 80, alignment: .leading)
                        
                        TextField("Cookie file path", text: $viewModel.options.cookieFile)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                        
                        Button("Browse...") {
                            browseCookieFile()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Cookie Jar
            GroupBox("Cookie Jar") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Save cookies to file after request completes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("-c, --cookie-jar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 100, alignment: .leading)
                        
                        TextField("Output cookie jar path", text: $viewModel.options.cookieJar)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                        
                        Button("Browse...") {
                            browseCookieJar()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Common Cookies Quick Add
            GroupBox("Quick Add") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add common cookie templates")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Button("Session ID") {
                            addQuickCookie(name: "sessionid", value: "")
                        }
                        Button("CSRF Token") {
                            addQuickCookie(name: "csrftoken", value: "")
                        }
                        Button("Auth Token") {
                            addQuickCookie(name: "auth_token", value: "")
                        }
                        Button("JWT") {
                            addQuickCookie(name: "jwt", value: "")
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
        }
    }
    
    private func addCookie() {
        viewModel.options.cookies.append(CookieItem())
        viewModel.objectWillChange.send()
    }
    
    private func removeCookie(_ cookie: CookieItem) {
        viewModel.options.cookies.removeAll { $0.id == cookie.id }
        if viewModel.options.cookies.isEmpty {
            viewModel.options.cookies.append(CookieItem())
        }
        viewModel.objectWillChange.send()
    }
    
    private func addQuickCookie(name: String, value: String) {
        if let emptyIndex = viewModel.options.cookies.firstIndex(where: { $0.name.isEmpty && $0.value.isEmpty }) {
            viewModel.options.cookies[emptyIndex] = CookieItem(name: name, value: value)
        } else {
            viewModel.options.cookies.append(CookieItem(name: name, value: value))
        }
        viewModel.objectWillChange.send()
    }
    
    private func browseCookieFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.text, .data]
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.options.cookieFile = url.path
            viewModel.objectWillChange.send()
        }
    }
    
    private func browseCookieJar() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.text]
        panel.nameFieldStringValue = "cookies.txt"
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.options.cookieJar = url.path
            viewModel.objectWillChange.send()
        }
    }
}

#Preview {
    CookiesView()
        .environmentObject(RequestViewModel())
        .padding()
        .frame(width: 700, height: 600)
}
