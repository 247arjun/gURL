import SwiftUI

struct AdvancedOptionsView: View {
    @EnvironmentObject var viewModel: RequestViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Timeouts
            GroupBox("Timeouts & Limits") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Connect Timeout:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("seconds", text: $viewModel.options.connectTimeout)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        Text("--connect-timeout <seconds>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Max Time:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("seconds", text: $viewModel.options.maxTime)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        Text("-m, --max-time <seconds>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Limit Rate:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("e.g., 100K, 1M", text: $viewModel.options.limitRate)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        Text("--limit-rate <speed>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Speed Limit:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("bytes/sec", text: $viewModel.options.speedLimit)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        Text("-Y, --speed-limit <speed>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Speed Time:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("seconds", text: $viewModel.options.speedTime)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        Text("-y, --speed-time <seconds>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Retry Options
            GroupBox("Retry Options") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Retry Count:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("number", text: $viewModel.options.retryCount)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        Text("--retry <num>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Retry Delay:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("seconds", text: $viewModel.options.retryDelay)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        Text("--retry-delay <seconds>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Retry Max Time:")
                            .frame(width: 120, alignment: .trailing)
                        TextField("seconds", text: $viewModel.options.retryMaxTime)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        Text("--retry-max-time <seconds>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("Retry All Errors", isOn: $viewModel.options.retryAllErrors)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("--retry-all-errors")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Redirect Options
            GroupBox("Redirect Options") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Toggle("Follow Redirects", isOn: $viewModel.options.followRedirects)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("-L, --location")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if viewModel.options.followRedirects {
                        HStack {
                            Text("Max Redirects:")
                                .frame(width: 120, alignment: .trailing)
                            TextField("number", text: $viewModel.options.maxRedirects)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                            Text("--max-redirs <num>")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Toggle("POST on Redirect (301/302/303)", isOn: $viewModel.options.postRedirect)
                                .toggleStyle(.checkbox)
                            Spacer()
                            Text("--post301/302/303")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // DNS Options
            GroupBox("DNS Options") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("DNS Servers:")
                            .frame(width: 100, alignment: .trailing)
                        TextField("IP addresses (comma separated)", text: $viewModel.options.dnsServers)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 100)
                        Text("--dns-servers <addresses>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("DNS Interface:")
                            .frame(width: 100, alignment: .trailing)
                        TextField("interface name", text: $viewModel.options.dnsInterface)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 100)
                        Text("--dns-interface <interface>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Network Interface
            GroupBox("Network Interface") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Interface:")
                            .frame(width: 100, alignment: .trailing)
                        TextField("interface name or IP", text: $viewModel.options.interface)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 100)
                        Text("--interface <name>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Local Port:")
                            .frame(width: 100, alignment: .trailing)
                        TextField("port or range", text: $viewModel.options.localPort)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 150)
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 100)
                        Text("--local-port <num/range>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Misc Options
            GroupBox("Miscellaneous") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Range:")
                            .frame(width: 100, alignment: .trailing)
                        TextField("e.g., 0-499, 500-999", text: $viewModel.options.range)
                            .textFieldStyle(.roundedBorder)
                        Text("-r, --range <range>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Continue At:")
                            .frame(width: 100, alignment: .trailing)
                        TextField("offset or -", text: $viewModel.options.continueAt)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        Text("-C, --continue-at <offset>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Toggle("Create Directories", isOn: $viewModel.options.createDirs)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("--create-dirs")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("Convert to CRLF", isOn: $viewModel.options.crlf)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("--crlf")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("Path As Is", isOn: $viewModel.options.pathAsIs)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("--path-as-is")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("No Buffer", isOn: $viewModel.options.noBuffer)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("-N, --no-buffer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("No Session ID", isOn: $viewModel.options.noSessionId)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("--no-sessionid")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("Remote Time", isOn: $viewModel.options.remoteTime)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("-R, --remote-time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("Parallel", isOn: $viewModel.options.parallel)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("-Z, --parallel")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if viewModel.options.parallel {
                        HStack {
                            Text("Parallel Max:")
                                .frame(width: 100, alignment: .trailing)
                            TextField("number", text: $viewModel.options.parallelMax)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 100)
                            Text("--parallel-max <num>")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
        }
    }
}

#Preview {
    AdvancedOptionsView()
        .environmentObject(RequestViewModel())
        .padding()
        .frame(width: 600, height: 1000)
}
