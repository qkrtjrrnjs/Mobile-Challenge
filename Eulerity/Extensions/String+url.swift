//
//  String+url.swift
//  Eulerity
//
//  Created by Chris Park on 11/11/21.
//

import Foundation

extension String {
    var fileURL: URL {
        return URL(fileURLWithPath: self)
    }
    
    var lastPathComponent: String {
        return fileURL.lastPathComponent
    }
}
