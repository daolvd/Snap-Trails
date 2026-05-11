import UIKit

protocol ImageStorageServiceProtocol {
    func saveImage(_ image: UIImage) throws -> String
    func loadImage(fileName: String) -> UIImage?
    func deleteImage(fileName: String)
    func imageExists(fileName: String) -> Bool
}

final class ImageStorageService: ImageStorageServiceProtocol {
    nonisolated(unsafe) static let live: ImageStorageServiceProtocol = ImageStorageService()

    private let fileManager: FileManager
    private let folderName: String
    private let compressionQuality: CGFloat
    private let maxSizeBytes: Int

    init(
        fileManager: FileManager = .default,
        folderName: String = AppConstants.memoriesFolderName,
        compressionQuality: CGFloat = AppConstants.imageCompressionQuality,
        maxSizeBytes: Int = AppConstants.imageMaxSizeBytes
    ) {
        self.fileManager = fileManager
        self.folderName = folderName
        self.compressionQuality = compressionQuality
        self.maxSizeBytes = maxSizeBytes
    }

    private var memoriesDirectory: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent(folderName, isDirectory: true)
    }

    func saveImage(_ image: UIImage) throws -> String {
        try fileManager.createDirectory(at: memoriesDirectory, withIntermediateDirectories: true)

        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            throw AppError.imageSaveFailed
        }
        guard imageData.count <= maxSizeBytes else {
            throw AppError.imageTooLarge
        }

        let fileName = UUID().uuidString + ".jpg"
        let fileURL = memoriesDirectory.appendingPathComponent(fileName)

        do {
            try imageData.write(to: fileURL, options: [.atomic])
            return fileName
        } catch {
            throw AppError.imageSaveFailed
        }
    }

    func loadImage(fileName: String) -> UIImage? {
        let fileURL = memoriesDirectory.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            AppLog.error(
                "Failed to read image file '\(fileName)'",
                category: .storage,
                error: error
            )
            return nil
        }
    }

    /// Idempotent: deleting a non-existent file is a no-op.
    func deleteImage(fileName: String) {
        let fileURL = memoriesDirectory.appendingPathComponent(fileName)
        guard fileManager.fileExists(atPath: fileURL.path) else { return }
        do {
            try fileManager.removeItem(at: fileURL)
        } catch {
            AppLog.error(
                "Failed to delete image file '\(fileName)'",
                category: .storage,
                error: error
            )
        }
    }

    func imageExists(fileName: String) -> Bool {
        let fileURL = memoriesDirectory.appendingPathComponent(fileName)
        return fileManager.fileExists(atPath: fileURL.path)
    }
}
