//
//  UIImageView+THImageHelper.swift
//  ImageHandler
//
//  Created by taekki on 2023/10/01.
//

import UIKit

/// 사용할 클래스에 채택
public typealias THImageView = UIImageView
extension THImageView: THImageHelperCompatible {}

/// 사용할 메서드 선언
extension THImageHelperWrapper where Base: UIImageView {
  public func setImage(
    with url: String,
    resizing: Bool = true,
    scale: CGFloat = 1
  ) {
    Task {
      do {
        let imageRepository = ImageRepository()
        if let url = URL(string: url),
           let data = await imageRepository.fetchImage(imageURL: url) {
          
          // 리사이징
          if resizing {
            let resizedImage = await data.downSampling(to: base.frame.size, scale: scale)
            await update(image: resizedImage)
          } else {
            let image = data.mapToImage()
            await update(image: image)
          }
          
        } else {
          await update(image: UIImage())
        }
      }
    }
  }
  
  @MainActor
  private func update(image: UIImage?) {
    self.base.image = image
  }
}
