//
//  DiskCacheImpl.swift
//  ImageHandler
//
//  Created by taekki on 2023/09/30.
//

import Foundation

final class DiskCacheImpl: ImageCache {
  func fetch(with urlString: String) async throws -> Data? {
    guard let fileURL = URL(string: urlString)?.lastPathComponent else {
      return nil
    }
    
    guard let documentPath = FileManager.default.urls(
      for: .documentDirectory,
      in: .allDomainsMask
    ).first else {
      return nil
    }
    
    let imageDirPath = documentPath.appending(path: "Images")
    let filePath = imageDirPath.appending(path: fileURL)
    
    if FileManager.default.fileExists(atPath: filePath.path()) {
      return try? Data(contentsOf: filePath)
    } else {
      try? FileManager.default.createDirectory(
        atPath: imageDirPath.path(),
        withIntermediateDirectories: true
      )
    }
    
    return nil
  }
  
  func set(_ data: Data, forKey urlString: String) {
    guard let fileURL = URL(string: urlString)?.lastPathComponent else {
      return
    }
    
    guard let documentPath = FileManager.default.urls(
      for: .documentDirectory,
      in: .allDomainsMask
    ).first else {
      return
    }
    
    let imageDirPath = documentPath.appending(path: "Images")
    let filePath = imageDirPath.appending(path: fileURL)
    
    do {
      try data.write(to: filePath)
    } catch {
      print("이미지를 디스크에 저장하지 못했습니다.")
    }
  }
}
