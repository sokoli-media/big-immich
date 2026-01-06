//
//  ContentProvider.swift
//  TopShelf
//
//  Created by Maciej Płoński on 06/01/2026.
//

import ImmichAPI
import TVServices

class ContentProvider: TVTopShelfContentProvider {

    override func loadTopShelfContent() async -> (any TVTopShelfContent)? {
        guard let albums = await loadAlbums() else {
            return nil
        }

        var items: [TVTopShelfSectionedItem] = []
        for album in albums {
            items.append(await generateTopShelfItem(album: album))
        }

        let section = TVTopShelfItemCollection(items: items)
        let content = TVTopShelfSectionedContent(sections: [section])
        return content
    }

    private func generateTopShelfItem(album: Album) async
        -> TVTopShelfSectionedItem
    {
        let item = TVTopShelfSectionedItem(identifier: album.id)
        item.title = album.albumName
        item.imageShape = .hdtv

        var components = URLComponents()
        components.scheme = "bigimmich"
        components.host = "album"
        components.path = "/details"
        components.queryItems = [
            URLQueryItem(name: "albumID", value: album.id),
            URLQueryItem(name: "albumName", value: album.albumName),
        ]
        if let url = components.url {
            item.displayAction = TVTopShelfAction(url: url)
        }

        let thumbnailUrl = await getThumbnailURL(album: album)
        if let thumbnailUrl {
            item.setImageURL(
                thumbnailUrl,
                for: TVTopShelfItem.ImageTraits.screenScale1x
            )
        }

        return item
    }

    private func getThumbnailURL(album: Album) async -> URL? {
        do {
            return try await ImmichAPI.shared.getUrlWithQueryAuth(
                path: "/api/assets/\(album.albumThumbnailAssetId)/thumbnail",
                queryParams: ["size": "preview"]
            )
        } catch {
            return nil
        }
    }

    private func joinAlbums(_ albumLists: [Album]...) -> [Album] {
        let allAlbums = albumLists.flatMap { $0 }

        var uniqueAlbums = [String: Album]()
        for album in allAlbums {
            if uniqueAlbums[album.id] == nil {
                uniqueAlbums[album.id] = album
            }
        }

        return uniqueAlbums.values.sorted { $0.startDate > $1.startDate }
    }

    // TODO: this method is duplicated in AlbumsView, can we move it somewhere?
    private func loadAlbums() async -> [Album]? {
        do {
            let ownAlbums: [Album] = try await ImmichAPI.shared.loadObject(
                path: "/api/albums",
                queryParams: [:],
            )
            let sharedAlbums: [Album] = try await ImmichAPI.shared.loadObject(
                path: "/api/albums",
                queryParams: ["shared": "true"],
            )
            return joinAlbums(ownAlbums, sharedAlbums)
        } catch {
            return nil
        }
    }

}
