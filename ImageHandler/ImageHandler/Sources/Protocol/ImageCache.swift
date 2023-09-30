//
//  ImageCache.swift
//  ImageHandler
//
//  Created by taekki on 2023/09/30.
//

import UIKit

protocol ImageCache {
  func fetch(with url: URL) async throws -> Data?
}

extension ImageCache {
  func fetchImageData(with url: URL) async throws -> Data? {
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
  }
}
