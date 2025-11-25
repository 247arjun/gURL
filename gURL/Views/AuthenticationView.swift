import SwiftUI

struct AuthenticationView: View {
    @EnvironmentObject var viewModel: RequestViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Auth Type Selector
            GroupBox("Authentication Type") {
                VStack(alignment: .leading, spacing: 12) {
                    Picker("Type", selection: $viewModel.options.authType) {
                        ForEach(AuthenticationType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 200)
                    
                    if let flag = viewModel.options.authType.curlFlag {
                        Text(flag)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            // Auth Configuration
            switch viewModel.options.authType {
            case .none:
                noAuthView
            case .basic:
                basicAuthView
            case .bearer:
                bearerAuthView
            case .digest:
                digestAuthView
            case .ntlm:
                ntlmAuthView
            case .negotiate:
                negotiateAuthView
            case .awsSigv4:
                awsSigv4AuthView
            }
            
            Spacer()
        }
    }
    
    // MARK: - No Auth View
    private var noAuthView: some View {
        GroupBox {
            VStack {
                Image(systemName: "lock.open")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text("No authentication")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, minHeight: 150)
        }
    }
    
    // MARK: - Basic Auth View
    private var basicAuthView: some View {
        GroupBox("Basic Authentication") {
            VStack(alignment: .leading, spacing: 12) {
                Text("-u, --user <user:password>")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Username:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("Username", text: $viewModel.options.authUsername)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Password:")
                        .frame(width: 80, alignment: .trailing)
                    SecureField("Password", text: $viewModel.options.authPassword)
                        .textFieldStyle(.roundedBorder)
                }
                
                if !viewModel.options.authUsername.isEmpty {
                    Text("Header: Authorization: Basic \(encodedBasicAuth)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textSelection(.enabled)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Bearer Auth View
    private var bearerAuthView: some View {
        GroupBox("Bearer Token") {
            VStack(alignment: .leading, spacing: 12) {
                Text("Sends: -H \"Authorization: Bearer <token>\"")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Token:")
                        .frame(width: 80, alignment: .trailing)
                    SecureField("Bearer Token", text: $viewModel.options.bearerToken)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                }
                
                if !viewModel.options.bearerToken.isEmpty {
                    Text("Header: Authorization: Bearer \(String(viewModel.options.bearerToken.prefix(20)))...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Digest Auth View
    private var digestAuthView: some View {
        GroupBox("Digest Authentication") {
            VStack(alignment: .leading, spacing: 12) {
                Text("--digest -u <user:password>")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Username:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("Username", text: $viewModel.options.authUsername)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Password:")
                        .frame(width: 80, alignment: .trailing)
                    SecureField("Password", text: $viewModel.options.authPassword)
                        .textFieldStyle(.roundedBorder)
                }
                
                Text("Uses HTTP Digest authentication. More secure than Basic as password is not sent in clear text.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - NTLM Auth View
    private var ntlmAuthView: some View {
        GroupBox("NTLM Authentication") {
            VStack(alignment: .leading, spacing: 12) {
                Text("--ntlm -u <user:password>")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Username:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("DOMAIN\\Username or Username", text: $viewModel.options.authUsername)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Password:")
                        .frame(width: 80, alignment: .trailing)
                    SecureField("Password", text: $viewModel.options.authPassword)
                        .textFieldStyle(.roundedBorder)
                }
                
                Text("Used for Windows authentication. Username can include domain as DOMAIN\\user")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Negotiate Auth View
    private var negotiateAuthView: some View {
        GroupBox("Negotiate (SPNEGO) Authentication") {
            VStack(alignment: .leading, spacing: 12) {
                Text("--negotiate -u :")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Username:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("Username (optional)", text: $viewModel.options.authUsername)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Password:")
                        .frame(width: 80, alignment: .trailing)
                    SecureField("Password (optional)", text: $viewModel.options.authPassword)
                        .textFieldStyle(.roundedBorder)
                }
                
                Text("Uses SPNEGO negotiation. Leave credentials empty to use current Kerberos ticket.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - AWS Sigv4 Auth View
    private var awsSigv4AuthView: some View {
        GroupBox("AWS Signature Version 4") {
            VStack(alignment: .leading, spacing: 12) {
                Text("--aws-sigv4 <provider1[:provider2[:region[:service]]]>")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Provider:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("aws:amz", text: $viewModel.options.awsProvider)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Region:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("us-east-1", text: $viewModel.options.awsRegion)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Service:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("s3, execute-api, etc.", text: $viewModel.options.awsService)
                        .textFieldStyle(.roundedBorder)
                }
                
                Divider()
                
                Text("Credentials (Access Key / Secret Key)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text("Access Key:")
                        .frame(width: 80, alignment: .trailing)
                    TextField("AWS Access Key ID", text: $viewModel.options.authUsername)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Secret Key:")
                        .frame(width: 80, alignment: .trailing)
                    SecureField("AWS Secret Access Key", text: $viewModel.options.authPassword)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Helpers
    private var encodedBasicAuth: String {
        let credentials = "\(viewModel.options.authUsername):\(viewModel.options.authPassword)"
        return Data(credentials.utf8).base64EncodedString()
    }
}

#Preview {
    AuthenticationView()
        .environmentObject(RequestViewModel())
        .padding()
        .frame(width: 500, height: 600)
}
