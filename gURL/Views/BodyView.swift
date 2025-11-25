import SwiftUI

struct BodyView: View {
    @EnvironmentObject var viewModel: RequestViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Body Type Selector
            GroupBox("Body Type") {
                Picker("Body Type", selection: $viewModel.options.bodyType) {
                    ForEach(BodyType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 8)
            }
            
            // Body Content
            switch viewModel.options.bodyType {
            case .none:
                emptyBodyView
            case .raw:
                rawBodyView
            case .formData:
                formDataView
            case .urlEncoded:
                urlEncodedView
            case .binary:
                binaryView
            }
            
            Spacer()
        }
    }
    
    // MARK: - Empty Body View
    private var emptyBodyView: some View {
        GroupBox {
            VStack {
                Image(systemName: "doc.text")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text("No body content")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 200)
        }
    }
    
    // MARK: - Raw Body View
    private var rawBodyView: some View {
        GroupBox("Raw Body") {
            VStack(alignment: .leading, spacing: 12) {
                // Content Type Selector
                HStack {
                    Text("Content Type:")
                        .foregroundColor(.secondary)
                    
                    Picker("", selection: $viewModel.options.rawBodyType) {
                        ForEach(RawBodyType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .frame(width: 150)
                    
                    Spacer()
                    
                    Text(viewModel.options.rawBodyType.contentType)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Text("-d, --data <data>")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Text Editor
                TextEditor(text: $viewModel.options.rawBody)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 200)
                    .border(Color.secondary.opacity(0.3))
                
                // Quick Templates
                HStack {
                    Button("JSON Example") {
                        viewModel.options.rawBody = """
                        {
                            "key": "value",
                            "number": 123,
                            "boolean": true,
                            "array": [1, 2, 3],
                            "nested": {
                                "inner": "value"
                            }
                        }
                        """
                        viewModel.options.rawBodyType = .json
                        viewModel.objectWillChange.send()
                    }
                    
                    Button("XML Example") {
                        viewModel.options.rawBody = """
                        <?xml version="1.0" encoding="UTF-8"?>
                        <root>
                            <element attribute="value">Content</element>
                        </root>
                        """
                        viewModel.options.rawBodyType = .xml
                        viewModel.objectWillChange.send()
                    }
                    
                    Spacer()
                    
                    Button("Format JSON") {
                        formatJSON()
                        viewModel.objectWillChange.send()
                    }
                    .disabled(viewModel.options.rawBodyType != .json)
                    
                    Button("Clear") {
                        viewModel.options.rawBody = ""
                        viewModel.objectWillChange.send()
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Form Data View
    private var formDataView: some View {
        GroupBox("Form Data (multipart/form-data)") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("-F, --form <name=content>")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: addFormDataItem) {
                        Label("Add Field", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                }
                
                ForEach($viewModel.options.formData) { $item in
                    HStack(spacing: 8) {
                        Toggle("", isOn: $item.isEnabled)
                            .toggleStyle(.checkbox)
                            .labelsHidden()
                        
                        TextField("Name", text: $item.key)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                        
                        Toggle("File", isOn: $item.isFile)
                            .toggleStyle(.checkbox)
                        
                        if item.isFile {
                            TextField("File Path", text: $item.filePath)
                                .textFieldStyle(.roundedBorder)
                            
                            Button("Browse") {
                                browseFile(for: item)
                            }
                            .buttonStyle(.bordered)
                        } else {
                            TextField("Value", text: $item.value)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        TextField("Content-Type", text: $item.contentType)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                            .help("Optional content type")
                        
                        Button(action: { removeFormDataItem(item) }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - URL Encoded View
    private var urlEncodedView: some View {
        GroupBox("URL Encoded (application/x-www-form-urlencoded)") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("--data-urlencode <data>")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: addUrlEncodedItem) {
                        Label("Add Field", systemImage: "plus")
                    }
                    .buttonStyle(.bordered)
                }
                
                ForEach($viewModel.options.urlEncodedData) { $item in
                    HStack(spacing: 8) {
                        Toggle("", isOn: $item.isEnabled)
                            .toggleStyle(.checkbox)
                            .labelsHidden()
                        
                        TextField("Key", text: $item.key)
                            .textFieldStyle(.roundedBorder)
                        
                        Text("=")
                            .foregroundColor(.secondary)
                        
                        TextField("Value", text: $item.value)
                            .textFieldStyle(.roundedBorder)
                        
                        Button(action: { removeUrlEncodedItem(item) }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Binary View
    private var binaryView: some View {
        GroupBox("Binary File") {
            VStack(alignment: .leading, spacing: 12) {
                Text("--data-binary <data>")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    TextField("File Path", text: $viewModel.options.binaryFilePath)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                    
                    Button("Browse...") {
                        browseBinaryFile()
                    }
                    .buttonStyle(.bordered)
                }
                
                if !viewModel.options.binaryFilePath.isEmpty {
                    HStack {
                        Image(systemName: "doc.fill")
                        Text(URL(fileURLWithPath: viewModel.options.binaryFilePath).lastPathComponent)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Helper Methods
    private func formatJSON() {
        guard let data = viewModel.options.rawBody.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return
        }
        viewModel.options.rawBody = prettyString
    }
    
    private func addFormDataItem() {
        viewModel.options.formData.append(FormDataItem())
        viewModel.objectWillChange.send()
    }
    
    private func removeFormDataItem(_ item: FormDataItem) {
        viewModel.options.formData.removeAll { $0.id == item.id }
        if viewModel.options.formData.isEmpty {
            viewModel.options.formData.append(FormDataItem())
        }
        viewModel.objectWillChange.send()
    }
    
    private func addUrlEncodedItem() {
        viewModel.options.urlEncodedData.append(KeyValuePair())
        viewModel.objectWillChange.send()
    }
    
    private func removeUrlEncodedItem(_ item: KeyValuePair) {
        viewModel.options.urlEncodedData.removeAll { $0.id == item.id }
        if viewModel.options.urlEncodedData.isEmpty {
            viewModel.options.urlEncodedData.append(KeyValuePair())
        }
        viewModel.objectWillChange.send()
    }
    
    private func browseFile(for item: FormDataItem) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK, let url = panel.url {
            if let index = viewModel.options.formData.firstIndex(where: { $0.id == item.id }) {
                viewModel.options.formData[index].filePath = url.path
            }
            viewModel.objectWillChange.send()
        }
    }
    
    private func browseBinaryFile() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.options.binaryFilePath = url.path
            viewModel.objectWillChange.send()
        }
    }
}

#Preview {
    BodyView()
        .environmentObject(RequestViewModel())
        .padding()
        .frame(width: 600, height: 700)
}
