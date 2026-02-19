import SwiftUI

struct CameraView: View {
    let mealType: MealType
    let onMealCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .camera

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Camera preview area
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

                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(mealType.color.opacity(0.1))
                                    .frame(width: 80, height: 80)

                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 36, weight: .light))
                                    .foregroundStyle(mealType.color.opacity(0.7))
                            }

                            VStack(spacing: 6) {
                                Text("Scan your \(mealType.rawValue.lowercased())")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                                    .foregroundStyle(.primary)

                                Text("Take a photo and we'll analyze the nutrition")
                                    .font(.system(size: 13, weight: .regular, design: .rounded))
                                    .foregroundStyle(.tertiary)
                                    .multilineTextAlignment(.center)
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
                    .frame(height: 320)
                    .padding(.horizontal, 24)

                    Spacer()
                        .frame(height: 40)

                    // Action buttons
                    VStack(spacing: 14) {
                        Button {
                            pickerSource = .camera
                            showImagePicker = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Take Photo")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.1, green: 0.65, blue: 0.35)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .green.opacity(0.35), radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(ScaleButtonStyle())

                        Button {
                            pickerSource = .photoLibrary
                            showImagePicker = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Choose from Library")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                            }
                            .foregroundStyle(.green)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.green.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(Color.green.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())

                        // Barcode option
                        Button {
                            // Placeholder for barcode scanning
                            pickerSource = .camera
                            showImagePicker = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Scan Barcode")
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
                    Text("Scan Meal")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: pickerSource) { image in
                    onMealCaptured(image)
                    dismiss()
                }
                .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    CameraView(mealType: .lunch, onMealCaptured: { _ in })
}
