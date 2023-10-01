//
//  THImageHelper.swift
//  ImageHandler
//
//  Created by taekki on 2023/10/01.
//

import Foundation

/// Generic 사용
/// - 여러 타입에 호환되게 사용할 수 있도록 함
/// - Wrapper로 한 번 감싸고 그 안에 있는 base(여러 타입)을 사용해서 메서드에 접근하도록 함
public struct THImageHelperWrapper<Base> {
  public let base: Base
  
  public init(base: Base) {
    self.base = base
  }
}

/// AnyObject와 NSObject의 차이
public protocol THImageHelperCompatible: NSObject {}

extension THImageHelperCompatible {
  /// 계산 프로퍼티이기 때문에 인스턴스를 매번 생성하지만,
  /// 구조체이므로 불변성을 보장할 수 있다.
  public var th: THImageHelperWrapper<Self> {
    return THImageHelperWrapper(base: self)
  }
}
