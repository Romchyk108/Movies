//
//  Presenter.swift
//  Movies
//
//  Created by Roman Shestopal on 18.10.2023.
//

import Foundation
import UIKit
import Network

protocol MoviePresenterDelegate: AnyObject {
    func getMovies(movieModels: [MovieCellModel])
    func showDetail(movieModel: MovieDetail)
}

final class MoviePresenter {
    weak var delegate: MoviePresenterDelegate?
    weak var detailRouter: DetailViewRouting?
    weak var errorHandler: ErrorHandlerProtocol?
    
    private var movies: Movies? 
    private var languages = [MovieLanguage]()
    private var movieGenres = [MovieGenre]()
    private var movieDetails = [MovieDetail]()
    private var movieCellModels = [MovieCellModel]()
    private let monitorConnection = NWPathMonitor()
    private var imageNames = [String]()
    
    private let headers = ["accept": "application/json",
                           "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkOGNiYWNkMGQzZDA2NjYyMzUxM2EwZGIzYTkxYmU4MSIsInN1YiI6IjY1MmZlYzgyMDI0ZWM4MDBjNzc2OGZiNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.vNlj8Llox6PYxa8mgso0Y90-R7Xjve-QYx_NNC4QSRc"]
    
    func setMovieDelegate(delegate: MoviePresenterDelegate) {
        self.delegate = delegate
    }
    
    func prepareMovies() {
        checkConnection()
        Spinner.start()
        DispatchQueue.global().async { [weak self] in
            self?.fetchMovieGenres()
            self?.fetchMovies { [weak self] in
                self?.fetchImages()
                self?.convertToMovieCellModel()
            }
        }
        convertToMovieCellModel()
    }
    
    func refreshMovies() {
        checkConnection()
        Spinner.start()
        DispatchQueue.global().async { [weak self] in
            self?.fetchMovies { [weak self] in
                self?.fetchImages()
                self?.convertToMovieCellModel()
            }
        }
    }
    
    func getMovieDetails() -> [MovieDetail] {
        return self.movieDetails
    }
    
    func didTapMovie(movie: MovieCellModel) {
        if let detail = movieDetails.first(where: { $0.id == movie.id }) {
            detailRouter?.showDetailView(detailModel: detail)
        } else {
            checkConnection()
            Spinner.start()
            fetchMovieDetail(for: movie.id, completion: { [weak self] detail in
                DispatchQueue.main.async { [weak self] in
                    Spinner.stop()
                    self?.detailRouter?.showDetailView(detailModel: detail)
                }
            })
        }
    }
    
    func checkConnection() {
        monitorConnection.pathUpdateHandler = { [weak self] path in
            if path.status != .satisfied {
                self?.errorHandler?.showErrorAlert(title: "You are offline. Please, enable your Wi-Fi or connect using cellular data.", message: nil, dismissCompletion: { [weak self] in
                    self?.monitorConnection.cancel()
                    Spinner.stop()
                })
            }
           print(path.isExpensive)
        }
        monitorConnection.start(queue: DispatchQueue(label: "Monitor"))
    }
    
    private func fetchMovies(completion: (()->())?) {
        let request = getRequest(url: NSURL(string: "https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&page=1&sort_by=popularity.desc")! as URL)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { [weak self] (data, response, error) -> Void in
            if (error != nil) {
                self?.errorHandler?.showErrorAlert(title: "Error", message: "\(error?.localizedDescription ?? "") - \(#function)", dismissCompletion: nil)
            } else {
                guard let self, let data else { return }
                do {
                    let result = try JSONDecoder().decode(Movies.self, from: data)
                    self.movies = result
                    completion?()
                } catch {
                    self.errorHandler?.showErrorAlert(title: "Error", message: "\(error.localizedDescription)) - \(#function)", dismissCompletion: nil)
                }
            }
        })
        dataTask.resume()
    }
    
    private func fetchImages() {
        movies?.results.forEach({ [weak self] movie in
            guard let self else { return }
            self.fetchImages(for: movie)
        })
    }
    
    private func fetchImages(for movie: Movie) {
        fetchImages(from: movie.backdropPath)
        fetchImages(from: movie.posterPath)
    }
    
    private func fetchImages(from path: String) {
        guard let url = URL(string: "https://image.tmdb.org/t/p/w500" + path) else { return }
        let request = URLRequest(url: url)
        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) -> Void in
            guard let self,
                  let data,
                  error == nil,
                  let imageName = path.components(separatedBy: ".").first?.components(separatedBy: "/").last
            else {
                self?.errorHandler?.showErrorAlert(title: "Error", message: "\(error?.localizedDescription ?? "") - \(#function)", dismissCompletion: nil)
                return
            }
            let fileName = getDocumentsDirectory().appendingPathExtension("\(imageName).png")
            do {
                if !FileManager.default.fileExists(atPath: fileName.path) {
                    try data.write(to: fileName)
                    imageNames.append("\(path)")
                }
            } catch {
                self.errorHandler?.showErrorAlert(title: "Error", message: "\(error.localizedDescription) - \(#function)", dismissCompletion: nil)
            }
        }
        dataTask.resume()
    }
    
    private func fetchMovieDetail(for id: Int, completion: @escaping (MovieDetail)->()) {
        let urlString = "https://api.themoviedb.org/3/movie/\(id)"
        guard let url = NSURL(string: urlString) as? URL else { return }
        let request = getRequest(url: url)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { [weak self] data, _, error in
            guard let data, let self, error == nil else {
                self?.errorHandler?.showErrorAlert(title: "Error", message: "\(error?.localizedDescription ?? "") - \(#function)", dismissCompletion: nil)
                return
            }
            do {
                let movieDetail = try JSONDecoder().decode(MovieDetail.self, from: data)
                if !self.movieDetails.contains(where: { $0.id == movieDetail.id }) {
                    self.movieDetails.append(movieDetail)
                }
                completion(movieDetail)
            } catch {
                self.errorHandler?.showErrorAlert(title: "Error", message: "\(error.localizedDescription) - \(#function)", dismissCompletion: nil)
            }
        }
        task.resume()
    }
    
    private func fetchMovieGenres() {
        guard let url = URL(string: "https://api.themoviedb.org/3/genre/movie/list") else { return }
        let request = getRequest(url: url)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { [weak self] data, _, error in
            guard let data, let self, error == nil else {
                self?.errorHandler?.showErrorAlert(title: "Error", message: "\(error?.localizedDescription ?? "") - \(#function)", dismissCompletion: nil)
                return
            }
            do {
                let genres = try JSONDecoder().decode(MassifGenres.self, from: data)
                self.movieGenres = genres.genres
            } catch {
                self.errorHandler?.showErrorAlert(title: "Error", message: "\(error.localizedDescription) - \(#function)", dismissCompletion: nil)
            }
        }
        task.resume()
    }
    
    private func getRequest(url: URL) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 20.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        return request
    }
    
    private func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    private func convertToMovieCellModel() {
        guard let movies = movies?.results else { return }
        movies.forEach { [weak self] movie in
            guard let self else { return }
            let filteredGenres = self.movieGenres.filter({ movie.genreIDS.contains($0.id) })
            let genres = filteredGenres.map({ $0.name })
            let movieCell = MovieCellModel(id: movie.id, title: movie.title, year: movie.releaseDate, genres: genres, rating: movie.voteAverage, imageName: movie.backdropPath)
            if !self.movieCellModels.contains(where: { $0.id == movieCell.id }) {
                self.movieCellModels.append(movieCell)
            }
        }
        Spinner.stop()
        self.delegate?.getMovies(movieModels: self.movieCellModels)
    }
}
