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
    from imageURLString: String,
    placeholder: UIImage? = nil,
    indicator: UIActivityIndicatorView? = nil,
    transitionTime: TimeInterval = 0.0,
    shouldDownsample: Bool = true
  ) {
    base.image = placeholder

    let imageHelper = THImageHelper()
    let scale = UIScreen.main.scale
    
    Task {
      let image = await imageHelper.fetchImage(
        from: imageURLString,
        shouldDownsample: shouldDownsample,
        size: base.frame.size,
        scale: scale
      )

      await updateImage(image, transitionTime: transitionTime)
    }
  }
  
  @MainActor
  private func updateImage(
    _ image: UIImage?,
    transitionTime: TimeInterval = 0.0
  ) {
    base.alpha = 0
    base.image = image
    
    UIView.animate(withDuration: transitionTime) {
      base.alpha = 1
    }
  }
}
