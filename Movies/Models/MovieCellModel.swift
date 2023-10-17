//
//  MovieCell.swift
//  Movies
//
//  Created by Roman Shestopal on 19.10.2023.
//

import Foundation

struct MovieCellModel: Identifiable {
    let id: Int
    let title: String
    let year: String
    let genres: [String]
    let rating: Double
    let imageName: String
}
