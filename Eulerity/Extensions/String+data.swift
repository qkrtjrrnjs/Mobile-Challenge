//
//  String+data.swift
//  Eulerity
//
//  Created by Chris Park on 11/11/21.
//

import Foundation

extension Data {
    mutating func appendString(_ string: String, encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding, allowLossyConversion: true) {
            append(data)
        }
    }
}
