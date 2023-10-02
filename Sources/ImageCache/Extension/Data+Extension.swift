//
//  File.swift
//  
//
//  Created by taekki on 2023/10/02.
//

import UIKit

extension Data {
  
  public func mapToImage() -> UIImage? {
    return UIImage(data: self)
  }
  
  /// 다운샘플링 메서드
  public func downSampling(to targetSize: CGSize, scale: CGFloat) -> UIImage? {
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let imageSource = CGImageSourceCreateWithData(self as CFData, imageSourceOptions) else {
      return nil
    }
    
    let maxDimension = Swift.max(targetSize.width, targetSize.height) * scale
    let resizingOptions: [CFString: Any] = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceShouldCacheImmediately: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceThumbnailMaxPixelSize: maxDimension,
    ]
    
    guard let resizedImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, resizingOptions as CFDictionary) else {
      print("ERROR: Resizing Error")
      return nil
    }
    
    return UIImage(cgImage: resizedImage)
  }
}
