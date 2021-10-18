//
//  File.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-18.
//

import Foundation
import UIKit


extension UIViewController {

    public func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
          let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "OK", style: .default))
          self.present(alertController, animated: true)
        }
    }

    public func showPermissionsAlert() {
        showAlert(
          withTitle: "Camera Permissions",
          message: "Please open Settings and grant permission for this app to use your camera.")
    }
    
    
    

}
