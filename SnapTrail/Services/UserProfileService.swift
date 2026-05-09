import Foundation
import UIKit

/// Persists the user's display name and profile photo across sessions.
/// Name is stored in UserDefaults; the photo is written to the app's
/// Documents directory as "profile_photo.jpg".
final class UserProfileService {

    static let shared = UserProfileService()
    private init() {}

    // MARK: - Keys

    private let nameKey = "userProfileName"
    private let photoFileName = "profile_photo.jpg"

    // MARK: - Name

    var displayName: String {
        get { UserDefaults.standard.string(forKey: nameKey) ?? "My SnapTrails" }
        set { UserDefaults.standard.set(newValue, forKey: nameKey) }
    }

    // MARK: - Photo

    private var photoURL: URL? {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent(photoFileName)
    }

    func savePhoto(_ image: UIImage) {
        guard let url = photoURL,
              let data = image.jpegData(compressionQuality: 0.85) else { return }
        try? data.write(to: url, options: .atomic)
    }

    func loadPhoto() -> UIImage? {
        guard let url = photoURL,
              let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    func deletePhoto() {
        guard let url = photoURL else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
