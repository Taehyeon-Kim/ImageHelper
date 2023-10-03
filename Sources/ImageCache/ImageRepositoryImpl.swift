//
//  ImageRepository.swift
//  ImageHandler
//
//  Created by taekki on 2023/10/01.
//

import Foundation

public actor ImageRepositoryImpl: ImageRepository {
  
  // MARK: - Properties
  
  private let cache: URLCache
  private var session = URLSession.shared
  
  /// 생성자로 캐시 정책 설정 가능
  public init(cache: URLCache = URLCache(memoryCapacity: MEM_CAPACITY, diskCapacity: DISK_CAPACITY)) {
    self.cache = cache
  }
  
  /// 이미지 데이터를 가져오는 fetch 함수
  public func fetch(from imageURL: URL) async -> Data? {
    let request = URLRequest(url: imageURL)
    if let cachedResponse = cache.cachedResponse(for: request) {
      return await fetch(from: imageURL, with: cachedResponse)
    } else {
      return await fetchFromRemote(with: imageURL)
    }
  }
}

extension ImageRepositoryImpl {
  
  /// 캐싱 데이터 검증
  private func fetch(
    from imageURL: URL,
    with cachedResponse: CachedURLResponse
  ) async -> Data? {
    /// 요청(Request) 생성
    var request = URLRequest(url: imageURL)
    request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    
    /// 헤더 추가
    if let httpResponse = cachedResponse.response as? HTTPURLResponse,
       let etag = httpResponse.allHeaderFields[THHeaderFields.ETAG] as? String {
      request.addValue(etag, forHTTPHeaderField: THHeaderFields.NONE_MATCH)
    }
    
    do {
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse else { return nil }
      
      /// status code : 304
      if httpResponse.statusCode == THRequestStatus.NOT_MODIFIED {
        /// 캐시된 데이터 사용
        return await fetchFromCache(with: imageURL)
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
}

extension ImageRepositoryImpl {
  /// 캐시된 URL 응답 반환
  /// ... 요청을 통해 데이터를 찾은 다음에 검색된 데이터로 UIImage를 초기화함
  private func fetchFromCache(with imageURL: URL) async -> Data? {
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
  private func fetchFromRemote(with imageURL: URL) async -> Data? {
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
