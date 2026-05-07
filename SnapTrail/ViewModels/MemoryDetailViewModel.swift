import SwiftUI
import Combine
import Photos

@MainActor
final class MemoryDetailViewModel: ObservableObject {
    @Published var memory: Memory
    @Published var errorMessage: String?
    @Published var isDeleted: Bool = false

    /// Toast state for save-to-Photos feedback
    @Published var saveToastMessage: String?
    @Published var saveToastIsError: Bool = false

    private let memoryDataService: MemoryDataService

    init(memory: Memory, memoryDataService: MemoryDataService) {
        self.memory = memory
        self.memoryDataService = memoryDataService
    }

    func toggleFavourite() {
        do {
            try memoryDataService.toggleFavourite(memory)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteMemory() {
        do {
            try memoryDataService.delete(memory)
            isDeleted = true
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Save Image to Photos

    /// Saves the memory's image to the device Photo Library.
    /// Requests add-only permission if not yet granted, shows a toast for feedback.
    func saveImageToPhotos() {
        // Haptic feedback on long press
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        guard let uiImage = ImageStorageService.loadImage(fileName: memory.imageFileName) else {
            showToast("Image not found", isError: true)
            return
        }

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                switch status {
                case .authorized, .limited:
                    PHPhotoLibrary.shared().performChanges {
                        PHAssetChangeRequest.creationRequestForAsset(from: uiImage)
                    } completionHandler: { success, error in
                        DispatchQueue.main.async {
                            if success {
                                self.showToast("Saved to Photos", isError: false)
                            } else {
                                self.showToast("Save failed", isError: true)
                                print("Save to Photos error: \(error?.localizedDescription ?? "unknown")")
                            }
                        }
                    }
                case .denied, .restricted:
                    showToast("Photo access denied", isError: true)
                default:
                    showToast("Photo access unavailable", isError: true)
                }
            }
        }
    }

    /// Shows a temporary toast message that auto-dismisses after 2 seconds
    private func showToast(_ message: String, isError: Bool) {
        saveToastIsError = isError
        saveToastMessage = message

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.saveToastMessage = nil
        }
    }
}
