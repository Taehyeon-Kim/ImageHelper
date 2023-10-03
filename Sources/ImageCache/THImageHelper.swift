//
//  THImageHelper.swift
//  
//
//  Created by taekki on 2023/10/03.
//

import UIKit

public class THImageHelper {
  
  private let imageRepository: ImageRepository
  
  public init(imageRepository: ImageRepository = ImageRepositoryImpl()) {
    self.imageRepository = imageRepository
  }
  
  public func fetchImage(
    from imageURLString: String,
    shouldDownsample: Bool = true,
    size: CGSize,
    scale: CGFloat
  ) async -> UIImage {
    guard let url = URL(string: imageURLString) else {
      return UIImage()
    }

    guard let imageData = await imageRepository.fetch(from: url),
          let image = UIImage(data: imageData) else {
      return UIImage()
    }
    
    if shouldDownsample {
      return downsample(imageData: imageData, for: size, scale: scale)
    } else {
      return image
    }
  }

  private func downsample(imageData: Data, for size: CGSize, scale:CGFloat) -> UIImage {
    let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
    guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else {
      return UIImage()
    }
    let maxDimensionInPixels = max(size.width, size.height) * scale
    let downsampleOptions: [CFString : Any] = [
      kCGImageSourceCreateThumbnailFromImageAlways: true,
      kCGImageSourceShouldCacheImmediately: true,
      kCGImageSourceCreateThumbnailWithTransform: true,
      kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
    ]
    
    guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions as CFDictionary) else {
      assertionFailure()
      return UIImage()
    }
    return UIImage(cgImage: downsampledImage)
  }
}
