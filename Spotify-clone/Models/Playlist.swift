//
//  Playlist.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/1/2024.
//

import Foundation
struct  Playlist : Codable {
    let description : String
    let external_urls : [String:String]
    let id : String
    let images: [ApiImage]
    let name : String
    let owner : User
}
