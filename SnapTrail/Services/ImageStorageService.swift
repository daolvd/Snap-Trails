import UIKit

enum ImageStorageService {
    private static var memoriesDirectory: URL {
        let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        return documentsDirectory.appendingPathComponent(
            AppConstants.memoriesFolderName,
            isDirectory: true
        )
    }

    static func saveImage(_ image: UIImage) throws -> String {
        try FileManager.default.createDirectory(
            at: memoriesDirectory,
            withIntermediateDirectories: true
        )

        let fileName = UUID().uuidString + ".jpg"
        let fileURL = memoriesDirectory.appendingPathComponent(fileName)

        guard let imageData = image.jpegData(compressionQuality: 0.85) else {
            throw AppError.imageSaveFailed
        }

        do {
            try imageData.write(to: fileURL, options: [.atomic])
            return fileName
        } catch {
            throw AppError.imageSaveFailed
        }
    }

    static func loadImage(fileName: String) -> UIImage? {
        let fileURL = memoriesDirectory.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        return UIImage(data: data)
    }

    static func deleteImage(fileName: String) {
        let fileURL = memoriesDirectory.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }

        try? FileManager.default.removeItem(at: fileURL)
    }

    static func imageExists(fileName: String) -> Bool {
        let fileURL = memoriesDirectory.appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
}
