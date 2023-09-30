//
//  UIImage+Extension.swift
//  ImageHandler
//
//  Created by taekki on 2023/09/30.
//

import UIKit

extension UIImageView {
  
  func setImage(with url: String) {
    Task {
      do {
        let image = try? await ImageCacheService.shared.setImage(with: url)
        self.image = image
      }
    }
  }
}
