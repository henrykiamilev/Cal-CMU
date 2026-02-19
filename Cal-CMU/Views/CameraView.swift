import SwiftUI

struct CameraView: View {
    let onMealCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showImagePicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .camera

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Camera preview area
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .strokeBorder(Color(.systemGray4), lineWidth: 1)
                            )

                        VStack(spacing: 16) {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 56, weight: .light))
                                .foregroundStyle(.secondary)

                            Text("Take a photo of your meal")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(.secondary)

                            Text("We'll analyze the nutritional content")
                                .font(.system(size: 13, weight: .regular, design: .rounded))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .frame(height: 340)
                    .padding(.horizontal, 24)

                    Spacer()
                        .frame(height: 48)

                    // Action buttons
                    VStack(spacing: 14) {
                        // Camera button
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
                            .frame(height: 54)
                            .background(Color.green.gradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .green.opacity(0.3), radius: 12, x: 0, y: 6)
                        }

                        // Photo library button
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
                            .frame(height: 54)
                            .background(Color.green.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()
                        .frame(height: 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
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
    CameraView(onMealCaptured: { _ in })
}
