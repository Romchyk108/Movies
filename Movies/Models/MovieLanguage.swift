//
//  MovieLanguage.swift
//  Movies
//
//  Created by Roman Shestopal on 19.10.2023.
//

import Foundation

struct MovieLanguage: Codable {
    let iso639_1, englishName, name: String
    
    enum CodingKeys: String, CodingKey {
        case iso639_1 = "iso_639_1"
        case englishName = "english_name"
        case name
    }
}

typealias MovieLanguages = [MovieLanguage]
