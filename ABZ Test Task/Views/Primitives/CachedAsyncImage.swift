//
//  CachedAsyncImage.swift
//  ABZ Test Task
//
//  Created by Ilia Kolo on 24.06.2025.
//

import SwiftUI

/// The cached async image view
///
/// The view asynchronously loads an image from the provided url
struct CachedAsyncImage<ContentView: View, PlaceholderView: View>: View {

    /// The url to download an image from
    let url: URL?
    /// The content view which will utilize the downloaded image
    @ViewBuilder let content: (Image) -> ContentView
    /// The placeholder view to show before the image is downloaded
    @ViewBuilder let placeholder: () -> PlaceholderView

    /// The internal state of an image to get update view once image is downloaded
    @State private var image: UIImage?

    /// Initialize new instance of the view with given url.
    ///
    /// - Parameter url: The url to download an image from. If none provided placeholder view will be shown.
    /// - Parameter content: The view to show once the image is downloaded.
    /// - Parameter placeholder: The view to show while image is not available.
    init(
        url: URL?,
        content: @escaping (Image) -> ContentView,
        placeholder: @escaping () -> PlaceholderView
    ) {
        self.url = url
        self.content = content
        self.placeholder = placeholder
    }

    /// Initialize new instance of the view with given string url.
    ///
    /// - Parameter string: The string with url to download an image from. If none provided placeholder view will be shown.
    /// - Parameter content: The view to show once the image is downloaded.
    /// - Parameter placeholder: The view to show while image is not available.
    init(
        string: String?,
        content: @escaping (Image) -> ContentView,
        placeholder: @escaping () -> PlaceholderView
    ) {
        if let string {
            self.url = URL(string: string)
        } else {
            self.url = nil
        }
        self.content = content
        self.placeholder = placeholder
    }

    var body: some View {
        if let image {
            content(Image(uiImage: image))
        } else {
            placeholder()
                .onAppear {
                    Task {
                        await loadImage()
                    }
                }
        }
    }

    private func loadImage() async {
        guard let url else { return }
        let urlRequest = URLRequest(url: url)

        if let cachedData = URLCache.shared.cachedResponse(for: urlRequest) {
            image = UIImage(data: cachedData.data)
        } else {
            do {
                let (data, response) = try await URLSession.shared.data(for: urlRequest)

                guard let image = UIImage(data: data) else {
                    return
                }

                URLCache.shared.storeCachedResponse(.init(response: response, data: data), for: urlRequest)

                self.image = image
            } catch {
                logger.error("Cannot download image from \(url): \(error.localizedDescription)")
            }
        }
    }
}
