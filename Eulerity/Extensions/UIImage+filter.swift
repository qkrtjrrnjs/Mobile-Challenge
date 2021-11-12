//
//  UIImage+filter.swift
//  Eulerity
//
//  Created by Chris Park on 11/11/21.
//

import Foundation
import UIKit

enum FilterType : String {
    case sephia = "CISepiaTone"
    case colorInvert = "CIColorInvert"
    case process = "CIPhotoEffectProcess"
    case mono = "CIPhotoEffectMono"
}

extension UIImage {
    func addFilter(filterString : String?) -> UIImage {
        let ciFilterStrings = [
            "Sephia": "CISepiaTone",
            "Invert Color": "CIColorInvert",
            "Process": "CIPhotoEffectProcess",
            "Mono": "CIPhotoEffectMono"
        ]
        
        guard let filterString = filterString, let ciFilterString = ciFilterStrings[filterString], let filter = CIFilter(name: ciFilterString) else {
            assertionFailure("Invalid filter")
            return self
        }

        guard let ciInput = CIImage(image: self) else {
            assertionFailure("Invalid input image")
            return self
        }
        filter.setValue(ciInput, forKey: kCIInputImageKey)
        
        guard let ciOutput = filter.outputImage else {
            assertionFailure("Invalid ouputImage")
            return self
        }
        
        let ciContext = CIContext()
        
        if let cgImage = ciContext.createCGImage(ciOutput, from: ciOutput.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            return uiImage
        } else {
            return self
        }
    }
}
