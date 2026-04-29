//
//  SaveMemoryView.swift
//  SnapTrail
//
//  Created by Niramon Kitrattanasak on 30/4/2026.
//

import SwiftUI
import UIKit
import CoreLocation

struct SaveMemoryView: View {
    let image: UIImage
    let location: CLLocation?
    let locationName: String
    let capturedDate: Date

    @ObservedObject var viewModel: SaveMemoryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showSavedConfirmation = false

    var body: some View {
        ZStack {
            Color.snapBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    photoPreview
                    memoryDetails
                    captionInput

                    PrimaryButton(
                        title: viewModel.isSaving ? "Saving..." : "Save Memory",
                        systemImage: "checkmark"
                    ) {
                        saveMemory()
                    }
                    .disabled(viewModel.isSaving)
                    .opacity(viewModel.isSaving ? 0.65 : 1)
                }
                .padding(20)
            }
        }
        .navigationTitle("Save Memory")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.snapBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Retake") {
                    dismiss()
                }
                .foregroundColor(Color.snapAccent)
            }
        }
        .onAppear {
            viewModel.locationName = locationName
        }
        .alert("Unable to Save", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Memory Saved", isPresented: $showSavedConfirmation) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("Your photo, place, time, and caption were saved privately on this device.")
        }
    }

    private var photoPreview: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .clipped()
    }

    private var memoryDetails: some View {
        VStack(spacing: 14) {
            detailRow(
                icon: "mappin.and.ellipse",
                title: "Location",
                value: locationName
            )

            detailRow(
                icon: "calendar",
                title: "Date & Time",
                value: DateFormatterHelper.displayDateTime(capturedDate)
            )

            detailRow(
                icon: "lock.fill",
                title: "Privacy",
                value: "Stored locally on this device"
            )
        }
        .padding(18)
        .background(Color.snapCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private var captionInput: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Caption optional")
                .font(.headline)
                .foregroundColor(.snapTextPrimary)

            TextEditor(text: $viewModel.caption)
                .frame(minHeight: 110)
                .padding(10)
                .scrollContentBackground(.hidden)
                .background(Color.snapCardLight)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .foregroundColor(.snapTextPrimary)
                .overlay(alignment: .topLeading) {
                    if viewModel.caption.isEmpty {
                        Text("Write something about this moment...")
                            .foregroundColor(.snapTextSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                            .allowsHitTesting(false)
                    }
                }
        }
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color.snapAccent)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.snapTextSecondary)

                Text(value)
                    .font(.body.weight(.semibold))
                    .foregroundColor(.snapTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }

    private func saveMemory() {
        let saved = viewModel.saveMemory(
            image: image,
            location: location,
            capturedDate: capturedDate
        )

        if saved {
            showSavedConfirmation = true
        }
    }
}
