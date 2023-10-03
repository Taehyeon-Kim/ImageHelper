//
//  THNetwork.swift
//  
//
//  Created by taekki on 2023/10/03.
//

import Foundation

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

public var MEM_CAPACITY = 10 * 1024 * 1024 // (10MB)
public var DISK_CAPACITY = 50 * 1024 * 1024     // (1MB)
