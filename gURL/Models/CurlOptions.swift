import Foundation

// MARK: - HTTP Methods
enum HTTPMethod: String, CaseIterable, Identifiable {
    case GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS, TRACE, CONNECT
    var id: String { rawValue }
}

// MARK: - Authentication Types
enum AuthenticationType: String, CaseIterable, Identifiable {
    case none = "None"
    case basic = "Basic"
    case bearer = "Bearer Token"
    case digest = "Digest"
    case ntlm = "NTLM"
    case negotiate = "Negotiate"
    case awsSigv4 = "AWS Sigv4"
    
    var id: String { rawValue }
    
    var curlFlag: String? {
        switch self {
        case .none: return nil
        case .basic: return "--basic"
        case .bearer: return nil // Uses -H "Authorization: Bearer ..."
        case .digest: return "--digest"
        case .ntlm: return "--ntlm"
        case .negotiate: return "--negotiate"
        case .awsSigv4: return "--aws-sigv4"
        }
    }
}

// MARK: - Body Type
enum BodyType: String, CaseIterable, Identifiable {
    case none = "None"
    case raw = "Raw"
    case formData = "Form Data"
    case urlEncoded = "x-www-form-urlencoded"
    case binary = "Binary"
    
    var id: String { rawValue }
}

// MARK: - Raw Body Content Type
enum RawBodyType: String, CaseIterable, Identifiable {
    case text = "Text"
    case json = "JSON"
    case xml = "XML"
    case html = "HTML"
    case javascript = "JavaScript"
    
    var id: String { rawValue }
    
    var contentType: String {
        switch self {
        case .text: return "text/plain"
        case .json: return "application/json"
        case .xml: return "application/xml"
        case .html: return "text/html"
        case .javascript: return "application/javascript"
        }
    }
}

// MARK: - HTTP Version
enum HTTPVersion: String, CaseIterable, Identifiable {
    case auto = "Auto"
    case http1_0 = "HTTP/1.0"
    case http1_1 = "HTTP/1.1"
    case http2 = "HTTP/2"
    case http3 = "HTTP/3"
    
    var id: String { rawValue }
    
    var curlFlag: String? {
        switch self {
        case .auto: return nil
        case .http1_0: return "--http1.0"
        case .http1_1: return "--http1.1"
        case .http2: return "--http2"
        case .http3: return "--http3"
        }
    }
}

// MARK: - SSL Version
enum SSLVersion: String, CaseIterable, Identifiable {
    case auto = "Auto"
    case tlsv1 = "TLS 1.0"
    case tlsv1_1 = "TLS 1.1"
    case tlsv1_2 = "TLS 1.2"
    case tlsv1_3 = "TLS 1.3"
    case sslv3 = "SSL 3.0"
    
    var id: String { rawValue }
    
    var curlFlag: String? {
        switch self {
        case .auto: return nil
        case .tlsv1: return "--tlsv1"
        case .tlsv1_1: return "--tlsv1.1"
        case .tlsv1_2: return "--tlsv1.2"
        case .tlsv1_3: return "--tlsv1.3"
        case .sslv3: return "--sslv3"
        }
    }
}

// MARK: - Proxy Type
enum ProxyType: String, CaseIterable, Identifiable {
    case http = "HTTP"
    case https = "HTTPS"
    case socks4 = "SOCKS4"
    case socks4a = "SOCKS4A"
    case socks5 = "SOCKS5"
    case socks5Hostname = "SOCKS5 Hostname"
    
    var id: String { rawValue }
    
    var curlFlag: String {
        switch self {
        case .http: return "--proxy-http"
        case .https: return "--proxy-https"
        case .socks4: return "--socks4"
        case .socks4a: return "--socks4a"
        case .socks5: return "--socks5"
        case .socks5Hostname: return "--socks5-hostname"
        }
    }
}

// MARK: - Key-Value Pair
struct KeyValuePair: Identifiable, Equatable, Hashable {
    let id = UUID()
    var key: String
    var value: String
    var isEnabled: Bool = true
    
