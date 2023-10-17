//
//  DetailViewRouter.swift
//  Movies
//
//  Created by Roman Shestopal on 21.10.2023.
//

import Foundation
import UIKit


protocol DetailViewRouting: AnyObject {
    func showDetailView(detailModel: MovieDetail)
}

final class DetailViewRouter: DetailViewRouting {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
    
    func showDetailView(detailModel: MovieDetail) {
        let detailController = MovieDetailViewController(model: detailModel)
        viewController?.show(detailController, sender: nil)
    }
}
