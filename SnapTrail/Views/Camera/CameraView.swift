//
//  CameraView.swift
//  SnapTrail
//
//  Created by Niramon Kitrattanasak on 28/4/2026.
//

import SwiftUI
import UIKit
import CoreLocation
import SwiftData


struct CameraView: View {
    let memoryDataService: MemoryDataService
    let categoryDataService: CategoryDataService

    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showSaveMemory = false
    @State private var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        NavigationStack {
            ZStack {
                Color.snapBackground.ignoresSafeArea()

                GeometryReader { geo in
                    let screenWidth = geo.size.width
                    let screenHeight = geo.size.height
                    let horizontalPadding: CGFloat = 24
                    let previewWidth = screenWidth - horizontalPadding * 2
                    // Photo preview takes ~55% of available height, clamped
                    let previewHeight = min(max(previewWidth * 1.1, 280), screenHeight * 0.58)

                    VStack(spacing: 0) {
                        Spacer()

                        // Photo preview area
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.snapCard)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                                )

                            if let selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: previewWidth, height: previewHeight)
                                    .clipped()
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                            } else {
                                VStack(spacing: 16) {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 64))
                                        .foregroundColor(Color.snapAccent.opacity(0.3))
                                    Text("Take or select a photo")
                                        .font(.subheadline)
                                        .foregroundColor(.snapTextSecondary)
                                }
                            }
                        }
                        .frame(width: previewWidth, height: previewHeight)
                        .padding(.horizontal, horizontalPadding)

                        Spacer()

                        // Capture controls
                        HStack(spacing: 40) {
                            // Flash toggle
                            IconButton(systemName: "bolt.slash.fill", size: 56) {
                                // Flash not available in picker mode
                            }

                            // Shutter button
                            Button {
                                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                    pickerSourceType = .camera
                                } else {
                                    pickerSourceType = .photoLibrary
                                }
                                showImagePicker = true
                            } label: {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 76, height: 76)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.snapCardLight, lineWidth: 4)
                                            .frame(width: 84, height: 84)
                                    )
                            }

                            // Photo library
                            IconButton(systemName: "photo.on.rectangle") {
                                pickerSourceType = .photoLibrary
                                showImagePicker = true
                            }
                        }
                        .padding(.bottom, 16)

                        // Location badge
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption)
                                .foregroundColor(Color.snapAccent)
                            Text("Tap shutter to begin")
                                .font(.caption)
                                .foregroundColor(.snapTextSecondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.snapCard)
                        .clipShape(Capsule())
                        .padding(.bottom, geo.safeAreaInsets.bottom > 0 ? 8 : 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("SNAPTRAIL")
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(Color.snapAccent)
                }
            }
            .toolbarBackground(Color.snapBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(sourceType: pickerSourceType) { image in
                    selectedImage = image
                    showSaveMemory = true
                }
            }
            .fullScreenCover(isPresented: $showSaveMemory) {
                if let image = selectedImage {
                    SaveMemoryView(
                        image: image,
                        memoryDataService: memoryDataService,
                        categoryDataService: categoryDataService,
                        onDismiss: {
                            selectedImage = nil
                            showSaveMemory = false
                        }
                    )
                }
            }
        }
    }
}

#Preview {
    CameraView(
        memoryDataService: MemoryDataService(modelContext: PreviewContainer.context),
        categoryDataService: CategoryDataService(modelContext: PreviewContainer.context)
    )
    .modelContainer(PreviewContainer.shared)
}
