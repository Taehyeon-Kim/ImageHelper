//
//  ImageRepository.swift
//  
//
//  Created by taekki on 2023/10/03.
//

import Foundation

/// ImageRepository 프로토콜
public protocol ImageRepository {
  func fetch(from imageURL: URL) async -> Data?
}
