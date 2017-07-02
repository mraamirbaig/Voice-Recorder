//
//  ShowAlertService.swift
//  Voice Recorder
//
//  Created by Aamir Baig on 6/21/17.
//  Copyright © 2017 AamirBaig. All rights reserved.
//

import Foundation
import UIKit

class ShowAlertAndLoaderService {
    
    var loaderView: UIView?
    var onViewController: UIViewController!
    
    public init(onViewController: UIViewController) {
        self.onViewController = onViewController
    }
    
    public func addLoader() {
        if let viewController = onViewController {
            let backgroundFrameSize = CGSize.init(width: 80.0, height: 80.0)
            loaderView = getLoaderBackgroundView(size: backgroundFrameSize)
            let activityIndicator = getActivityIndicator(style: .whiteLarge)
            
            loaderView!.addSubview(activityIndicator)
            activityIndicator.center = loaderView!.center
            
            viewController.view.addSubview(loaderView!)
            setupConstraints(subview: loaderView!, parentView: viewController.view, size: CGSize.init(width: 80.0, height: 80.0))
        }
    }
    
    public func addLoaderViewWithTitle(title: String) {
        
        
        if let viewController = onViewController {
            let backgroundFrameSize = CGSize.init(width: 160.0, height: 46.0)
            loaderView = getLoaderBackgroundView(size: backgroundFrameSize)
            let activityIndicator = getActivityIndicator(style: .white)
            
            loaderView!.addSubview(activityIndicator)
            activityIndicator.center = CGPoint.init(x: 25, y: 23)
            let strLabel = getLabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46), text: title)
            loaderView!.addSubview(strLabel)
            
            viewController.view.addSubview(loaderView!)
            setupConstraints(subview: loaderView!, parentView: viewController.view, size: CGSize.init(width: 80.0, height: 80.0))
        }
    }
    
    private func getLabel(frame: CGRect, text: String) -> UILabel {
        
        let strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = text
        strLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightMedium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        return strLabel
    }
    
    private func getLoaderBackgroundView(size: CGSize) -> UIView {
        let backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        backgroundView.frame.size = CGSize.init(width: size.width, height: size.height)
        backgroundView.backgroundColor = UIColor.init(red: 68 / 225, green: 68 / 225, blue: 68 / 225, alpha: 0.7)
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 10
        return backgroundView
    }
    
    private func getActivityIndicator(style: UIActivityIndicatorViewStyle) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = style
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    func setupConstraints(subview: UIView, parentView: UIView, size: CGSize) {
        let centerX = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: parentView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: parentView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: subview.frame.size.width)
        let height = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: subview.frame.size.height)
        subview.translatesAutoresizingMaskIntoConstraints = false
        parentView.addConstraints([centerX, centerY, width, height])
    }
    
    public func removeLoaderView() {
        if loaderView != nil {
            loaderView!.removeFromSuperview()
            loaderView = nil
        }
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
