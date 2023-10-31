//
//  ImageCollectionCell.swift
//  Movies
//
//  Created by Roman Shestopal on 30.10.2023.
//

import Foundation
import UIKit
import SnapKit

class ImageCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "ImageCollectionCell"
    static var widthCell: CGFloat = 350
    
    private var imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(imageName: String) {
        guard let firstPart = imageName.components(separatedBy: ".").first,
              let lastPart = firstPart.components(separatedBy: "/").last else { return }
        let imageName = "." + lastPart + ".png"
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
           let image = UIImage(contentsOfFile: path + imageName) {
            imageView.image = image
            contentView.addSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.top.leading.trailing.equalToSuperview()
                make.height.equalTo(500)
            }
        }
    }
}
