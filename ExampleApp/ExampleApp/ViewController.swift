//
//  ViewController.swift
//  ExampleApp
//
//  Created by taekki on 2023/10/01.
//

import UIKit

import ImageCache

final class ViewController: UIViewController {
  
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  private let imageURL = "https://cdn.pixabay.com/photo/2017/11/09/21/41/cat-2934720_1280.jpg"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
    fetchImage(for: imageURL)
  }
  
  private func setupViews() {
    view.backgroundColor = .white
    view.addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.topAnchor),
      imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
    ])
  }

  private func fetchImage(for urlString: String) {
    imageView.th.setImage(with: urlString)
  }
}

