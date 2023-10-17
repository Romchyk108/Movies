//
//  MovieCountry.swift
//  Movies
//
//  Created by Roman Shestopal on 20.10.2023.
//

import Foundation

struct Country: Codable {
    let iso3166_1, englishName, nativeName: String

    enum CodingKeys: String, CodingKey {
        case iso3166_1 = "iso_3166_1"
        case englishName = "english_name"
        case nativeName = "native_name"
    }
}

typealias Countries = [Country]
