import SwiftUI

struct ResponseDiffView: View {
    @EnvironmentObject var tabManager: TabManager
    @Environment(\.dismiss) private var dismiss
    @State private var diffMode: DiffMode = .sideBySide
    @State private var showOnlyDifferences = false
    
    enum DiffMode: String, CaseIterable {
        case sideBySide = "Side by Side"
        case unified = "Unified"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            Divider()
            
            // Content
            if tabManager.diffLeftResponse == nil && tabManager.diffRightResponse == nil {
                emptyState
            } else {
                switch diffMode {
                case .sideBySide:
                    sideBySideView
                case .unified:
                    unifiedView
                }
            }
        }
        .frame(minWidth: 900, minHeight: 600)
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Text("Response Diff")
                .font(.headline)
            
            Spacer()
            
            Picker("Mode", selection: $diffMode) {
                ForEach(DiffMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 200)
            
            Toggle("Show only differences", isOn: $showOnlyDifferences)
                .toggleStyle(.checkbox)
            
            Spacer()
            
            Button("Clear") {
                tabManager.clearDiff()
            }
            .buttonStyle(.bordered)
            
            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No responses to compare")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Use 'Set as Diff Left' and 'Set as Diff Right' from the Response menu\nor right-click on history items to select responses to compare.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Side by Side View
    private var sideBySideView: some View {
        HSplitView {
            // Left Response
            VStack(spacing: 0) {
                responseHeader(title: "Left", response: tabManager.diffLeftResponse, color: .blue)
                Divider()
                responseBody(tabManager.diffLeftResponse)
            }
            
            // Right Response
            VStack(spacing: 0) {
                responseHeader(title: "Right", response: tabManager.diffRightResponse, color: .green)
                Divider()
                responseBody(tabManager.diffRightResponse)
            }
        }
    }
    
    // MARK: - Unified View
    private var unifiedView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let left = tabManager.diffLeftResponse, let right = tabManager.diffRightResponse {
                    let leftLines = left.body.components(separatedBy: "\n")
                    let rightLines = right.body.components(separatedBy: "\n")
                    let diff = computeDiff(left: leftLines, right: rightLines)
                    
                    ForEach(Array(diff.enumerated()), id: \.offset) { index, line in
                        if !showOnlyDifferences || line.type != .unchanged {
                            HStack(spacing: 8) {
                                Text(line.type.symbol)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(line.type.color)
                                    .frame(width: 20)
                                
                                Text(line.content)
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(line.type.color)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 2)
                            .background(line.type.backgroundColor)
                        }
                    }
                } else {
                    Text("Select two responses to compare")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding()
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
    
    // MARK: - Helpers
    private func responseHeader(title: String, response: CurlResponse?, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            if let response = response {
                Text(response.statusText)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(response.formattedDuration)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(response.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Not set")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(color.opacity(0.1))
    }
    
    private func responseBody(_ response: CurlResponse?) -> some View {
        ScrollView {
            if let response = response {
                Text(formatBody(response.body))
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            } else {
                VStack {
                    Image(systemName: "doc.text")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text("No response selected")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color(nsColor: .textBackgroundColor))
    }
    
    private func formatBody(_ body: String) -> String {
        if let data = body.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }
        return body
    }
    
    // MARK: - Diff Computation
    private func computeDiff(left: [String], right: [String]) -> [DiffLine] {
        var result: [DiffLine] = []
        
        let maxLines = max(left.count, right.count)
        var leftIndex = 0
        var rightIndex = 0
        
        // Simple line-by-line diff (for more sophisticated diff, consider using a proper diff algorithm)
        while leftIndex < left.count || rightIndex < right.count {
            let leftLine = leftIndex < left.count ? left[leftIndex] : nil
            let rightLine = rightIndex < right.count ? right[rightIndex] : nil
            
            if leftLine == rightLine {
                if let line = leftLine {
                    result.append(DiffLine(content: line, type: .unchanged))
                }
                leftIndex += 1
                rightIndex += 1
            } else if let leftLine = leftLine, rightLine == nil {
                result.append(DiffLine(content: leftLine, type: .removed))
                leftIndex += 1
            } else if let rightLine = rightLine, leftLine == nil {
                result.append(DiffLine(content: rightLine, type: .added))
                rightIndex += 1
            } else if let leftLine = leftLine, let rightLine = rightLine {
                // Check if lines appear later in the other array
                let leftInRight = right.dropFirst(rightIndex).contains(leftLine)
                let rightInLeft = left.dropFirst(leftIndex).contains(rightLine)
                
                if leftInRight && !rightInLeft {
                    result.append(DiffLine(content: rightLine, type: .added))
                    rightIndex += 1
                } else if rightInLeft && !leftInRight {
                    result.append(DiffLine(content: leftLine, type: .removed))
                    leftIndex += 1
                } else {
                    result.append(DiffLine(content: leftLine, type: .removed))
                    result.append(DiffLine(content: rightLine, type: .added))
                    leftIndex += 1
                    rightIndex += 1
                }
            }
        }
        
        return result
    }
}

// MARK: - Diff Line Model
struct DiffLine {
    let content: String
    let type: DiffType
    
    enum DiffType {
        case unchanged
        case added
        case removed
        
        var symbol: String {
            switch self {
            case .unchanged: return " "
            case .added: return "+"
            case .removed: return "-"
            }
        }
        
        var color: Color {
            switch self {
            case .unchanged: return .primary
            case .added: return .green
            case .removed: return .red
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .unchanged: return .clear
            case .added: return .green.opacity(0.1)
            case .removed: return .red.opacity(0.1)
            }
        }
    }
}

#Preview {
    ResponseDiffView()
        .environmentObject(TabManager())
}
