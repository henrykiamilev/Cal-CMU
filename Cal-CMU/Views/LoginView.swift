import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager
    @FocusState private var isInputFocused: Bool

    var body: some View {
        @Bindable var auth = authManager

        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.12, blue: 0.08),
                    Color(red: 0.02, green: 0.06, blue: 0.04),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .onTapGesture { isInputFocused = false }

            VStack(spacing: 0) {
                Spacer()

                // Logo & Branding
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.green.opacity(0.3), Color.green.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .blur(radius: 20)

                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.1, green: 0.65, blue: 0.35)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 88, height: 88)
                                .shadow(color: .green.opacity(0.4), radius: 20, x: 0, y: 10)

                            Image(systemName: "doc.text.viewfinder")
                                .font(.system(size: 38, weight: .medium))
                                .foregroundStyle(.white)
                        }
                    }

                    VStack(spacing: 8) {
                        Text("Cal-CMU")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Smart nutrition tracking\npowered by receipt scanning")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }

                Spacer()

                // Features
                VStack(spacing: 16) {
                    featureRow(
                        icon: "doc.text.viewfinder",
                        title: "Scan Receipts",
                        subtitle: "Get exact ingredients from your orders"
                    )
                    featureRow(
                        icon: "chart.bar.fill",
                        title: "Track Nutrients",
                        subtitle: "Vitamins, minerals, macros & more"
                    )
                    featureRow(
                        icon: "camera.fill",
                        title: "Photo Analysis",
                        subtitle: "Snap a photo for instant nutrition info"
                    )
                }
                .padding(.horizontal, 32)

                Spacer()

                // Sign in section
                VStack(spacing: 16) {
                    if authManager.authStep == .enterEmail {
                        emailEntryView
                    } else {
                        otpVerificationView
                    }

                    // Error message
                    if let error = authManager.errorMessage {
                        Text(error)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.red.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    // Terms
                    Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(.white.opacity(0.35))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }

    // MARK: - Email Entry

    private var emailEntryView: some View {
        @Bindable var auth = authManager

        return VStack(spacing: 16) {
            // Email input
            TextField("", text: $auth.emailInput, prompt: Text("Email address").foregroundStyle(.white.opacity(0.35)))
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .frame(height: 56)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .focused($isInputFocused)

            // Send Code button
            Button {
                isInputFocused = false
                Task {
                    await authManager.sendOTP()
                }
            } label: {
                HStack(spacing: 10) {
                    if authManager.isSendingOTP {
                        ProgressView()
                            .tint(.black)
                            .scaleEffect(0.9)
                    }

                    Text(authManager.isSendingOTP ? "Sending..." : "Continue with Email")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.15, green: 0.7, blue: 0.35)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .green.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .disabled(authManager.isSendingOTP)
            .buttonStyle(ScaleButtonStyle())
        }
    }

    // MARK: - OTP Verification

    private var otpVerificationView: some View {
        @Bindable var auth = authManager

        return VStack(spacing: 16) {
            // Info
            VStack(spacing: 8) {
                Text("Enter verification code")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text("We sent a 6-digit code to \(authManager.emailInput)")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }

            // OTP input
            TextField("", text: $auth.otpCode, prompt: Text("000000").foregroundStyle(.white.opacity(0.25)))
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .padding(.horizontal, 20)
                .frame(height: 64)
                .background(Color.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .focused($isInputFocused)

            // Verify button
            Button {
                isInputFocused = false
                Task {
                    await authManager.verifyOTP()
                }
            } label: {
                HStack(spacing: 10) {
                    if authManager.isVerifying {
                        ProgressView()
                            .tint(.black)
                            .scaleEffect(0.9)
                    }

                    Text(authManager.isVerifying ? "Verifying..." : "Verify & Sign In")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.15, green: 0.7, blue: 0.35)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .green.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .disabled(authManager.isVerifying)
            .buttonStyle(ScaleButtonStyle())

            // Resend / Change email
            HStack(spacing: 20) {
                Button {
                    Task {
                        await authManager.sendOTP()
                    }
                } label: {
                    Text("Resend Code")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.green)
                }

                Button {
                    authManager.resetToEmailEntry()
                } label: {
                    Text("Change Email")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
    }

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(.green)
                .frame(width: 44, height: 44)
                .background(Color.green.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager())
}
