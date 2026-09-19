import Foundation
import Observation

struct AuthUser: Equatable {
    let id: String
    let displayName: String?
}

protocol AuthProviding {
    func signInWithApple() async throws -> AuthUser
    func signInWithGoogle() async throws -> AuthUser
    func signOut() async throws
}

enum AuthProviderError: LocalizedError {
    case notConfigured

    var errorDescription: String? {
        "Authentication is enabled, but no production auth provider is configured."
    }
}

struct MockAuthProvider: AuthProviding {
    func signInWithApple() async throws -> AuthUser {
        AuthUser(id: "preview-apple-user", displayName: "Preview User")
    }

    func signInWithGoogle() async throws -> AuthUser {
        AuthUser(id: "preview-google-user", displayName: "Preview User")
    }

    func signOut() async throws {}
}

struct UnavailableAuthProvider: AuthProviding {
    func signInWithApple() async throws -> AuthUser {
        throw AuthProviderError.notConfigured
    }

    func signInWithGoogle() async throws -> AuthUser {
        throw AuthProviderError.notConfigured
    }

    func signOut() async throws {
        throw AuthProviderError.notConfigured
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
        subscriptions: any SubscriptionProviding = RevenueCatSubscriptionProvider(),
        analytics: any AnalyticsTracking = NoopAnalyticsTracker()
    ) {
        if let auth {
            self.auth = auth
        } else {
            self.auth = Self.defaultAuthProvider()
        }

        self.subscriptions = subscriptions
        self.analytics = analytics
    }

    private static func defaultAuthProvider() -> any AuthProviding {
        #if DEBUG
        MockAuthProvider()
        #else
        UnavailableAuthProvider()
        #endif
    }
}
