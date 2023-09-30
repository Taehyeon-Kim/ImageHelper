//
//  ImageCacheService.swift
//  ImageHandler
//
//  Created by taekki on 2023/09/30.
//

import UIKit

final class ImageCacheService {

  enum ImageCacheError: Error {
    case invalidURL
  }
  
  static let shared = ImageCacheService()
  
  /// key로 class type을 요구하는데, String 타입은 struct이므로 NSString 타입을 사용해야 한다.
  /// 현재는 빠르게 확인하기 위해 value로 UIImage를 사용하도록 한다.
  /// NSCache는 Thread-safe하게 구현되어 있다.
  private let cache = NSCache<NSString, UIImage>()
  
  private init() {}
  
  /// Request -> Memory(Cache) -> Disk -> Server
  func setImage(with urlString: String) async throws -> UIImage? {
    guard let url = URL(string: urlString) else {
      throw ImageCacheError.invalidURL
    }
    
    /// - 1. Lookup memory
    if let image = findImageInMemory(with: urlString) {
      print("Hit! 캐시 메모리에서 꺼내온 이미지", image)
      return image
    }
    
    /// - 2. Lookup disk
    if let image = findImageInDisk(with: urlString) {
      print("Hit! 디스크에서 꺼내온 이미지", image)
      
      /// 디스크에서 꺼내왔다는 것은 캐시 메모리에 없다는 것이므로,
      /// 앱을 사용하는 동안에는 캐시에서 꺼내올 수 있도록 저장
      setImageInMemory(image: image, at: urlString)
      return image
    }
    
    /// - 3. Request to server
    /// async, await을 사용해서 가독성을 살림
    let (data, _) = try await URLSession.shared.data(from: url)
    if let image = UIImage(data: data) {
      /// 성공시에는 캐시와 디스크에 저장
      /// 1. In cache(memory)
      setImageInMemory(image: image, at: urlString)
      
      /// 2. In disk
      setImageInDisk(image: image, at: urlString)
      return image
    }
    return nil
  }
}

// MARK: - In Disk

extension ImageCacheService {
  
  private func findImageInMemory(with urlString: String) -> UIImage? {
    return cache.object(forKey: urlString as NSString)
  }
  
  private func setImageInMemory(image: UIImage, at urlString: String) {
    cache.setObject(image, forKey: urlString as NSString)
  }
}

// MARK: - In Disk

extension ImageCacheService {

  private func findImageInDisk(with urlString: String) -> UIImage? {
    // "https://cdn.pixabay.com/photo/2014/11/30/14/11/cat-551554_1280.jpg"
    // 전부 다 저장하는 것이 아니라 마지막 path(file-name)만 저장
    guard let fileURL = URL(string: urlString)?.lastPathComponent else { return nil }
    
    /// 1. 경로(URL) 설정
    guard let path = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first else {
      return nil
    }
    
    /// 2. 실제 이미지 저장할 폴더 지정
    /// e.g. Library/Caches/Images
    let storedDir = path.appending(path: "Images")
    
    /// 3. fileURL
    let filePath = storedDir.appending(path: fileURL)
    
    /// 디스크에서 해당 URL로 파일 찾아서 이미지로 바꾸기
    if FileManager.default.fileExists(atPath: filePath.path()) {
      guard let imageData = try? Data(contentsOf: filePath),
            let image = UIImage(data: imageData) else {
        return nil
      }
      return image
    } else {
      try? FileManager.default.createDirectory(
        atPath: storedDir.path(),
        withIntermediateDirectories: true,
        attributes: nil
      )
    }
    return nil
  }
  
  private func setImageInDisk(image: UIImage, at urlString: String) {
    guard let fileURL = URL(string: urlString)?.lastPathComponent else { return }
    guard let path = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first else { return }
    let storedDir = path.appending(path: "Images")
    guard let data = image.jpegData(compressionQuality: 1) else { return }
    
    do {
      try data.write(to: storedDir.appending(path: fileURL))
    } catch {
      fatalError("이미지를 저장하지 못했습니다.")
    }
  }
}
