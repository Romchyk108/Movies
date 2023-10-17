//
//  VideoRouter.swift
//  Movies
//
//  Created by Roman Shestopal on 23.10.2023.
//

import Foundation
import UIKit

protocol VideoRouting: AnyObject {
    func showVideoPlayer(url: URL?)
}

final class VideoRouter: VideoRouting {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func showVideoPlayer(url: URL?) {
        guard let url else { return }
        let videoVC = PlayerViewController(url: url)
        viewController?.present(videoVC, animated: true)
    }
}
