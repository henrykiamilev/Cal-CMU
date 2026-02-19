import Foundation
import SwiftUI
import Supabase

enum AuthStep {
    case enterEmail
    case enterOTP
}

@Observable
class AuthManager {
    var isAuthenticated = false
    var isLoading = true
    var currentUser: User?
    var userName: String = ""
    var userEmail: String = ""
    var errorMessage: String?

    // Login flow state
    var authStep: AuthStep = .enterEmail
    var emailInput: String = ""
    var otpCode: String = ""
    var isSendingOTP = false
    var isVerifying = false

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

        if let metadata = user.userMetadata {
            if let name = metadata["full_name"]?.value as? String {
                userName = name
            } else if let name = metadata["name"]?.value as? String {
                userName = name
            }
        }
    }

    // MARK: - Send OTP

    func sendOTP() async {
        errorMessage = nil
        await MainActor.run { isSendingOTP = true }

        do {
            let trimmed = emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else {
                await MainActor.run {
                    errorMessage = "Please enter your email address"
                    isSendingOTP = false
                }
                return
            }
            try await SupabaseConfig.client.auth.signInWithOTP(email: trimmed)

            await MainActor.run {
                authStep = .enterOTP
                isSendingOTP = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isSendingOTP = false
            }
        }
    }

    // MARK: - Verify OTP

    func verifyOTP() async {
        errorMessage = nil
        await MainActor.run { isVerifying = true }

        do {
            let code = otpCode.trimmingCharacters(in: .whitespacesAndNewlines)
            guard code.count == 6 else {
                await MainActor.run {
                    errorMessage = "Please enter the 6-digit code"
                    isVerifying = false
                }
                return
            }

            let trimmed = emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
            try await SupabaseConfig.client.auth.verifyOTP(
                email: trimmed,
                token: code,
                type: .email
            )

            await MainActor.run {
                isVerifying = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isVerifying = false
            }
        }
    }

    // MARK: - Reset Flow

    func resetToEmailEntry() {
        authStep = .enterEmail
        otpCode = ""
        errorMessage = nil
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
                authStep = .enterEmail
                emailInput = ""
                otpCode = ""
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
}
