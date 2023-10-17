//
//  ViewController.swift
//  Movies
//
//  Created by Roman Shestopal on 17.10.2023.
//

import UIKit

class MainViewController: UIViewController {
    
    enum SortType {
        case rating, name, year
    }

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func tapSort(_ sender: UIBarButtonItem) {
        showSortPopup()
    }
    
    var presenter: MoviePresenter?
    var movies = [MovieCellModel]()
    var filteredMovies = [MovieCellModel]()
    var detailRouter: DetailViewRouter?
    
    private var selectedSorting: Int = 0
    
    private let refreshControl = UIRefreshControl()
    
    override func loadView() {
        super.loadView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailRouter = DetailViewRouter(viewController: self)
        
        presenter = MoviePresenter()
        presenter?.detailRouter = detailRouter
        presenter?.errorHandler = self
        presenter?.setMovieDelegate(delegate: self)
        presenter?.prepareMovies()
        
        tableView.register(MainMovieCell.self, forCellReuseIdentifier: MainMovieCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(updateMovies), for: .valueChanged)
    }
    
    @objc private func updateMovies() {
        presenter?.refreshMovies()
    }
    
    private func sortMovies(by type: SortType) {
        switch type {
        case .name:
            self.filteredMovies.sort(by: { $0.title < $1.title })
        case .rating:
            self.filteredMovies.sort(by: { $0.rating > $1.rating})
        case .year:
            self.filteredMovies.sort(by: { $0.year > $1.year })
        }
        tableView.reloadData()
    }
    
    private func showSortPopup() {
        let alert = UIAlertController(title: "Sorting", message: nil, preferredStyle: .actionSheet)
        let sortByName = UIAlertAction(title: "by Name", style: .default) { [weak self] _ in
            self?.sortMovies(by: .name)
            self?.selectedSorting = 1
        }
        sortByName.setValue(selectedSorting == 1, forKey: "checked")
        let sortByRating = UIAlertAction(title: "by Rating", style: .default) { [weak self] _ in
            self?.sortMovies(by: .rating)
            self?.selectedSorting = 2
        }
        sortByRating.setValue(selectedSorting == 2, forKey: "checked")
        let sortByYear = UIAlertAction(title: "by Year", style: .default) { [weak self] _ in
            self?.sortMovies(by: .year)
            self?.selectedSorting = 3
        }
        sortByYear.setValue(selectedSorting == 3, forKey: "checked")
        let dismiss = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(sortByName)
        alert.addAction(sortByYear)
        alert.addAction(sortByRating)
        alert.addAction(dismiss)
        present(alert, animated: true)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainMovieCell.identifier, for: indexPath) as? MainMovieCell else {
            return UITableViewCell()
        }
        cell.configure(movie: filteredMovies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter?.didTapMovie(movie: filteredMovies[indexPath.row])
    }
}

// MARK: MoviePresenterDelegate
extension MainViewController: MoviePresenterDelegate {
    func getMovies(movieModels movies: [MovieCellModel]) {
        self.movies = movies
        self.filteredMovies = movies
        DispatchQueue.main.async { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()
        }
    }
    
    func showDetail(movieModel movie: MovieDetail) {
        let alert = UIAlertController(title: movie.title, message: movie.overview, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}

extension MainViewController: ErrorHandlerProtocol {
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

extension MainViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText:String) {
        if !searchText.isEmpty {
            self.filteredMovies = self.movies.filter({ $0.title.lowercased().contains(searchText.lowercased()) })
        } else {
            filteredMovies = movies
        }
        tableView.reloadData()
    }
}
