import Foundation

class CurlService {
    @MainActor static let shared = CurlService()
    
    private var currentTask: Process?
    
    // MARK: - Command Generation
    func generateCommand(from options: CurlOptions) -> String {
        var args: [String] = ["curl"]
        
        // HTTP Method (if not GET or if custom)
        if options.method != .GET || !options.customRequest.isEmpty {
            if !options.customRequest.isEmpty {
                args.append("-X")
                args.append(options.customRequest)
            } else {
                args.append("-X")
                args.append(options.method.rawValue)
            }
        }
        
        // HTTP Version
        if let flag = options.httpVersion.curlFlag {
            args.append(flag)
        }
        
        // Headers
        for header in options.headers where header.isEnabled && !header.key.isEmpty {
            args.append("-H")
            args.append(escapeForShell("\(header.key): \(header.value)"))
        }
        
        // User Agent
        if !options.userAgent.isEmpty {
            args.append("-A")
            args.append(escapeForShell(options.userAgent))
        }
        
        // Referer
        if !options.referer.isEmpty {
            if options.autoReferer {
                args.append("-e")
                args.append(escapeForShell("\(options.referer);auto"))
            } else {
                args.append("-e")
                args.append(escapeForShell(options.referer))
            }
        } else if options.autoReferer {
            args.append("-e")
            args.append(";auto")
        }
        
        // Body
        args.append(contentsOf: generateBodyArgs(from: options))
        
        // Authentication
        args.append(contentsOf: generateAuthArgs(from: options))
        
        // SSL/TLS
        args.append(contentsOf: generateSSLArgs(from: options))
        
        // Proxy
        args.append(contentsOf: generateProxyArgs(from: options))
        
        // Cookies
        args.append(contentsOf: generateCookieArgs(from: options))
        
        // Connection options
        args.append(contentsOf: generateConnectionArgs(from: options))
        
        // Redirect options
        args.append(contentsOf: generateRedirectArgs(from: options))
        
        // Output options
        args.append(contentsOf: generateOutputArgs(from: options))
        
        // DNS options
        args.append(contentsOf: generateDNSArgs(from: options))
        
        // Network Interface
        args.append(contentsOf: generateNetworkArgs(from: options))
        
        // Advanced options
        args.append(contentsOf: generateAdvancedArgs(from: options))
        
        // URL (must be last)
        if !options.url.isEmpty {
            args.append(escapeForShell(options.url))
        }
        
        return args.joined(separator: " ")
    }
    
    // MARK: - Body Arguments
    private func generateBodyArgs(from options: CurlOptions) -> [String] {
        var args: [String] = []
        
        switch options.bodyType {
        case .none:
            break
            
        case .raw:
            if !options.rawBody.isEmpty {
                // Add Content-Type header if not already present
                let hasContentType = options.headers.contains { $0.key.lowercased() == "content-type" && $0.isEnabled }
                if !hasContentType {
                    args.append("-H")
                    args.append("Content-Type: \(options.rawBodyType.contentType)")
                }
                args.append("-d")
                args.append(escapeForShell(options.rawBody))
            }
            
        case .formData:
            for item in options.formData where item.isEnabled && !item.key.isEmpty {
                args.append("-F")
                if item.isFile {
                    var formValue = "\(item.key)=@\(item.filePath)"
                    if !item.contentType.isEmpty {
                        formValue += ";type=\(item.contentType)"
                    }
                    args.append(escapeForShell(formValue))
                } else {
                    args.append(escapeForShell("\(item.key)=\(item.value)"))
                }
            }
            
        case .urlEncoded:
            for item in options.urlEncodedData where item.isEnabled && !item.key.isEmpty {
                args.append("--data-urlencode")
                args.append(escapeForShell("\(item.key)=\(item.value)"))
            }
            
        case .binary:
            if !options.binaryFilePath.isEmpty {
                args.append("--data-binary")
                args.append("@\(escapeForShell(options.binaryFilePath))")
            }
        }
        
        return args
    }
    
