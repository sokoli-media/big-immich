import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .albums

    @State private var albumID: String? = nil
    @State private var albumName: String? = nil
    @State private var assetID: String? = nil

    @State private var isShowingSlideshow = false
    @State private var albumDetailsInitialyFocusedButton: ButtonFocus =
        .slideshow

    var body: some View {
        ZStack {
            if isShowingSlideshow, let albumID = albumID {
                SlideshowView(
                    albumID: albumID,
                    initialAssetID: assetID,
                    onExit: { exitAssetID in
                        selectedTab = .albumAssets

                        isShowingSlideshow = false
                        assetID = exitAssetID
                    },
                )
                .zIndex(50)
            } else {
                VStack {
                    Picker("Menu", selection: $selectedTab) {
                        Text("Albums").tag(Tab.albums)
                        if selectedTab == .albumAssets,
                            let albumName = albumName
                        {
                            Text(albumName).tag(Tab.albumAssets)
                        }
                        if selectedTab == .albumDetails,
                            let albumName = albumName
                        {
                            Text(albumName).tag(Tab.albumDetails)
                        }
                        Text("Settings").tag(Tab.settings)
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 1200)
                    .padding(.top, 40)
                    .onChange(of: selectedTab) {
                        if selectedTab == .settings {
                            albumID = nil
                            albumName = nil
                            assetID = nil
                        }
                    }
                    .onExitCommand(perform: {
                        if selectedTab == .albumAssets {
                            selectedTab = .albumDetails
                        } else if selectedTab == .albumDetails {
                            selectedTab = .albums
                        } else {
                            albumID = nil
                            albumName = nil
                            assetID = nil
                        }
                    })

                    Spacer()

                    switch selectedTab {
                    case .albums:
                        AlbumsView(
                            initialAlbumID: albumID,
                            onSelectAlbum: {
                                selectedAlbumID,
                                selectedAlbumName in
                                albumID = selectedAlbumID
                                albumName = selectedAlbumName
                                assetID = nil
                                albumDetailsInitialyFocusedButton = .slideshow

                                selectedTab = .albumDetails
                            },
                        )
                    case .albumDetails:
                        if let currentAlbumID = albumID {
                            AlbumDetailsView(
                                albumID: currentAlbumID,
                                initialyFocusedButton:
                                    albumDetailsInitialyFocusedButton,
                                startSlideshow: {
                                    assetID = nil

                                    isShowingSlideshow = true
                                },
                                viewAssets: {
                                    assetID = nil

                                    selectedTab = .albumAssets
                                },
                                onExit: {
                                    selectedTab = .albums
                                },
                            )
                        }
                    case .albumAssets:
                        if let currentAlbumID = albumID {
                            AlbumAssetsView(
                                albumID: currentAlbumID,
                                initialAssetID: assetID,
                                startSlideshow: { exitAssetID in
                                    assetID = exitAssetID

                                    isShowingSlideshow = true
                                },
                                onExit: {
                                    selectedTab = .albumDetails
                                    albumDetailsInitialyFocusedButton =
                                        .viewAssets
                                },
                            )
                        }
                    case .settings:
                        SettingsView()
                            .onExitCommand(perform: {
                                albumID = nil
                                albumName = nil
                                assetID = nil
                                
                                selectedTab = .albums
                            })
                    }

                    Spacer()
                }
            }
        }
    }
}

enum Tab: Hashable {
    case albums
    case albumAssets
    case albumDetails
    case settings
}
