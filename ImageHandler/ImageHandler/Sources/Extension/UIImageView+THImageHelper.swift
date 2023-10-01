//
//  UIImageView+THImageHelper.swift
//  ImageHandler
//
//  Created by taekki on 2023/10/01.
//

import UIKit

/// 사용할 클래스에 채택
typealias THImageView = UIImageView
extension THImageView: THImageHelperCompatible {}

/// 사용할 메서드 선언
extension THImageHelperWrapper where Base: UIImageView {
  public func setImage(with url: String) {
    Task {
      do {
        let imageRepository = ImageRepository()
        if let url = URL(string: url),
           let image = await imageRepository.fetchImage(imageURL: url) {
          await update(image: image)
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
