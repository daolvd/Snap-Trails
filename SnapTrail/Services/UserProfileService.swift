import Foundation
import UIKit

protocol UserProfileServiceProtocol {
    var displayName: String { get set }
    func savePhoto(_ image: UIImage)
    func loadPhoto() -> UIImage?
    func deletePhoto()
}

final class UserProfileService: UserProfileServiceProtocol {
    private let defaults: UserDefaults
    private let fileManager: FileManager
    private let nameKey: String
    private let photoFileName: String

    init(
        defaults: UserDefaults = .standard,
        fileManager: FileManager = .default,
        nameKey: String = AppConstants.userProfileNameKey,
        photoFileName: String = AppConstants.profilePhotoFileName
    ) {
        self.defaults = defaults
        self.fileManager = fileManager
        self.nameKey = nameKey
        self.photoFileName = photoFileName
    }

    var displayName: String {
        get { defaults.string(forKey: nameKey) ?? "My SnapTrails" }
        set { defaults.set(newValue, forKey: nameKey) }
    }

    private var photoURL: URL? {
        fileManager
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(photoFileName)
    }

    func savePhoto(_ image: UIImage) {
        guard let url = photoURL,
              let data = image.jpegData(compressionQuality: AppConstants.imageCompressionQuality)
        else { return }
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            AppLog.error("Failed to save profile photo", category: .storage, error: error)
        }
    }

    func loadPhoto() -> UIImage? {
        guard let url = photoURL else { return nil }
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            AppLog.error("Failed to load profile photo", category: .storage, error: error)
            return nil
        }
    }

    /// Idempotent: deleting a non-existent photo is a no-op.
    func deletePhoto() {
        guard let url = photoURL, fileManager.fileExists(atPath: url.path) else { return }
        do {
            try fileManager.removeItem(at: url)
        } catch {
            AppLog.error("Failed to delete profile photo", category: .storage, error: error)
        }
    }
}
