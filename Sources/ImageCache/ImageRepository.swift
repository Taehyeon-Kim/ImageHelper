//
//  ImageRepository.swift
//  ImageHandler
//
//  Created by taekki on 2023/10/01.
//

import UIKit

public protocol ImageRepositoryProtocol {
  func fetchImage(imageURL: URL) async -> UIImage?
  func downloadImage(imageURL: URL) async -> UIImage?
  func loadImageFromCache(imageURL: URL) async -> UIImage?
}

public actor ImageRepository: ImageRepositoryProtocol {
  /// - URLCache는 thread-safe하다.
  /// - 인스턴스 메서드는 다중 스레드(여러 실행 컨텍스트)에서 안전하게 호출할 수 있지만
  /// - 동일한 요청에 대해서 응답을 읽거나 쓰려고 할 때 즉, 변경을 하려고 할 때 race-condition이 발생할 수 있다.
  /// - e.g. cachedResponse(for:), storeCachedResponse(_:for:)
  private let cache: URLCache
  
  private var session: URLSession {
    let config = URLSessionConfiguration.default
    config.urlCache = cache
    let session = URLSession(configuration: config)
    return session
  }
  
  public init(cache: URLCache = URLCache.shared) {
    self.cache = cache
  }
  
  public func fetchImage(imageURL: URL) async -> UIImage? {
    let request = URLRequest(url: imageURL)
    if cache.cachedResponse(for: request) != nil {
      return await loadImageFromCache(imageURL: imageURL)
    } else {
      return await downloadImage(imageURL: imageURL)
    }
  }
  
  /// 캐시된 URL 응답 반환
  /// ... 요청을 통해 데이터를 찾은 다음에 검색된 데이터로 UIImage를 초기화함
  public func loadImageFromCache(imageURL: URL) async -> UIImage? {
    let request = URLRequest(url: imageURL)
    if let data = cache.cachedResponse(for: request)?.data,
       let image = UIImage(data: data) {
      return image
    } else {
      return nil
    }
  }

  /// 네트워크 호출
  /// 데이터가 있는지 확인한 다음에 CachedURLResponse 형식으로 저장한다.
  /// *메모리와 디스크(저장소)캐시에 모두 저장된다.
  public func downloadImage(imageURL: URL) async -> UIImage? {
    let request = URLRequest(url: imageURL)
    do {
      let (data, response) = try await session.data(for: request)
      let cachedData = CachedURLResponse(response: response, data: data)
      cache.storeCachedResponse(cachedData, for: request)
      return UIImage(data: data)
    } catch {
      return nil
    }
  }
}
