//
//  ShowAlertService.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 6/21/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import Foundation
import UIKit

class ShowAlertService {
    
    var loaderView: UIView?
    var onViewController: UIViewController!
    
    public init(onViewController: UIViewController) {
        self.onViewController = onViewController
    }
    
    //Alerts
    public func showAlertWithAlertTitle(title: String, alertMessage: String, actionTitle: String) {
        if onViewController != nil {
            let alertController = UIAlertController(title: title, message: alertMessage, preferredStyle: .alert)
            let actionButton = UIAlertAction(title: actionTitle, style: .default, handler: nil)
            alertController.addAction(actionButton)
            onViewController!.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func showAlertWithAlertTitle(title: String, alertMessage: String, defaultActionTitle: String, cancelActionTitle: String?, alert: @escaping (_ alertController: UIAlertController) -> Void) {
        
        if onViewController != nil {
            let alertController = UIAlertController(title: title, message: alertMessage, preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: defaultActionTitle, style: .default, handler: { (action) in
                alert(alertController)
            }))
            
            if cancelActionTitle != nil {
                alertController.addAction(UIAlertAction(title: cancelActionTitle, style: .cancel, handler: nil))
            }
            
            onViewController!.present(alertController, animated: true, completion: nil)
        }
    }
    
    public func showAlertWithTextField(title: String, alertMessage: String, placeHolderStr: String, defaultActionTitle: String, cancelActionTitle: String?, textEntered: @escaping (_ textFieldText: String) -> Void) {
        
        if onViewController != nil {
            let alertController = UIAlertController(title: title, message: alertMessage, preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.isSecureTextEntry = true
                textField.placeholder = placeHolderStr
            }
            if cancelActionTitle != nil {
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }
            
            alertController.addAction(UIAlertAction(title: defaultActionTitle, style: .default, handler: { [weak alertController] (_) in
                if let textField = alertController?.textFields![0] { // Force unwrapping because we know it exists.
                    textEntered(textField.text!)
                }
                //print("Text field: \(String(describing: textField?.text))")
            }))
            onViewController!.present(alertController, animated: true, completion: nil)
        }
    }
}
