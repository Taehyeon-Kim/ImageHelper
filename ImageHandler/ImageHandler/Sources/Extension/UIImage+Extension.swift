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
        let imageData = try? await ImageHelper.shared.fetch(with: url)
        let image = UIImage(data: imageData ?? Data())
        self.image = image
      }
    }
  }
}
