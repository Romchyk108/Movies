//
//  MovieDetailPresenter.swift
//  Movies
//
//  Created by Roman Shestopal on 23.10.2023.
//

import Foundation
import UIKit

protocol ImagePresenterDelegate: AnyObject {
    func getImages(names: [String])
}

class MovieDetailPresenter {
    weak var delegate: ImagePresenterDelegate?
    weak var videoRouter: VideoRouting?
    weak var errorHandler: ErrorHandlerProtocol?
    
    private let header = [
        "accept": "application/json",
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkOGNiYWNkMGQzZDA2NjYyMzUxM2EwZGIzYTkxYmU4MSIsInN1YiI6IjY1MmZlYzgyMDI0ZWM4MDBjNzc2OGZiNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.vNlj8Llox6PYxa8mgso0Y90-R7Xjve-QYx_NNC4QSRc"
      ]
    
    func getVideo(id: Int) {
        fetchVideo(id: id) { [weak self] detail in
            DispatchQueue.main.async { [weak self] in
                self?.videoRouter?.showVideoPlayer(url: self?.prepareLink(videoDetail: detail))
            }
        }
    }
    
    func getImages(id: Int) {
        fetchImages(id: id) { [weak self] names in
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.getImages(names: names)
            }
        }
    }
    
    private func fetchImages(id: Int, completion: (([String])->())?) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/movie/\(id)/images")! as URL,
                                                cachePolicy: .useProtocolCachePolicy,
                                            timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = header

        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { [weak self] (data, response, error) -> Void in
          if (error != nil) {
              self?.errorHandler?.showErrorAlert(title: "Error", message: "\(error?.localizedDescription ?? "") - \(#function)", dismissCompletion: nil)
          } else {
              guard let self, let data else { return }
              do {
                  let images = try JSONDecoder().decode(ImageMovieDetails.self, from: data)
                  let posterNames: [String] = images.posters.compactMap{ $0.filePath }
                  
                  let maxPosters = posterNames.count > 9 ? 9 : (posterNames.count - 1)
                  var maxPosterNames = [String]()
                  for item in (0...maxPosters) {
                      downloadImages(path: posterNames[item])
                      maxPosterNames.append(posterNames[item])
                  }
                  completion?(maxPosterNames)
              }
              catch {
                  self.errorHandler?.showErrorAlert(title: "Error", message: "\(error.localizedDescription) - \(#function)", dismissCompletion: nil)
              }
          }
        })

        dataTask.resume()
    }
    
    private func downloadImages(path: String) {
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
                }
            } catch {
                self.errorHandler?.showErrorAlert(title: "Error", message: "\(error.localizedDescription) - \(#function)", dismissCompletion: nil)
            }
        }
        dataTask.resume()
    }
    
    private func fetchVideo(id: Int, completion: ((VideoDetail?)->())?) {
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.themoviedb.org/3/movie/\(id)/videos?api_key=d8cbacd0d3d066623513a0db3a91be81")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = header
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error?.localizedDescription as Any)
            } else {
                guard let data else { return }
                do {
                    let video = try JSONDecoder().decode(Video.self, from: data)
                    completion?(video.results.first)
                } catch {
                    print(error.localizedDescription)
                }
            }
        })
        
        dataTask.resume()
    }
    
    private func prepareLink(videoDetail: VideoDetail?) -> URL? {
        guard let detail = videoDetail, let key = detail.key, let site = detail.site else { return nil }
        var link: String
        switch site {
        case .youTube:
            link = "https://www.youtube.com/watch?v=" + key
        case.vimeo:
            link = "https://vimeo.com/" + key
        }
        return URL(string: link)
    }
    
    private func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
}
