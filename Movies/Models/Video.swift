//
//  Video.swift
//  Movies
//
//  Created by Roman Shestopal on 23.10.2023.
//

import Foundation

class Video: Codable {
    let id: Int
    let results: [VideoDetail]
}

struct VideoDetail: Codable {
    let iso639_1: ISO639_1?
    let iso3166_1: ISO3166_1?
    let name: String?
    let key: String?
    let site: Site?
    let size: Int?
    let type: TypeEnum?
    let official: Bool?
    let publishedAt: String?
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case iso639_1 = "iso_639_1"
        case iso3166_1 = "iso_3166_1"
        case name, key, site, size, type, official
        case publishedAt = "published_at"
        case id
    }
}

enum ISO3166_1: String, Codable {
    case us = "US"
}

enum ISO639_1: String, Codable {
    case en = "en"
}

enum Site: String, Codable {
    case youTube = "YouTube"
    case vimeo = "Vimeo"
}

enum TypeEnum: String, Codable {
    case behindTheScenes = "Behind the Scenes"
    case clip = "Clip"
    case featurette = "Featurette"
    case teaser = "Teaser"
    case trailer = "Trailer"
}
