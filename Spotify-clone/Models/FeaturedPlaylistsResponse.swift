//
//  FeaturedPlaylistsResponse.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 20/1/2024.
//

import Foundation

struct FeaturedPlaylistsResponse : Codable {
    let playlists: PlaylistResponse
    
}
struct CategoryPlaylistsResponse : Codable {
    let playlists: PlaylistResponse
    
}

struct PlaylistResponse: Codable{
    let items : [Playlist]
}

struct User : Codable {
    let display_name : String
    let external_urls : [String:String]
    let id : String

}

