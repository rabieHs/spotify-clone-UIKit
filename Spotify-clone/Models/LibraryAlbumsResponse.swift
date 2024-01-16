//
//  LibraryAlbumsResponse.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 18/2/2024.
//

import Foundation
struct LibraryAlbumsResponse : Codable{
    let items: [SavedAlbum]
}

struct SavedAlbum : Codable {
    let added_at : String
    let album : Album
}
