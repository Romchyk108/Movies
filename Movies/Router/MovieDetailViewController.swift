//
//  MovieDetailViewController.swift
//  Movies
//
//  Created by Roman Shestopal on 21.10.2023.
//

import UIKit
import SnapKit
import AVFoundation

class MovieDetailViewController: UIViewController {
    
    private var imageView = UIImageView()
    private let nameLabel = UILabel()
    private let countryWithYearLabel = UILabel()
    private let genresLabel = UILabel()
    private let trailerButton = UIButton()
    private let ratingLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let container = UIView()
    private let scrollView = UIScrollView()
    private var imagesCollection: UICollectionView?
    
    private var imageNames = [String]()
    
    var detailPresenter: MovieDetailPresenter?
    var videoRouter: VideoRouter?
    var imageRouter: ImageRouter?
    
    private var model: MovieDetail
    
    init(model: MovieDetail) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoRouter = VideoRouter(viewController: self)
        imageRouter = ImageRouter(viewController: self)
        
        detailPresenter = MovieDetailPresenter()
        detailPresenter?.delegate = self
        detailPresenter?.videoRouter = videoRouter
        detailPresenter?.errorHandler = self
        detailPresenter?.getImages(id: model.id)

        view.backgroundColor = .white
        setupCollection()
        setupNameLabel()
        setupCountryWithYearLabel()
        setupGenresLabel()
        setupRatingLabel()
        setupTrailerButton()
        setupDescriptionLabel()
        
        setupScrollView()
        setupContainer()
        imagesCollection?.reloadData()
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupContainer() {
        container.backgroundColor = .white
        container.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(container)
        container.snp.makeConstraints { make in
            make.top.bottom.equalTo(scrollView)
            make.trailing.leading.equalTo(view)
        }
    }
    
    private func setupCollection() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: ImageCollectionCell.widthCell, height: Constants.heightImage)
        layout.scrollDirection = .horizontal
        
        imagesCollection = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        guard let imagesCollection else { return }
        imagesCollection.register(ImageCollectionCell.self, forCellWithReuseIdentifier: ImageCollectionCell.reuseIdentifier)
        imagesCollection.dataSource = self
        imagesCollection.delegate = self
        
        container.addSubview(imagesCollection)
        imagesCollection.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(container)
            make.height.equalTo(Constants.heightImage)
        }
        self.imagesCollection = imagesCollection
    }
    
    private func setupDescriptionLabel() {
        setupLabel(text: model.overview, label: descriptionLabel, font: .systemFont(ofSize: 13), textAlignment: .left)
        container.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(model.video ? trailerButton.snp.bottom : ratingLabel.snp.bottom).offset(Constants.verticalSpacing)
            make.leading.equalTo(container).offset(Constants.horizontalSpacing)
            make.trailing.bottom.equalTo(container).offset(-Constants.horizontalSpacing)
        }
    }
    
    private func setupTrailerButton() {
        trailerButton.isHidden = !model.video
        let imageButton = UIImage(systemName: "play.rectangle", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .large))
        trailerButton.setImage(imageButton, for: .normal)
        container.addSubview(trailerButton)
        trailerButton.addTarget(self, action: #selector(tappedTrailerButton), for: .touchUpInside)
        trailerButton.snp.makeConstraints { make in
            make.leading.equalTo(container).offset(Constants.horizontalSpacing)
            make.trailing.lessThanOrEqualTo(ratingLabel)
            make.top.equalTo(genresLabel.snp.bottom).offset(0.5*Constants.verticalSpacing)
            make.width.equalTo(Constants.sizeTrailerButton)
        }
    }
    
    @objc private func tappedTrailerButton() {
        detailPresenter?.getVideo(id: model.id)
    }
    
    @objc private func presentImage(poster: String) {
        imageRouter?.showImage(imageName: poster)
    }
    
    private func setupRatingLabel() {
        let textLabel = "Rating: \(String(format: "%.1f", model.voteAverage))"
        setupLabel(text: textLabel, label: ratingLabel, font: .boldSystemFont(ofSize: 15), textAlignment: .left)
        container.addSubview(ratingLabel)
        ratingLabel.snp.makeConstraints { make in
            make.top.equalTo(genresLabel.snp.bottom).offset(0.5*Constants.verticalSpacing)
            make.trailing.equalTo(container).offset(-Constants.horizontalSpacing)
        }
    }
    
    private func setupGenresLabel() {
        let textLabel = model.genres.map{ $0.name }.joined(separator: ", ")
        setupLabel(text: textLabel, label: genresLabel, font: .systemFont(ofSize: 15), textAlignment: .left)
        container.addSubview(genresLabel)
        genresLabel.snp.makeConstraints { make in
            make.top.equalTo(countryWithYearLabel.snp.bottom).offset(Constants.verticalSpacing)
            make.leading.equalTo(container).offset(Constants.horizontalSpacing)
            make.trailing.equalTo(container).offset(-Constants.horizontalSpacing)
        }
    }
    
    private func setupCountryWithYearLabel() {
        let textLabel = model.productionCountries.map{ $0.name }.joined(separator: ", ") + ", " + (model.releaseDate.components(separatedBy: "-").first ?? "")
        setupLabel(text: textLabel, label: countryWithYearLabel, font: .systemFont(ofSize: 15), textAlignment: .left)
        container.addSubview(countryWithYearLabel)
        countryWithYearLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(Constants.verticalSpacing)
            make.leading.equalTo(container).offset(Constants.horizontalSpacing)
            make.trailing.equalTo(container).offset(-Constants.horizontalSpacing)
        }
    }
    
    private func setupNameLabel() {
        setupLabel(text: model.title, label: nameLabel, font: .systemFont(ofSize: 17), textAlignment: .left)
        container.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(container).offset(Constants.horizontalSpacing)
            if let imagesCollection {
                make.top.equalTo(imagesCollection.snp.bottom).offset(Constants.verticalSpacing)
            } else {
                make.top.equalToSuperview().offset(Constants.verticalSpacing)
            }
            make.trailing.equalTo(container).offset(-Constants.horizontalSpacing)
        }
    }
    
    private func setupLabel(text: String, label: UILabel, font: UIFont, textAlignment: NSTextAlignment) {
        label.text = text
        let widthLabel = UILabel.widthForLabel(text: text, font: font, height: label.frame.height) + 2*Constants.horizontalSpacing
        if widthLabel > view.frame.width {
            label.preferredMaxLayoutWidth = view.frame.width - 2*Constants.horizontalSpacing
        }
        label.numberOfLines = 0
        label.textAlignment = textAlignment
        label.font = font
        label.textColor = .black
    }
    
    private enum Constants {
        static let verticalSpacing: CGFloat = 20
        static let horizontalSpacing: CGFloat = 30
        static let heightImage: CGFloat = 500
        static let sizeTrailerButton: CGFloat = 50
    }
}

extension MovieDetailViewController: ImagePresenterDelegate {
    func getImages(names: [String]) {
        self.imageNames = names
        imagesCollection?.reloadData()
    }
}

extension MovieDetailViewController: ErrorHandlerProtocol {
    func showErrorAlert(title: String, message: String?, dismissCompletion: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .cancel) { _ in
            dismissCompletion?()
        }
        alert.addAction(action)
        Spinner.stop()
        if Thread.isMainThread {
            self.present(alert, animated: true)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.present(alert, animated: true)
            }
        }
    }
}

extension MovieDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionCell.reuseIdentifier, for: indexPath) as? ImageCollectionCell else {
            return UICollectionViewCell()
        }
        cell.config(imageName: imageNames[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presentImage(poster: imageNames[indexPath.row])
    }
}
