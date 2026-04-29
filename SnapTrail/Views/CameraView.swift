//
//  CameraView.swift
//  SnapTrail
//
//  Created by Niramon Kitrattanasak on 28/4/2026.
//

import SwiftUI
import UIKit
import CoreLocation

struct CameraView: View {
    let memoryDataService: MemoryDataService
    let categoryDataService: CategoryDataService

    @StateObject private var locationService = LocationService()
    @State private var capturedImage: UIImage?
    @State private var capturedLocation: CLLocation?
    @State private var capturedDate = Date()
    @State private var locationName = "Location unavailable"
    @State private var locationStatus = "Ready to capture"
    @State private var isDetectingLocation = false
    @State private var showCamera = false
    @State private var showSaveMemory = false
    @State private var errorMessage: String?
    @State private var pickerSourceType: UIImagePickerController.SourceType = .camera

    private let geocodingService = GeocodingService()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.snapBackground.ignoresSafeArea()

                VStack(spacing: 22) {
                    cameraPreview
                    locationPill

                    VStack(spacing: 8) {
                        Text("Capture your reality.")
                            .font(.title3.bold())
                            .foregroundColor(.snapTextPrimary)

                        Text("Photos tied to coordinates. Stored privately on this device.")
                            .font(.subheadline)
                            .foregroundColor(.snapTextSecondary)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()

                    PrimaryButton(title: "Take Photo", systemImage: "camera.fill") {
                        openCamera()
                    }
                }
                .padding(24)
            }
            .navigationTitle("Capture")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.snapBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker(sourceType: pickerSourceType) { image in
                    handleCapturedImage(image)
                }
                .ignoresSafeArea()
            }
            .navigationDestination(isPresented: $showSaveMemory) {
                if let capturedImage {
                    SaveMemoryView(
                        image: capturedImage,
                        location: capturedLocation,
                        locationName: locationName,
                        capturedDate: capturedDate,
                        viewModel: SaveMemoryViewModel(memoryDataService: memoryDataService)
                    )
                }
            }
            .alert("Capture Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .onAppear {
                locationService.requestPermission()
            }
        }
    }

    private var cameraPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.snapCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.snapAccent.opacity(0.25), lineWidth: 1)
                )

            if let capturedImage {
                Image(uiImage: capturedImage)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 24))
            } else {
                VStack(spacing: 14) {
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 58, weight: .medium))
                        .foregroundColor(Color.snapAccent.opacity(0.65))

                    Text("Camera Preview")
                        .font(.headline)
                        .foregroundColor(.snapTextPrimary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 320)
        .clipped()
    }

    private var locationPill: some View {
        HStack(spacing: 8) {
            Image(systemName: isDetectingLocation ? "location.circle" : "location.fill")
            Text(locationStatus)
                .font(.caption.bold())
        }
        .foregroundColor(.snapAccent)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Color.snapCardLight)
        .clipShape(Capsule())
    }

    private func openCamera() {
        pickerSourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
        showCamera = true
    }

    private func handleCapturedImage(_ image: UIImage) {
        capturedImage = image
        capturedDate = Date()
        locationStatus = "Detecting location..."
        isDetectingLocation = true

        Task {
            do {
                let location = try await locationService.getCurrentLocation()
                capturedLocation = location
                locationName = await geocodingService.reverseGeocode(location: location)
                locationStatus = "Location saved"
            } catch {
                capturedLocation = nil
                locationName = "Location unavailable"
                locationStatus = "Location unavailable"
            }

            isDetectingLocation = false
            showSaveMemory = true
        }
    }
}

struct CameraPicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onCapture: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        if sourceType == .camera {
            picker.cameraCaptureMode = .photo
        }
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onCapture: (UIImage) -> Void
        let dismiss: DismissAction

        init(onCapture: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onCapture = onCapture
            self.dismiss = dismiss
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.originalImage] as? UIImage {
                onCapture(image)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}