    // MARK: - Authentication Arguments
    private func generateAuthArgs(from options: CurlOptions) -> [String] {
        var args: [String] = []
        
        switch options.authType {
        case .none:
            break
            
        case .basic:
            args.append("--basic")
            if !options.authUsername.isEmpty {
                args.append("-u")
                args.append(escapeForShell("\(options.authUsername):\(options.authPassword)"))
            }
            
        case .bearer:
            if !options.bearerToken.isEmpty {
                args.append("-H")
                args.append(escapeForShell("Authorization: Bearer \(options.bearerToken)"))
            }
            
        case .digest:
            args.append("--digest")
            if !options.authUsername.isEmpty {
                args.append("-u")
                args.append(escapeForShell("\(options.authUsername):\(options.authPassword)"))
            }
            
        case .ntlm:
            args.append("--ntlm")
            if !options.authUsername.isEmpty {
                args.append("-u")
                args.append(escapeForShell("\(options.authUsername):\(options.authPassword)"))
            }
            
        case .negotiate:
            args.append("--negotiate")
            args.append("-u")
            if !options.authUsername.isEmpty {
                args.append(escapeForShell("\(options.authUsername):\(options.authPassword)"))
            } else {
                args.append(":")
            }
            
        case .awsSigv4:
            var sigv4Value = options.awsProvider
            if !options.awsRegion.isEmpty {
                sigv4Value += ":\(options.awsRegion)"
            }
            if !options.awsService.isEmpty {
                sigv4Value += ":\(options.awsService)"
            }
            args.append("--aws-sigv4")
            args.append(escapeForShell(sigv4Value))
            if !options.authUsername.isEmpty {
                args.append("-u")
                args.append(escapeForShell("\(options.authUsername):\(options.authPassword)"))
            }
        }
        
        return args
    }
    
    // MARK: - SSL Arguments
    private func generateSSLArgs(from options: CurlOptions) -> [String] {
        var args: [String] = []
        
        if options.insecure {
            args.append("-k")
        }
        
        if let flag = options.sslVersion.curlFlag {
            args.append(flag)
        }
        
        if !options.certPath.isEmpty {
            args.append("--cert")
            args.append(escapeForShell(options.certPath))
            if options.certType != "PEM" {
                args.append("--cert-type")
                args.append(options.certType)
            }
        }
        
        if !options.keyPath.isEmpty {
            args.append("--key")
            args.append(escapeForShell(options.keyPath))
            if options.keyType != "PEM" {
                args.append("--key-type")
                args.append(options.keyType)
            }
        }
        
        if !options.keyPassword.isEmpty {
            args.append("--pass")
            args.append(escapeForShell(options.keyPassword))
        }
        
        if !options.cacertPath.isEmpty {
            args.append("--cacert")
            args.append(escapeForShell(options.cacertPath))
        }
        
        if !options.caPath.isEmpty {
            args.append("--capath")
            args.append(escapeForShell(options.caPath))
        }
        
        if !options.crlFile.isEmpty {
            args.append("--crlfile")
            args.append(escapeForShell(options.crlFile))
        }
        
        if !options.pinnedPublicKey.isEmpty {
            args.append("--pinnedpubkey")
            args.append(escapeForShell(options.pinnedPublicKey))
        }
        
        if options.sslAllowBeast {
            args.append("--ssl-allow-beast")
        }
        
        if options.sslNoRevoke {
            args.append("--ssl-no-revoke")
        }
        
        return args
    }
    
    // MARK: - Proxy Arguments
    private func generateProxyArgs(from options: CurlOptions) -> [String] {
        var args: [String] = []
        
        if options.useProxy && !options.proxyHost.isEmpty {
            let proxyUrl = options.proxyPort.isEmpty ? options.proxyHost : "\(options.proxyHost):\(options.proxyPort)"
            
            switch options.proxyType {
            case .http, .https:
                args.append("-x")
                args.append(proxyUrl)
            case .socks4:
                args.append("--socks4")
                args.append(proxyUrl)
            case .socks4a:
                args.append("--socks4a")
                args.append(proxyUrl)
            case .socks5:
                args.append("--socks5")
                args.append(proxyUrl)
            case .socks5Hostname:
                args.append("--socks5-hostname")
                args.append(proxyUrl)
            }
            
            if !options.proxyUsername.isEmpty {
                args.append("-U")
                args.append(escapeForShell("\(options.proxyUsername):\(options.proxyPassword)"))
            }
            
            if options.proxyTunnel {
                args.append("-p")
            }
        }
        
        if !options.noProxy.isEmpty {
            args.append("--noproxy")
            args.append(escapeForShell(options.noProxy))
        }
        
        return args
    }
    
