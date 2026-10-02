import Foundation
import Observation

struct AuthUser: Equatable {
    let id: String
    let displayName: String?
}

struct AppleIdentity: Encodable {
    struct Name: Encodable {
        let firstName: String?
        let lastName: String?
    }

    struct Profile: Encodable {
        let name: Name
        let email: String?
    }

    let token: String
    let nonce: String
    let profile: Profile
}

enum AppleSignInNonce {
    static func make() -> String {
        "\(UUID().uuidString).\(UUID().uuidString)"
    }
}

protocol AuthProviding {
    func signInWithApple(_ identity: AppleIdentity) async throws -> AuthUser
    func signInWithGoogle() async throws -> AuthUser
    func signOut() async throws
}

enum AuthProviderError: LocalizedError {
    case notConfigured
    case providerUnavailable
    case requestFailed

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            "Authentication is enabled, but no API endpoint is configured."
        case .providerUnavailable:
            "This sign-in provider is not configured on the API yet."
        case .requestFailed:
            "The API could not complete sign in. Please try again."
        }
    }
}

struct MockAuthProvider: AuthProviding {
    func signInWithApple(_ identity: AppleIdentity) async throws -> AuthUser {
        AuthUser(id: "preview-apple-user", displayName: "Preview User")
    }

    func signInWithGoogle() async throws -> AuthUser {
        AuthUser(id: "preview-google-user", displayName: "Preview User")
    }

    func signOut() async throws {}
}

struct UnavailableAuthProvider: AuthProviding {
    func signInWithApple(_ identity: AppleIdentity) async throws -> AuthUser {
        throw AuthProviderError.notConfigured
    }

    func signInWithGoogle() async throws -> AuthUser {
        throw AuthProviderError.notConfigured
    }

    func signOut() async throws {
        throw AuthProviderError.notConfigured
    }
}

struct BetterAuthProvider: AuthProviding {
    private let baseURL: URL
    private let session: URLSession

    private var origin: String {
        var components = URLComponents()
        components.scheme = baseURL.scheme
        components.host = baseURL.host
        components.port = baseURL.port
        return components.string ?? baseURL.absoluteString
    }

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func signInWithApple(_ identity: AppleIdentity) async throws -> AuthUser {
        struct Token: Encodable {
            let token: String
            let nonce: String
            let user: AppleIdentity.Profile
        }
        struct RequestBody: Encodable {
            let provider = "apple"
            let idToken: Token
        }
        struct ResponseBody: Decodable {
            let user: User
            struct User: Decodable {
                let id: String
                let name: String
            }
        }

        var request = URLRequest(url: authEndpoint("sign-in/social"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(origin, forHTTPHeaderField: "Origin")
        request.httpBody = try JSONEncoder().encode(RequestBody(
            idToken: Token(token: identity.token, nonce: identity.nonce, user: identity.profile)
        ))

        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
            throw AuthProviderError.requestFailed
        }
        let result = try JSONDecoder().decode(ResponseBody.self, from: data)
        return AuthUser(id: result.user.id, displayName: result.user.name.isEmpty ? nil : result.user.name)
    }

    func signInWithGoogle() async throws -> AuthUser {
        throw AuthProviderError.providerUnavailable
    }

    func signOut() async throws {
        var request = URLRequest(url: authEndpoint("sign-out"))
        request.httpMethod = "POST"
        request.setValue(origin, forHTTPHeaderField: "Origin")
        let (_, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
            throw AuthProviderError.requestFailed
        }
    }

    private func authEndpoint(_ path: String) -> URL {
        path.split(separator: "/").reduce(baseURL.appendingPathComponent("api").appendingPathComponent("auth")) {
            $0.appendingPathComponent(String($1))
        }
    }
}

protocol AnalyticsTracking {
    func track(_ event: String, properties: [String: String])
}

struct NoopAnalyticsTracker: AnalyticsTracking {
    func track(_ event: String, properties: [String: String] = [:]) {}
}

@MainActor
@Observable
final class AppServices {
    let auth: any AuthProviding
    let subscriptions: any SubscriptionProviding
    let analytics: any AnalyticsTracking

    init(
        auth: (any AuthProviding)? = nil,
        subscriptions: (any SubscriptionProviding)? = nil,
        analytics: any AnalyticsTracking = NoopAnalyticsTracker()
    ) {
        if let auth {
            self.auth = auth
        } else {
            self.auth = Self.defaultAuthProvider()
        }

        self.subscriptions = subscriptions ?? Self.defaultSubscriptionProvider()
        self.analytics = analytics
    }

    private static func defaultSubscriptionProvider() -> any SubscriptionProviding {
        #if DEBUG
        if E2ETestConfiguration.isEnabled { return E2ESubscriptionProvider() }
        #endif
        return RevenueCatSubscriptionProvider()
    }

    private static func defaultAuthProvider() -> any AuthProviding {
        guard let baseURL = AppConfig.apiBaseURL else { return UnavailableAuthProvider() }
        return BetterAuthProvider(baseURL: baseURL)
    }
}