    init(key: String = "", value: String = "", isEnabled: Bool = true) {
        self.key = key
        self.value = value
        self.isEnabled = isEnabled
    }
}

// MARK: - Form Data Item
struct FormDataItem: Identifiable, Equatable {
    let id = UUID()
    var key: String
    var value: String
    var isFile: Bool
    var filePath: String
    var contentType: String
    var isEnabled: Bool = true
    
    init(key: String = "", value: String = "", isFile: Bool = false, filePath: String = "", contentType: String = "", isEnabled: Bool = true) {
        self.key = key
        self.value = value
        self.isFile = isFile
        self.filePath = filePath
        self.contentType = contentType
        self.isEnabled = isEnabled
    }
}

// MARK: - Cookie
struct CookieItem: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var value: String
    var domain: String
    var path: String
    var isEnabled: Bool = true
    
    init(name: String = "", value: String = "", domain: String = "", path: String = "/", isEnabled: Bool = true) {
        self.name = name
        self.value = value
        self.domain = domain
        self.path = path
        self.isEnabled = isEnabled
    }
}

// MARK: - cURL Request Options
class CurlOptions: ObservableObject {
    // Basic Request
    @Published var url: String = ""
    @Published var method: HTTPMethod = .GET
    
    // Headers
    @Published var headers: [KeyValuePair] = [KeyValuePair()]
    @Published var userAgent: String = ""
    @Published var referer: String = ""
    
    // Body
    @Published var bodyType: BodyType = .none
    @Published var rawBody: String = ""
    @Published var rawBodyType: RawBodyType = .json
    @Published var formData: [FormDataItem] = [FormDataItem()]
    @Published var urlEncodedData: [KeyValuePair] = [KeyValuePair()]
    @Published var binaryFilePath: String = ""
    
    // Authentication
    @Published var authType: AuthenticationType = .none
    @Published var authUsername: String = ""
    @Published var authPassword: String = ""
    @Published var bearerToken: String = ""
    @Published var awsProvider: String = "aws:amz"
    @Published var awsRegion: String = ""
    @Published var awsService: String = ""
    
    // SSL/TLS Options
    @Published var insecure: Bool = false  // -k, --insecure
    @Published var sslVersion: SSLVersion = .auto
    @Published var certPath: String = ""  // --cert
    @Published var certType: String = "PEM"  // --cert-type
    @Published var keyPath: String = ""  // --key
    @Published var keyType: String = "PEM"  // --key-type
    @Published var keyPassword: String = ""  // --pass
    @Published var cacertPath: String = ""  // --cacert
    @Published var caPath: String = ""  // --capath
    @Published var crlFile: String = ""  // --crlfile
    @Published var pinnedPublicKey: String = ""  // --pinnedpubkey
    @Published var sslAllowBeast: Bool = false  // --ssl-allow-beast
    @Published var sslNoRevoke: Bool = false  // --ssl-no-revoke
    
    // Proxy
    @Published var useProxy: Bool = false
    @Published var proxyType: ProxyType = .http
    @Published var proxyHost: String = ""
    @Published var proxyPort: String = ""
    @Published var proxyUsername: String = ""
    @Published var proxyPassword: String = ""
    @Published var proxyTunnel: Bool = false  // -p, --proxytunnel
    @Published var noProxy: String = ""  // --noproxy
    
    // Cookies
    @Published var cookies: [CookieItem] = [CookieItem()]
    @Published var cookieJar: String = ""  // -c, --cookie-jar
    @Published var cookieFile: String = ""  // -b, --cookie (file)
    
    // Connection
    @Published var connectTimeout: String = ""  // --connect-timeout
    @Published var maxTime: String = ""  // -m, --max-time
    @Published var speedLimit: String = ""  // -Y, --speed-limit
    @Published var speedTime: String = ""  // -y, --speed-time
    @Published var limitRate: String = ""  // --limit-rate
    @Published var retryCount: String = ""  // --retry
    @Published var retryDelay: String = ""  // --retry-delay
    @Published var retryMaxTime: String = ""  // --retry-max-time
    @Published var retryAllErrors: Bool = false  // --retry-all-errors
    