    // MARK: - Cookie Arguments
    private func generateCookieArgs(from options: CurlOptions) -> [String] {
        var args: [String] = []
        
        // Cookie file
        if !options.cookieFile.isEmpty {
            args.append("-b")
            args.append(escapeForShell(options.cookieFile))
        }
        
        // Manual cookies
        let enabledCookies = options.cookies.filter { $0.isEnabled && !$0.name.isEmpty }
        if !enabledCookies.isEmpty {
            let cookieString = enabledCookies.map { "\($0.name)=\($0.value)" }.joined(separator: "; ")
            args.append("-b")
            args.append(escapeForShell(cookieString))
        }
        
        // Cookie jar
        if !options.cookieJar.isEmpty {
            args.append("-c")
            args.append(escapeForShell(options.cookieJar))
        }
        
        return args
    }
    
    // MARK: - Connection Arguments
    private func generateConnectionArgs(from options: CurlOptions) -> [String] {
        var args: [String] = []
        
        if !options.connectTimeout.isEmpty {
            args.append("--connect-timeout")
            args.append(options.connectTimeout)
        }
        
        if !options.maxTime.isEmpty {
            args.append("-m")
            args.append(options.maxTime)
        }
        
        if !options.limitRate.isEmpty {
            args.append("--limit-rate")
            args.append(options.limitRate)
        }
        
        if !options.speedLimit.isEmpty {
            args.append("-Y")
            args.append(options.speedLimit)
        }
        
        if !options.speedTime.isEmpty {
            args.append("-y")
            args.append(options.speedTime)
        }
        
        if !options.retryCount.isEmpty {
            args.append("--retry")
            args.append(options.retryCount)
        }
        
        if !options.retryDelay.isEmpty {
            args.append("--retry-delay")
            args.append(options.retryDelay)
        }
        
        if !options.retryMaxTime.isEmpty {
            args.append("--retry-max-time")
            args.append(options.retryMaxTime)
        }
        
        if options.retryAllErrors {
            args.append("--retry-all-errors")
        }
        
        if options.compressed {
            args.append("--compressed")
        }
        
        if options.tcpNoDelay {
            args.append("--tcp-nodelay")
        }
        
        if options.tcpFastOpen {
            args.append("--tcp-fastopen")
        }
        
        if options.noKeepalive {
            args.append("--no-keepalive")
        }
        
        if !options.keepAliveTime.isEmpty {
            args.append("--keepalive-time")
            args.append(options.keepAliveTime)
        }
        
        return args
    }
    
    // MARK: - Redirect Arguments
    private func generateRedirectArgs(from options: CurlOptions) -> [String] {
        var args: [String] = []
        
        if options.followRedirects {
            args.append("-L")
            
            if !options.maxRedirects.isEmpty {
                args.append("--max-redirs")
                args.append(options.maxRedirects)
            }
            
            if options.postRedirect {
                args.append("--post301")
                args.append("--post302")
                args.append("--post303")
            }
        }
        
        return args
    }
    
    // MARK: - Output Arguments
    private func generateOutputArgs(from options: CurlOptions) -> [String] {
        var args: [String] = []
        
        if options.verbose {
            args.append("-v")
        }
        
        if options.silent {
            args.append("-s")
            if options.showError {
                args.append("-S")
            }
        }
        
        if options.includeHeaders {
            args.append("-i")
        }
        
        if options.headOnly {
            args.append("-I")
        }
        
        if !options.outputFile.isEmpty {
            args.append("-o")
            args.append(escapeForShell(options.outputFile))
        }
        
        if !options.dumpHeader.isEmpty {
            args.append("-D")
            args.append(escapeForShell(options.dumpHeader))
        }
        
        if !options.writeOut.isEmpty {
            args.append("-w")
            args.append(escapeForShell(options.writeOut))
        }
        
        if !options.trace.isEmpty {
            args.append("--trace")
            args.append(escapeForShell(options.trace))
        }
        
        if !options.traceAscii.isEmpty {
            args.append("--trace-ascii")
            args.append(escapeForShell(options.traceAscii))
        }
        
        if options.traceTime {
            args.append("--trace-time")
        }
        
        if options.progressBar {
            args.append("-#")
        }
        
        if options.failOnError {
            args.append("-f")
        }
        
        if options.failEarly {
            args.append("--fail-early")
        }
        
        if options.rawOutput {
            args.append("--raw")
        }
        
        return args
    }
    
