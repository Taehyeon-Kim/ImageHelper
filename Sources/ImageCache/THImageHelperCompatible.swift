//
//  THImageHelperCompatible.swift
//  ImageHandler
//
//  Created by taekki on 2023/10/01.
//

import Foundation

/// AnyObject와 NSObject의 차이
public protocol THImageHelperCompatible: AnyObject {}

extension THImageHelperCompatible {
  /// 계산 프로퍼티이기 때문에 인스턴스를 매번 생성하지만,
  /// 구조체이므로 불변성을 보장할 수 있다.
  public var th: THImageHelperWrapper<Self> {
    return THImageHelperWrapper(base: self)
  }
}
