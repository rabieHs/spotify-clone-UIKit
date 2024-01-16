//
//  Artist.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/1/2024.
//

import Foundation
struct Artist : Codable{
    let id : String
    let name : String
    let type: String
    let images: [ApiImage]?
    let external_urls : [String:String]
}
