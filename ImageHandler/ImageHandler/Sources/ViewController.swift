//
//  ViewController.swift
//  ImageHandler
//
//  Created by taekki on 2023/09/30.
//

import UIKit

final class ViewController: UIViewController {
  @IBOutlet weak private var imageView: UIImageView!
  
  private let sampleImageURL = "https://cdn.pixabay.com/photo/2018/07/08/14/16/cat-3523992_1280.jpg"
  private let service = ImageCacheService.shared
  
  @IBAction func fetchImageButtonDidTap(_ sender: UIButton) {
    self.imageView.setImage(with: sampleImageURL)
    
    /// - 캐싱처리
    // guard self.imageView.image == nil else { return }
    //
    // let image = try await service.setImage(with: sampleImageURL)
    // DispatchQueue.main.async { [weak self] in
    //   self?.imageView.image = image
    // }
    
    /// - 직접 요청
    // let image = try await requestImage(with: sampleImageURL)
    // DispatchQueue.main.async { [weak self] in
    //   self?.imageView.image = image
    // }
  }
  
  @IBAction func resetButtonDidTap(_ sender: UIButton) {
    DispatchQueue.main.async { [weak self] in
      self?.imageView.image = nil
    }
  }
  
  /// 다이렉트 URL 요청
  private func requestImage(with urlString: String) async throws -> UIImage? {
    guard let url = URL(string: urlString) else { return nil }
    let (data, _) = try await URLSession.shared.data(from: url)
    guard let image = UIImage(data: data) else { return nil }
    return image
  }
}

