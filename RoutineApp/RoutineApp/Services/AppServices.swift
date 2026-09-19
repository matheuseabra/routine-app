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

struct MockAuthProvider: AuthProviding {
    func signInWithApple() async throws -> AuthUser {
        AuthUser(id: "preview-apple-user", displayName: "Preview User")
    }

    func signInWithGoogle() async throws -> AuthUser {
        AuthUser(id: "preview-google-user", displayName: "Preview User")
    }

    func signOut() async throws {}
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
        auth: any AuthProviding = MockAuthProvider(),
        subscriptions: any SubscriptionProviding = RevenueCatSubscriptionProvider(),
        analytics: any AnalyticsTracking = NoopAnalyticsTracker()
    ) {
        self.auth = auth
        self.subscriptions = subscriptions
        self.analytics = analytics
    }
}