    // Redirects
    @Published var followRedirects: Bool = true  // -L, --location
    @Published var maxRedirects: String = ""  // --max-redirs
    @Published var postRedirect: Bool = false  // --post301, --post302, --post303
    @Published var autoReferer: Bool = false  // --referer ";auto"
    
    // HTTP Options
    @Published var httpVersion: HTTPVersion = .auto
    @Published var compressed: Bool = false  // --compressed
    @Published var transferEncoding: Bool = false  // --tr-encoding
    @Published var keepAlive: Bool = true  // default is keep-alive
    @Published var keepAliveTime: String = ""  // --keepalive-time
    @Published var tcpNoDelay: Bool = false  // --tcp-nodelay
    @Published var tcpFastOpen: Bool = false  // --tcp-fastopen
    @Published var expectContinue: Bool = true  // --expect100-timeout
    
    // Output Options
    @Published var verbose: Bool = false  // -v, --verbose
    @Published var silent: Bool = false  // -s, --silent
    @Published var showError: Bool = false  // -S, --show-error
    @Published var includeHeaders: Bool = false  // -i, --include
    @Published var headOnly: Bool = false  // -I, --head
    @Published var outputFile: String = ""  // -o, --output
    @Published var writeOut: String = ""  // -w, --write-out
    @Published var dumpHeader: String = ""  // -D, --dump-header
    @Published var trace: String = ""  // --trace
    @Published var traceAscii: String = ""  // --trace-ascii
    @Published var traceTime: Bool = false  // --trace-time
    @Published var progressBar: Bool = false  // -#, --progress-bar
    @Published var failOnError: Bool = false  // -f, --fail
    @Published var failEarly: Bool = false  // --fail-early
    
    // DNS Options
    @Published var dnsServers: String = ""  // --dns-servers
    @Published var dnsInterface: String = ""  // --dns-interface
    @Published var dnsIpv4Addr: String = ""  // --dns-ipv4-addr
    @Published var dnsIpv6Addr: String = ""  // --dns-ipv6-addr
    @Published var resolve: [KeyValuePair] = []  // --resolve
    
    // Network Interface
    @Published var interface: String = ""  // --interface
    @Published var localPort: String = ""  // --local-port
    @Published var ipv4Only: Bool = false  // -4, --ipv4
    @Published var ipv6Only: Bool = false  // -6, --ipv6
    
    // Advanced
    @Published var customRequest: String = ""  // -X (for custom methods)
    @Published var range: String = ""  // -r, --range
    @Published var continueAt: String = ""  // -C, --continue-at
    @Published var createDirs: Bool = false  // --create-dirs
    @Published var crlf: Bool = false  // --crlf
    @Published var pathAsIs: Bool = false  // --path-as-is
    @Published var noBuffer: Bool = false  // -N, --no-buffer
    @Published var noSessionId: Bool = false  // --no-sessionid
    @Published var noKeepalive: Bool = false  // --no-keepalive
    @Published var rawOutput: Bool = false  // --raw
    @Published var remoteTime: Bool = false  // -R, --remote-time
    @Published var parallelMax: String = ""  // --parallel-max
    @Published var parallel: Bool = false  // -Z, --parallel
    
