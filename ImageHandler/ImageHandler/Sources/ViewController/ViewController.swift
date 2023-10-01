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

  @IBAction func fetchImageButtonDidTap(_ sender: UIButton) {
    self.firstImageView.th.setImage(with: sampleImageURL01)
    self.secondImageView.th.setImage(with: sampleImageURL02)
  }
  
  @IBAction func resetButtonDidTap(_ sender: UIButton) {
    DispatchQueue.main.async { [weak self] in
      self?.firstImageView.image = nil
      self?.secondImageView.image = nil
    }
  }
}
