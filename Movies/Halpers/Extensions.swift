//
//  Extensions.swift
//  Movies
//
//  Created by Roman Shestopal on 20.10.2023.
//

import Foundation
import UIKit

extension UILabel {
    static func heightForLabel(text: String, font: UIFont, width: CGFloat, lineBreakMode: NSLineBreakMode? = .byWordWrapping) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        if let mode = lineBreakMode {
            label.lineBreakMode = mode
        }
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
    
    static func widthForLabel(text: String, font: UIFont, height: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height ))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.width
    }
}