    // MARK: - DNS Arguments
    private func generateDNSArgs(from options: CurlOptions) -> [String] {
        var args: [String] = []
        
        if !options.dnsServers.isEmpty {
            args.append("--dns-servers")
            args.append(escapeForShell(options.dnsServers))
        }
        
        if !options.dnsInterface.isEmpty {
            args.append("--dns-interface")
            args.append(escapeForShell(options.dnsInterface))
        }
        
        if !options.dnsIpv4Addr.isEmpty {
            args.append("--dns-ipv4-addr")
            args.append(escapeForShell(options.dnsIpv4Addr))
        }
        
        if !options.dnsIpv6Addr.isEmpty {
            args.append("--dns-ipv6-addr")
            args.append(escapeForShell(options.dnsIpv6Addr))
        }
        
        for resolve in options.resolve where resolve.isEnabled && !resolve.key.isEmpty {
            args.append("--resolve")
            args.append(escapeForShell("\(resolve.key):\(resolve.value)"))
        }
        
        return args
    }
    
    // MARK: - Network Arguments
    private func generateNetworkArgs(from options: CurlOptions) -> [String] {
        var args: [String] = []
        
        if !options.interface.isEmpty {
            args.append("--interface")
            args.append(escapeForShell(options.interface))
        }
        
        if !options.localPort.isEmpty {
            args.append("--local-port")
            args.append(escapeForShell(options.localPort))
        }
        
        if options.ipv4Only {
            args.append("-4")
        }
        
        if options.ipv6Only {
            args.append("-6")
        }
        
        return args
    }
    
    // MARK: - Advanced Arguments
    private func generateAdvancedArgs(from options: CurlOptions) -> [String] {
        var args: [String] = []
        
        if !options.range.isEmpty {
            args.append("-r")
            args.append(escapeForShell(options.range))
        }
        
        if !options.continueAt.isEmpty {
            args.append("-C")
            args.append(escapeForShell(options.continueAt))
        }
        
        if options.createDirs {
            args.append("--create-dirs")
        }
        
        if options.crlf {
            args.append("--crlf")
        }
        
        if options.pathAsIs {
            args.append("--path-as-is")
        }
        
        if options.noBuffer {
            args.append("-N")
        }
        
        if options.noSessionId {
            args.append("--no-sessionid")
        }
        
        if options.remoteTime {
            args.append("-R")
        }
        
        if options.parallel {
            args.append("-Z")
            if !options.parallelMax.isEmpty {
                args.append("--parallel-max")
                args.append(options.parallelMax)
            }
        }
        
        return args
    }
    
    // MARK: - Execute Command
    func execute(command: String) async throws -> CurlResponse {
        let startTime = Date()
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command + " -w $'\\n__HTTP_CODE__:%{http_code}' -s -S"]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        currentTask = process
        
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            throw error
        }
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let outputString = String(data: outputData, encoding: .utf8) ?? ""
        let errorString = String(data: errorData, encoding: .utf8) ?? ""
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Parse HTTP code from output
        var body = outputString
        var statusCode: Int? = nil
        
        if let range = outputString.range(of: "\n__HTTP_CODE__:") {
            body = String(outputString[..<range.lowerBound])
            let codeString = String(outputString[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            statusCode = Int(codeString)
        }
        
        // Parse headers if -i was used
        var headers = ""
        if body.contains("HTTP/") {
            let parts = body.components(separatedBy: "\r\n\r\n")
            if parts.count >= 2 {
                headers = parts[0]
                body = parts.dropFirst().joined(separator: "\r\n\r\n")
            }
        }
        
        currentTask = nil
        
        return CurlResponse(
            timestamp: Date(),
            command: command,
            statusCode: statusCode,
            headers: headers,
            body: body,
            errorOutput: errorString,
            duration: duration,
            success: process.terminationStatus == 0
        )
    }
    
    func cancel() {
        currentTask?.terminate()
        currentTask = nil
    }
    
    // MARK: - Helpers
    private func escapeForShell(_ string: String) -> String {
        // If string contains special characters, wrap in single quotes
        // and escape any single quotes within
        if string.contains(where: { " \t\n'\"\\$`!#&*()[]{}|;<>?".contains($0) }) {
            let escaped = string.replacingOccurrences(of: "'", with: "'\"'\"'")
            return "'\(escaped)'"
        }
        return string
    }
}
