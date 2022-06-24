//
//  Bitfields.swift
//  
//
//  Created by Philip Turner on 6/22/22.
//

struct CLCommandQueueProperties: OptionSet  {
  let rawValue: UInt64
  init(rawValue: RawValue) {
    self.rawValue = rawValue
  }
}
