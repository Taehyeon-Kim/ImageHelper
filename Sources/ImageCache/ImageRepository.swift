//
//  ImageRepository.swift
//  ImageHandler
//
//  Created by taekki on 2023/10/01.
//

import UIKit

public protocol ImageRepositoryProtocol {
  func fetchImage(imageURL: URL) async -> Data?
}

public enum THNetwork {
  public enum HeaderField {
    public static let NONE_MATCH = "If-None-Match"
    public static let ETAG = "Etag"
  }
  
  public enum APIRequest {
    public static let SUCCESS: Int = 200
    public static let NOT_MODIFIED: Int = 304
  }
}

public typealias THHeaderFields = THNetwork.HeaderField
public typealias THRequestStatus = THNetwork.APIRequest

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
  
  public func fetchImage(imageURL: URL) async -> Data? {
    let request = URLRequest(url: imageURL)
    if let cachedResponse = cache.cachedResponse(for: request) {
      return await fetch(for: imageURL, with: cachedResponse)
    } else {
      return await downloadImage(imageURL: imageURL)
    }
  }
  
  private func fetch(for imageURL: URL, with cachedResponse: CachedURLResponse) async -> Data? {
    /// 요청(Request) 생성
    var request = URLRequest(url: imageURL, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData)
    
    if let httpResponse = cachedResponse.response as? HTTPURLResponse,
       let etag = httpResponse.allHeaderFields[THHeaderFields.ETAG] as? String {
      request.addValue(etag, forHTTPHeaderField: THHeaderFields.NONE_MATCH)
    }
    
    /// 캐싱 데이터 검증
    do {
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else { return nil }
      
      /// status code : 304
      if httpResponse.statusCode == THRequestStatus.NOT_MODIFIED {
        /// 캐시된 데이터 사용
        return await loadImageFromCache(imageURL: imageURL)
      }
      
      /// status code : 200
      if httpResponse.statusCode == THRequestStatus.SUCCESS {
        /// 새 이미지 사용
        let cachedData = CachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedData, for: request)
        return data
      }
    } catch {
      return nil
    }
    
    return nil
  }
  
  /// 캐시된 URL 응답 반환
  /// ... 요청을 통해 데이터를 찾은 다음에 검색된 데이터로 UIImage를 초기화함
  private func loadImageFromCache(imageURL: URL) async -> Data? {
    let request = URLRequest(url: imageURL)
    
    if let data = cache.cachedResponse(for: request)?.data {
      return data
    } else {
      return nil
    }
  }
  
  /// 네트워크 호출
  /// 데이터가 있는지 확인한 다음에 CachedURLResponse 형식으로 저장한다.
  /// *메모리와 디스크(저장소)캐시에 모두 저장된다.
  private func downloadImage(imageURL: URL) async -> Data? {
    let request = URLRequest(url: imageURL)
    
    do {
      let (data, response) = try await session.data(for: request)
      let cachedData = CachedURLResponse(response: response, data: data)
      cache.storeCachedResponse(cachedData, for: request)
      return data
    } catch {
      return nil
    }
  }
}
