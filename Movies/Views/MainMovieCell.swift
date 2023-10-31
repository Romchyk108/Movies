//
//  MainMovieCell.swift
//  Movies
//
//  Created by Roman Shestopal on 17.10.2023.
//

import UIKit
import SnapKit

class MainMovieCell: UITableViewCell {
    static var identifier = "MainMovieCell"
    
    private var titleLabel = UILabel()
    private var genresLabel = UILabel()
    private var ratingLabel = UILabel()
    private var backgroundImage = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(movie: MovieCellModel) {
        prepareBackground(movie: movie)
        prepareTitle(movie: movie)
        prepareGenresLabel(movie: movie)
        prepareRatingLabel(movie: movie)
    }
    
    private func prepareTitle(movie: MovieCellModel) {
        let font = UIFont.systemFont(ofSize: 17)
        guard let year = movie.year.components(separatedBy: "-").first else { return }
        let textLabel = "\(movie.title), \(year)"
        titleLabel.text = textLabel
        let widthText = UILabel.widthForLabel(text: textLabel, font: font, height: titleLabel.frame.height) + Constants.spacer
        if widthText > self.contentView.frame.width {
            titleLabel.preferredMaxLayoutWidth = self.contentView.frame.width - 2*Constants.spacer
        }
        titleLabel.numberOfLines = 0
        titleLabel.font = font
        titleLabel.textColor = .darkGray
        titleLabel.shadowColor = .white
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(Constants.spacer)
        }
    }
    
    private func prepareBackground(movie: MovieCellModel) {
        guard let firstPart = movie.imageName.components(separatedBy: ".").first,
              let lastPart = firstPart.components(separatedBy: "/").last else { return }
        let imageName = "." + lastPart + ".png"
        if let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first,
           let image = UIImage(contentsOfFile: path + imageName) {
            backgroundImage = UIImageView(image: image)
        } else {
            backgroundImage = UIImageView(image: UIImage(systemName: "photo"))
        }
        contentView.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(Constants.heightImage)
            make.width.equalTo(Constants.widthImage)
        }
    }
    
    private func prepareGenresLabel(movie: MovieCellModel) {
        let font = UIFont.systemFont(ofSize: 12)
        let genresText = movie.genres.joined(separator: ", ")
        genresLabel.text = genresText
        let widthText = UILabel.widthForLabel(text: genresText, font: font, height: genresLabel.frame.height)
        genresLabel.preferredMaxLayoutWidth = widthText >= (self.contentView.frame.width / 2) ? (self.contentView.frame.height / 2) : widthText
        genresLabel.numberOfLines = 0
        genresLabel.font = font
        genresLabel.textColor = .black
        genresLabel.backgroundColor = .lightGray
        contentView.addSubview(genresLabel)
        genresLabel.snp.makeConstraints { make in
            make.leading.equalTo(Constants.spacer)
            make.bottom.equalTo(-Constants.spacer)
        }
    }
    
    private func prepareRatingLabel(movie: MovieCellModel) {
        let font = UIFont.systemFont(ofSize: 12)
        ratingLabel.text = String(movie.rating)
        ratingLabel.font = font
        ratingLabel.textColor = .black
        ratingLabel.backgroundColor = .lightGray
        contentView.addSubview(ratingLabel)
        ratingLabel.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(-Constants.spacer)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private enum Constants {
        static let spacer: CGFloat = 30
        static let heightImage: CGFloat = 220
        static let widthImage: CGFloat = 150
    }
    
}
