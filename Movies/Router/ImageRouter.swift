//
//  ImageRouter.swift
//  Movies
//
//  Created by Roman Shestopal on 24.10.2023.
//

import Foundation
import UIKit

protocol ImageRouting: AnyObject {
    func showImage(imageName: String)
}

final class ImageRouter: ImageRouting {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func showImage(imageName: String) {
        let imageVC = ImageViewController(imageName: imageName)
        viewController?.present(imageVC, animated: true)
    }
}
