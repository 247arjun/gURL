import SwiftUI

struct OutputOptionsView: View {
    @EnvironmentObject var viewModel: RequestViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Verbosity
            GroupBox("Verbosity") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Toggle("Verbose", isOn: $viewModel.options.verbose)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("-v, --verbose")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("Makes curl verbose during operation. Useful for debugging.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    HStack {
                        Toggle("Silent", isOn: $viewModel.options.silent)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("-s, --silent")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("Show Error (with Silent)", isOn: $viewModel.options.showError)
                            .toggleStyle(.checkbox)
                            .disabled(!viewModel.options.silent)
                        Spacer()
                        Text("-S, --show-error")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Response Output
            GroupBox("Response Output") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Toggle("Include Response Headers", isOn: $viewModel.options.includeHeaders)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("-i, --include")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("Headers Only (HEAD request)", isOn: $viewModel.options.headOnly)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("-I, --head")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("Raw Output", isOn: $viewModel.options.rawOutput)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("--raw")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // File Output
            GroupBox("File Output") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Output File:")
                            .frame(width: 100, alignment: .trailing)
                        TextField("Path to save response", text: $viewModel.options.outputFile)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                        Button("Browse") {
                            browseOutputFile()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 100)
                        Text("-o, --output <file>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Dump Headers:")
                            .frame(width: 100, alignment: .trailing)
                        TextField("Path to save headers", text: $viewModel.options.dumpHeader)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                        Button("Browse") {
                            browseDumpHeader()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 100)
                        Text("-D, --dump-header <filename>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Write Out
            GroupBox("Write Out Format") {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Custom output format string")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("e.g., %{http_code} %{time_total}", text: $viewModel.options.writeOut)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                    
                    Text("-w, --write-out <format>")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    Text("Available variables:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
                        ForEach(writeOutVariables, id: \.self) { variable in
                            Button(variable) {
                                if viewModel.options.writeOut.isEmpty {
                                    viewModel.options.writeOut = "%{\(variable)}"
                                } else {
                                    viewModel.options.writeOut += " %{\(variable)}"
                                }
                                viewModel.objectWillChange.send()
                            }
                            .buttonStyle(.bordered)
                            .font(.system(size: 10, design: .monospaced))
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Trace Options
            GroupBox("Trace & Debug") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Trace File:")
                            .frame(width: 100, alignment: .trailing)
                        TextField("Binary trace output", text: $viewModel.options.trace)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 100)
                        Text("--trace <file>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Trace ASCII:")
                            .frame(width: 100, alignment: .trailing)
                        TextField("ASCII trace output", text: $viewModel.options.traceAscii)
                            .textFieldStyle(.roundedBorder)
                            .font(.system(.body, design: .monospaced))
                    }
                    
                    HStack {
                        Text("")
                            .frame(width: 100)
                        Text("--trace-ascii <file>")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("Trace Time", isOn: $viewModel.options.traceTime)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("--trace-time")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Progress & Error
            GroupBox("Progress & Error Handling") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Toggle("Progress Bar", isOn: $viewModel.options.progressBar)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("-#, --progress-bar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("Fail on HTTP Error", isOn: $viewModel.options.failOnError)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("-f, --fail")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Toggle("Fail Early", isOn: $viewModel.options.failEarly)
                            .toggleStyle(.checkbox)
                        Spacer()
                        Text("--fail-early")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Spacer()
        }
    }
    
    private let writeOutVariables = [
        "http_code",
        "http_version",
        "time_total",
        "time_namelookup",
        "time_connect",
        "time_appconnect",
        "time_pretransfer",
        "time_starttransfer",
        "size_download",
        "size_upload",
        "size_header",
        "speed_download",
        "speed_upload",
        "content_type",
        "num_connects",
        "redirect_url",
        "ssl_verify_result",
        "url_effective"
    ]
    
    private func browseOutputFile() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.data]
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.options.outputFile = url.path
            viewModel.objectWillChange.send()
        }
    }
    
    private func browseDumpHeader() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.text]
        panel.nameFieldStringValue = "headers.txt"
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.options.dumpHeader = url.path
            viewModel.objectWillChange.send()
        }
    }
}

#Preview {
    OutputOptionsView()
        .environmentObject(RequestViewModel())
        .padding()
        .frame(width: 600, height: 900)
}
