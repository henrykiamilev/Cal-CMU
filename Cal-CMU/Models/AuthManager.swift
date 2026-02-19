import Foundation
import SwiftUI
import Supabase

@Observable
class AuthManager {
    var isAuthenticated = false
    var isLoading = true
    var currentUser: User?
    var userName: String = ""
    var userEmail: String = ""
    var userAvatarURL: URL?
    var errorMessage: String?

    private var authStateTask: Task<Void, Never>?

    init() {
        authStateTask = Task { [weak self] in
            await self?.listenForAuthChanges()
        }
    }

    deinit {
        authStateTask?.cancel()
    }

    // MARK: - Listen for Auth State

    private func listenForAuthChanges() async {
        for await (event, session) in SupabaseConfig.client.auth.authStateChanges {
            await MainActor.run {
                switch event {
                case .initialSession:
                    if let session {
                        self.handleSignedIn(session.user)
                    } else {
                        self.isAuthenticated = false
                    }
                    self.isLoading = false
                case .signedIn:
                    if let session {
                        self.handleSignedIn(session.user)
                    }
                case .signedOut:
                    self.isAuthenticated = false
                    self.currentUser = nil
                    self.userName = ""
                    self.userEmail = ""
                    self.userAvatarURL = nil
                default:
                    break
                }
            }
        }
    }

    private func handleSignedIn(_ user: User) {
        currentUser = user
        isAuthenticated = true
        userEmail = user.email ?? ""

        // Extract name and avatar from user metadata
        if let metadata = user.userMetadata {
            if let name = metadata["full_name"]?.value as? String {
                userName = name
            } else if let name = metadata["name"]?.value as? String {
                userName = name
            }
            if let avatar = metadata["avatar_url"]?.value as? String,
               let url = URL(string: avatar) {
                userAvatarURL = url
            }
        }
    }

    // MARK: - Google Sign In

    func signInWithGoogle() async {
        errorMessage = nil
        do {
            try await SupabaseConfig.client.auth.signInWithOAuth(
                provider: .google,
                redirectTo: SupabaseConfig.redirectURL
            )
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Sign Out

    func signOut() async {
        do {
            try await SupabaseConfig.client.auth.signOut()
            await MainActor.run {
                isAuthenticated = false
                currentUser = nil
                userName = ""
                userEmail = ""
                userAvatarURL = nil
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Handle Callback URL

    func handleURL(_ url: URL) async {
        do {
            try await SupabaseConfig.client.auth.session(from: url)
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}
