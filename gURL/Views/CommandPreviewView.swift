import SwiftUI

struct CommandPreviewView: View {
    @EnvironmentObject var viewModel: RequestViewModel
    @State private var showCopied = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("cURL Command")
                    .font(.headline)
                
                Spacer()
                
                Button(action: copyCommand) {
                    HStack(spacing: 4) {
                        Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                        Text(showCopied ? "Copied!" : "Copy")
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            ScrollView(.horizontal, showsIndicators: true) {
                Text(viewModel.generatedCommand)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color(nsColor: .textBackgroundColor))
            .cornerRadius(6)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private func copyCommand() {
        viewModel.copyCommand()
        showCopied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopied = false
        }
    }
}

#Preview {
    CommandPreviewView()
        .environmentObject(RequestViewModel())
        .frame(width: 600, height: 120)
}
