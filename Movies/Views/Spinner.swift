//
//  Spinner.swift
//  Movies
//
//  Created by Roman Shestopal on 21.10.2023.
//

import Foundation
import UIKit
import SnapKit

open class Spinner {
    static var spinner: UIActivityIndicatorView?
    public static var style: UIActivityIndicatorView.Style = .large
    public static var baseBackColor = UIColor(white: 0, alpha: 0.6)
    public static var baseColor = UIColor.red
    
    public static func start(style: UIActivityIndicatorView.Style = style, backColor: UIColor = baseBackColor, baseColor: UIColor = baseColor) {
        if spinner == nil, let window = UIApplication.shared.connectedScenes.flatMap({ ($0 as? UIWindowScene)?.windows ?? [] }).last(where: { $0.isKeyWindow }) {
            let frame = UIScreen.main.bounds
            spinner = UIActivityIndicatorView(frame: frame)
            spinner!.backgroundColor = backColor
            spinner!.style = style
            spinner?.color = baseColor
            window.addSubview(spinner!)
            spinner!.startAnimating()
        }
    }
    
    public static func stop() {
        if spinner != nil {
            if Thread.isMainThread {
                spinner!.stopAnimating()
                spinner!.removeFromSuperview()
                spinner = nil
            } else {
                DispatchQueue.main.async {
                    spinner!.stopAnimating()
                    spinner!.removeFromSuperview()
                    spinner = nil
                }
            }
        }
    }
    
    public static func update() {
        if spinner != nil {
            stop()
            start()
        }
    }
}