    func reset() {
        url = ""
        method = .GET
        headers = [KeyValuePair()]
        userAgent = ""
        referer = ""
        bodyType = .none
        rawBody = ""
        rawBodyType = .json
        formData = [FormDataItem()]
        urlEncodedData = [KeyValuePair()]
        binaryFilePath = ""
        authType = .none
        authUsername = ""
        authPassword = ""
        bearerToken = ""
        awsProvider = "aws:amz"
        awsRegion = ""
        awsService = ""
        insecure = false
        sslVersion = .auto
        certPath = ""
        certType = "PEM"
        keyPath = ""
        keyType = "PEM"
        keyPassword = ""
        cacertPath = ""
        caPath = ""
        crlFile = ""
        pinnedPublicKey = ""
        sslAllowBeast = false
        sslNoRevoke = false
        useProxy = false
        proxyType = .http
        proxyHost = ""
        proxyPort = ""
        proxyUsername = ""
        proxyPassword = ""
        proxyTunnel = false
        noProxy = ""
        cookies = [CookieItem()]
        cookieJar = ""
        cookieFile = ""
        connectTimeout = ""
        maxTime = ""
        speedLimit = ""
        speedTime = ""
        limitRate = ""
        retryCount = ""
        retryDelay = ""
        retryMaxTime = ""
        retryAllErrors = false
        followRedirects = true
        maxRedirects = ""
        postRedirect = false
        autoReferer = false
        httpVersion = .auto
        compressed = false
        transferEncoding = false
        keepAlive = true
        keepAliveTime = ""
        tcpNoDelay = false
        tcpFastOpen = false
        expectContinue = true
        verbose = false
        silent = false
        showError = false
        includeHeaders = false
        headOnly = false
        outputFile = ""
        writeOut = ""
        dumpHeader = ""
        trace = ""
        traceAscii = ""
        traceTime = false
        progressBar = false
        failOnError = false
        failEarly = false
        dnsServers = ""
        dnsInterface = ""
        dnsIpv4Addr = ""
        dnsIpv6Addr = ""
        resolve = []
        interface = ""
        localPort = ""
        ipv4Only = false
        ipv6Only = false
        customRequest = ""
        range = ""
        continueAt = ""
        createDirs = false
        crlf = false
        pathAsIs = false
        noBuffer = false
        noSessionId = false
        noKeepalive = false
        rawOutput = false
        remoteTime = false
        parallelMax = ""
        parallel = false
    }
    
    func copy() -> CurlOptions {
        let copy = CurlOptions()
        copy.url = url
        copy.method = method
        copy.headers = headers
        copy.userAgent = userAgent
        copy.referer = referer
        copy.bodyType = bodyType
        copy.rawBody = rawBody
        copy.rawBodyType = rawBodyType
        copy.formData = formData
        copy.urlEncodedData = urlEncodedData
        copy.binaryFilePath = binaryFilePath
        copy.authType = authType
        copy.authUsername = authUsername
        copy.authPassword = authPassword
        copy.bearerToken = bearerToken
        copy.awsProvider = awsProvider
        copy.awsRegion = awsRegion
        copy.awsService = awsService
        copy.insecure = insecure
        copy.sslVersion = sslVersion
        copy.certPath = certPath
        copy.certType = certType
        copy.keyPath = keyPath
        copy.keyType = keyType
        copy.keyPassword = keyPassword
        copy.cacertPath = cacertPath
        copy.caPath = caPath
        copy.crlFile = crlFile
        copy.pinnedPublicKey = pinnedPublicKey
        copy.sslAllowBeast = sslAllowBeast
        copy.sslNoRevoke = sslNoRevoke
        copy.useProxy = useProxy
        copy.proxyType = proxyType
        copy.proxyHost = proxyHost
        copy.proxyPort = proxyPort
        copy.proxyUsername = proxyUsername
        copy.proxyPassword = proxyPassword
        copy.proxyTunnel = proxyTunnel
        copy.noProxy = noProxy
        copy.cookies = cookies
        copy.cookieJar = cookieJar
        copy.cookieFile = cookieFile
        copy.connectTimeout = connectTimeout
        copy.maxTime = maxTime
        copy.speedLimit = speedLimit
        copy.speedTime = speedTime
        copy.limitRate = limitRate
        copy.retryCount = retryCount
        copy.retryDelay = retryDelay
        copy.retryMaxTime = retryMaxTime
        copy.retryAllErrors = retryAllErrors
        copy.followRedirects = followRedirects
        copy.maxRedirects = maxRedirects
        copy.postRedirect = postRedirect
        copy.autoReferer = autoReferer
        copy.httpVersion = httpVersion
        copy.compressed = compressed
        copy.transferEncoding = transferEncoding
        copy.keepAlive = keepAlive
        copy.keepAliveTime = keepAliveTime
        copy.tcpNoDelay = tcpNoDelay
        copy.tcpFastOpen = tcpFastOpen
        copy.expectContinue = expectContinue
        copy.verbose = verbose
        copy.silent = silent
        copy.showError = showError
        copy.includeHeaders = includeHeaders
        copy.headOnly = headOnly
        copy.outputFile = outputFile
        copy.writeOut = writeOut
        copy.dumpHeader = dumpHeader
        copy.trace = trace
        copy.traceAscii = traceAscii
        copy.traceTime = traceTime
        copy.progressBar = progressBar
        copy.failOnError = failOnError
        copy.failEarly = failEarly
        copy.dnsServers = dnsServers
        copy.dnsInterface = dnsInterface
        copy.dnsIpv4Addr = dnsIpv4Addr
        copy.dnsIpv6Addr = dnsIpv6Addr
        copy.resolve = resolve
        copy.interface = interface
        copy.localPort = localPort
        copy.ipv4Only = ipv4Only
        copy.ipv6Only = ipv6Only
        copy.customRequest = customRequest
        copy.range = range
        copy.continueAt = continueAt
        copy.createDirs = createDirs
        copy.crlf = crlf
        copy.pathAsIs = pathAsIs
        copy.noBuffer = noBuffer
        copy.noSessionId = noSessionId
        copy.noKeepalive = noKeepalive
        copy.rawOutput = rawOutput
        copy.remoteTime = remoteTime
        copy.parallelMax = parallelMax
        copy.parallel = parallel
        return copy
    }
}

