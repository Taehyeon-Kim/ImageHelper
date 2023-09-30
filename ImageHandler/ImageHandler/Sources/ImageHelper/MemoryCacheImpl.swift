//
//  MemoryCache.swift
//  ImageHandler
//
//  Created by taekki on 2023/09/30.
//

import Foundation

final class MemoryCacheImpl: ImageCache {
  private let cache: NSCache<NSString, CachedImage>
  
  init(countLimit: Int = 0, totalCostLimit: Int = 0) {
    let cache = NSCache<NSString, CachedImage>()
    cache.countLimit = countLimit
    cache.totalCostLimit = totalCostLimit
    self.cache = cache
  }
  
  func fetch(with urlString: String) async throws -> Data? {
    let nsString = urlString as NSString
    return cache.object(forKey: nsString)?.imageData
  }
  
  func set(_ data: Data, forKey urlString: String) {
    let cachedImage = CachedImage(imageData: data)
    let nsString = urlString as NSString
    cache.setObject(cachedImage, forKey: nsString, cost: data.count)
  }
}
