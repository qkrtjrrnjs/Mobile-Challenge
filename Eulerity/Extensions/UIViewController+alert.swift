//
//  UIViewController+alert.swift
//  Eulerity
//
//  Created by Chris Park on 11/10/21.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String = "", message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
