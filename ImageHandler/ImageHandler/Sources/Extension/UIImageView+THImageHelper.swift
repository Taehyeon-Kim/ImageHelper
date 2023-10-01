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
        let imageData = try? await ImageHelper.shared.fetch(with: url)
        let image = UIImage(data: imageData ?? Data())
        await update(image: image)
      }
    }
  }
  
  @MainActor
  private func update(image: UIImage?) {
    self.base.image = image
  }
}
