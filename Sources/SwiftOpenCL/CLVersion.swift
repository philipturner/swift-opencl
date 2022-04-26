//
//  CLVersion.swift
//  
//
//  Created by Philip Turner on 4/26/22.
//

import COpenCL

func getVersion(versionInfo: UnsafeBufferPointer<CChar>) -> (Int, Int) {
  var highVersion = 0
  var lowVersion = 0
  var index = 7
  while versionInfo[index] != Character(".").asciiValue! {
    highVersion *= 10
    highVersion += Character(.init(versionInfo[index])).wholeNumberValue!
    index += 1
  }
  index += 1
  while versionInfo[index] != Character(".").asciiValue! &&
        versionInfo[index] != Character("\0").asciiValue! {
    lowVersion *= 10
    lowVersion += Character(.init(versionInfo[index])).wholeNumberValue!
    index += 1
  }
  return (highVersion, lowVersion)
}
