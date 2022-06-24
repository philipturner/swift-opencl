//
//  Bitfields.swift
//  
//
//  Created by Philip Turner on 6/22/22.
//

public struct CLCommandQueueProperties: OptionSet  {
  public let rawValue: UInt64
  public init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
}


