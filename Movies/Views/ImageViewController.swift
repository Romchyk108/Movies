//
//  ImageViewController.swift
//  Movies
//
//  Created by Roman Shestopal on 24.10.2023.
//

import Foundation
import UIKit
import SnapKit

class ImageViewController: UIViewController {
    var imageView = UIImageView()
    var scrollView = UIScrollView()
    let imageName: String
    
    init(imageName: String) {
        self.imageName = imageName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.flashScrollIndicators()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        if let first = imageName.components(separatedBy: ".").first,
           let second = first.components(separatedBy: "/").last {
            let imageName = "." + second + ".png"
            if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
               let image = UIImage(contentsOfFile: path + imageName) {
                self.imageView = UIImageView(image: image)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                scrollView.addSubview(imageView)
                imageView.snp.makeConstraints { make in
                    make.top.bottom.equalTo(scrollView)
                    make.trailing.leading.equalTo(scrollView)
                }
            }
        }
    }
}

// MARK: UIScrollViewDelegate
extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
