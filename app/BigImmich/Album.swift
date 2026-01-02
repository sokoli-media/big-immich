import Foundation

struct Album: Codable, Identifiable, Hashable {
    let id: String
    let albumName: String
    let albumThumbnailAssetId: String
    let createdAt: String
    let updatedAt: String
    let startDate: String
    let lastModifiedAssetTimestamp: String
    let assets: [AlbumAsset]

    static func == (lhs: Album, rhs: Album) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct AlbumAsset: Codable, Identifiable {
    let id: String
    let type: String
    let originalPath: String
    let duration: String
    let exifInfo: ExifInfo?
}

struct ExifInfo: Codable {
    let dateTimeOriginal: String?
    let city: String?
    let state: String?
    let country: String?
}
