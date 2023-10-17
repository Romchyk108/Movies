//
//  ErrorHandler.swift
//  Movies
//
//  Created by Roman Shestopal on 20.10.2023.
//

import Foundation
import UIKit

public protocol ErrorHandlerProtocol: AnyObject {
    func showErrorAlert(title: String, message: String?, dismissCompletion: (()->())?)
}

public extension ErrorHandlerProtocol {
    func showErrorAlert(vc: UIViewController?, title: String, message: String?, dismissCompletion: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel) { _ in
            dismissCompletion?()
        }
        alert.addAction(action)
        vc?.present(alert, animated: true)
    }
}

public class ErrorHandler: ErrorHandlerProtocol {
    weak var vc: UIViewController?
    
    init(vc: UIViewController? = nil) {
        self.vc = vc
    }
    
    public func showErrorAlert(title: String, message: String?, dismissCompletion: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel) { _ in
            dismissCompletion?()
        }
        alert.addAction(action)
        if Thread.isMainThread {
            vc?.present(alert, animated: true)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.vc?.present(alert, animated: true)
            }
        }
    }
}
