import SwiftUI

struct CameraView: View {
    let mealType: MealType
    let onMealCaptured: (UIImage, ScanSource) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .camera
    @State private var activeScanSource: ScanSource = .receipt

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Hero area
                    ZStack {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color(.systemGray4), Color(.systemGray5)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 1
                                    )
                            )

                        VStack(spacing: 18) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 80, height: 80)

                                Image(systemName: "doc.text.viewfinder")
                                    .font(.system(size: 36, weight: .light))
                                    .foregroundStyle(.blue.opacity(0.7))
                            }

                            VStack(spacing: 6) {
                                Text("Scan your receipt")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)

                                Text("Snap a receipt or upload a screenshot for exact ingredient tracking")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                            }

                            // Meal type badge
                            HStack(spacing: 6) {
                                Image(systemName: mealType.icon)
                                    .font(.system(size: 12))
                                Text(mealType.rawValue)
                                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(mealType.color)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(mealType.color.opacity(0.1))
                            .clipShape(Capsule())
                        }
                    }
                    .frame(height: 300)
                    .padding(.horizontal, 24)

                    Spacer()
                        .frame(height: 28)

                    // Action buttons
                    VStack(spacing: 12) {
                        // Primary: Scan Receipt (camera)
                        Button {
                            activeScanSource = .receipt
                            pickerSource = .camera
                            showImagePicker = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "doc.text.viewfinder")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Scan Receipt")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.2, green: 0.5, blue: 0.95), Color(red: 0.15, green: 0.4, blue: 0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .blue.opacity(0.35), radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(ScaleButtonStyle())

                        // Secondary: Upload Receipt Screenshot (photo library)
                        Button {
                            activeScanSource = .screenshot
                            pickerSource = .photoLibrary
                            showImagePicker = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "rectangle.on.rectangle")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Upload Receipt Screenshot")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(.purple)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.purple.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color.purple.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())

                        // Tertiary: Take Food Photo
                        Button {
                            activeScanSource = .photo
                            pickerSource = .camera
                            showImagePicker = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Take Food Photo")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                        .frame(height: 36)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 32, height: 32)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Log Meal")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: pickerSource) { image in
                    onMealCaptured(image, activeScanSource)
                    dismiss()
                }
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    CameraView(mealType: .lunch, onMealCaptured: { _, _ in })
}