// MARK: - Response Model
struct CurlResponse: Identifiable {
    let id = UUID()
    let timestamp: Date
    let command: String
    let statusCode: Int?
    let headers: String
    let body: String
    let errorOutput: String
    let duration: TimeInterval
    let success: Bool
    
    var formattedDuration: String {
        String(format: "%.2f ms", duration * 1000)
    }
    
    var statusText: String {
        guard let code = statusCode else { return "Error" }
        switch code {
        case 200: return "200 OK"
        case 201: return "201 Created"
        case 204: return "204 No Content"
        case 301: return "301 Moved Permanently"
        case 302: return "302 Found"
        case 304: return "304 Not Modified"
        case 400: return "400 Bad Request"
        case 401: return "401 Unauthorized"
        case 403: return "403 Forbidden"
        case 404: return "404 Not Found"
        case 405: return "405 Method Not Allowed"
        case 500: return "500 Internal Server Error"
        case 502: return "502 Bad Gateway"
        case 503: return "503 Service Unavailable"
        default: return "\(code)"
        }
    }
}

// MARK: - History Item
struct HistoryItem: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let url: String
    let method: String
    let command: String
    let statusCode: Int?
    let duration: TimeInterval
    let responseBody: String?
    let responseHeaders: String?
    var isPinned: Bool
    
    init(from response: CurlResponse, url: String, method: String) {
        self.id = UUID()
        self.timestamp = response.timestamp
        self.url = url
        self.method = method
        self.command = response.command
        self.statusCode = response.statusCode
        self.duration = response.duration
        self.responseBody = response.body
        self.responseHeaders = response.headers
        self.isPinned = false
    }
    
    // For backwards compatibility with existing saved history
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        url = try container.decode(String.self, forKey: .url)
        method = try container.decode(String.self, forKey: .method)
        command = try container.decode(String.self, forKey: .command)
        statusCode = try container.decodeIfPresent(Int.self, forKey: .statusCode)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        responseBody = try container.decodeIfPresent(String.self, forKey: .responseBody)
        responseHeaders = try container.decodeIfPresent(String.self, forKey: .responseHeaders)
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
    }
}
