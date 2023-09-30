//
//  ImageHelper.swift
//  ImageHandler
//
//  Created by taekki on 2023/09/30.
//

import Foundation

final class ImageHelper: ImageCache {
  static let shared = ImageHelper()
  
  // MARK: - Cache
  
  private lazy var memoryCache = MemoryCacheImpl()
  private lazy var diskCache = DiskCacheImpl()
  
  private init() {}
  
  func fetch(with urlString: String) async throws -> Data? {
    /// 1. Fetch image data in memory
    if let imageData = try await memoryCache.fetch(with: urlString) {
      return imageData
    }
    
    /// 2. Fetch image data in disk
    /// + set data in memory
    if let imageData = try await diskCache.fetch(with: urlString) {
      memoryCache.set(imageData, forKey: urlString)
      return imageData
    }
    guard let url = URL(string: urlString) else {
      return nil
    }
    
    /// 3. Network request and set image data in memory, disk
    guard let imageData = try await fetchImageData(with: url) else {
      return nil
    }
    memoryCache.set(imageData, forKey: urlString)
    diskCache.set(imageData, forKey: urlString)
    return imageData
  }
}
