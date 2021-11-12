//
//  ImageCache.swift
//  Eulerity
//
//  Created by Chris Park on 11/12/21.
//

import Foundation
import UIKit

class ImageCache: NSObject, NSDiscardableContent {

    public var image: UIImage!

    func isContentDiscarded() -> Bool { return false }
    func beginContentAccess() -> Bool { return true }
    func endContentAccess() {}
    func discardContentIfPossible() {}
}
