//
//  ViewController.swift
//  ExampleApp
//
//  Created by taekki on 2023/10/01.
//

import UIKit

import ImageCache

final class ViewController: UIViewController {
  
  private lazy var segmentControl: UISegmentedControl = {
    let segmentControl = UISegmentedControl()
    segmentControl.translatesAutoresizingMaskIntoConstraints = false
    segmentControl.insertSegment(withTitle: "first", at: 0, animated: false)
    segmentControl.insertSegment(withTitle: "second", at: 1, animated: false)
    return segmentControl
  }()
  private let label: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .black
    return label
  }()
  private let imageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  private let imageURL = "https://images.unsplash.com/photo-1695821449523-6929f4e61b6f?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxlZGl0b3JpYWwtZmVlZHwzfHx8ZW58MHx8fHx8&auto=format"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupViews()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    segmentControl.addAction(UIAction(handler: { [weak self] _ in
      guard let self = self else { return }
      
      let placeholder = UIImage(named: "placeholder")
      let shouldDownsample = segmentControl.selectedSegmentIndex == 0
      
      if shouldDownsample {
        imageView.th.setImage(from: imageURL, transitionTime: 0.5)
      } else {
        imageView.th.setImage(from: imageURL, placeholder: placeholder, transitionTime: 2.5, shouldDownsample: false)
      }
    }), for: .valueChanged)
  }
  
  private func setupViews() {
    view.backgroundColor = .white
    
    view.addSubview(segmentControl)
    NSLayoutConstraint.activate([
      segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      segmentControl.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      segmentControl.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
    ])
    
    view.addSubview(label)
    NSLayoutConstraint.activate([
      label.topAnchor.constraint(equalTo: segmentControl.bottomAnchor),
      label.heightAnchor.constraint(equalToConstant: 50),
      label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor)
    ])
    
    view.addSubview(imageView)
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: label.bottomAnchor),
      imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
    ])
  }
}
