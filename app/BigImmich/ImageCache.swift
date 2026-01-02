import SwiftUI

final class ImageCache {
    private let cache = NSCache<NSNumber, ImageWrapper>()

    init(countLimit: Int?, megaBytesLimit: Int?) {
        if let countLimit = countLimit {
            cache.countLimit = countLimit
        }

        if let megaBytesLimit = megaBytesLimit {
            cache.totalCostLimit = megaBytesLimit * 1024 * 1024
        }
    }

    func get(_ assetID: Int) -> Image? {
        cache.object(forKey: NSNumber(value: assetID))?.image
    }

    func set(_ assetID: Int, image: Image) {
        cache.setObject(ImageWrapper(image), forKey: NSNumber(value: assetID))
    }

    func clear() {
        cache.removeAllObjects()
    }
}

final class ImageWrapper {
    let image: Image
    init(_ image: Image) {
        self.image = image
    }
}
