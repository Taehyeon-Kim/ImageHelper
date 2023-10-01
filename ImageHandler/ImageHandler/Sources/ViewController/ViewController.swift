//
//  ViewController.swift
//  ImageHandler
//
//  Created by taekki on 2023/09/30.
//

import UIKit

final class ViewController: UIViewController {
  
  // MARK: - Outlets
  
  @IBOutlet weak private var firstImageView: UIImageView!
  @IBOutlet weak private var secondImageView: UIImageView!
  
  // MARK: - Image URL
  
  private let sampleImageURL01 = "https://cdn.pixabay.com/photo/2018/07/08/14/16/cat-3523992_1280.jpg"
  private let sampleImageURL02 = "https://cdn.pixabay.com/photo/2014/11/30/14/11/cat-551554_640.jpg"

  // MARK: - Property
  
  private var imageRepository: ImageRepositoryProtocol = ImageRepository()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    let diskCacheURL = cachesURL.appendingPathComponent("DownloadCache")
    let cache = URLCache(memoryCapacity: 100_000_000, diskCapacity: 1_000_000_000, directory: diskCacheURL)
    
    imageRepository = ImageRepository(cache: cache)
  }

  @IBAction func fetchImageButtonDidTap(_ sender: UIButton) {
    Task {
      if let url1 = URL(string: sampleImageURL01),
         let image = await imageRepository.fetchImage(imageURL: url1) {
        update(image: image, at: firstImageView)
      }
    
      if let url2 = URL(string: sampleImageURL02),
         let image = await imageRepository.fetchImage(imageURL: url2) {
        update(image: image, at: secondImageView)
      }
    }
    
    // firstImageView.th.setImage(with: sampleImageURL01)
    // secondImageView.th.setImage(with: sampleImageURL02)
  }
  
  @MainActor
  private func update(image: UIImage, at imageView: UIImageView) {
    imageView.image = image
  }
  
  @MainActor
  @IBAction func resetButtonDidTap(_ sender: UIButton) {
    firstImageView.image = nil
    secondImageView.image = nil
  }
}
