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

    private let memoryDataService: MemoryDataServiceProtocol
    private let imageStorage: ImageStorageServiceProtocol

    init(
        memory: Memory,
        memoryDataService: MemoryDataServiceProtocol,
        imageStorage: ImageStorageServiceProtocol = ImageStorageService.live
    ) {
        self.memory = memory
        self.memoryDataService = memoryDataService
        self.imageStorage = imageStorage
    }

    func toggleFavourite() {
        do {
            try memoryDataService.setFavourite(memory, to: !memory.isFavourite)
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
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        guard let uiImage = imageStorage.loadImage(fileName: memory.imageFileName) else {
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
                                AppLog.error(
                                    "Save to Photos failed",
                                    category: .storage,
                                    error: error
                                )
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

    private func showToast(_ message: String, isError: Bool) {
        saveToastIsError = isError
        saveToastMessage = message

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.saveToastMessage = nil
        }
    }
}
