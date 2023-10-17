//
//  MovieDetailPresenter.swift
//  Movies
//
//  Created by Roman Shestopal on 23.10.2023.
//

import Foundation
import UIKit

protocol VideoPresenterDelegate: AnyObject {
    func showVideo(video: Video)
}

class MovieDetailPresenter {
    weak var delegate: VideoPresenterDelegate?
    weak var videoRouter: VideoRouting?
    weak var errorHandler: ErrorHandlerProtocol?
    
    private let header = [
        "accept": "application/json",
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkOGNiYWNkMGQzZDA2NjYyMzUxM2EwZGIzYTkxYmU4MSIsInN1YiI6IjY1MmZlYzgyMDI0ZWM4MDBjNzc2OGZiNCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.vNlj8Llox6PYxa8mgso0Y90-R7Xjve-QYx_NNC4QSRc"
      ]
    
    var images = [String]()
    
    func getVideo(id: Int) {
        fetchVideo(id: id) { [weak self] detail in
            DispatchQueue.main.async { [weak self] in
                self?.videoRouter?.showVideoPlayer(url: self?.prepareLink(videoDetail: detail))
            }
        }
    }
    
    func getImages(id: String) {
        
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
              }
              
              catch {
                  self.errorHandler?.showErrorAlert(title: "Error", message: "\(error.localizedDescription) - \(#function)", dismissCompletion: nil)
              }
          }
        })

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
}
