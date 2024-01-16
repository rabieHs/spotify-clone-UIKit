//
//  PlaylistDetailsResponse.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 3/2/2024.
//

import Foundation
struct PlaylistDetailsResponse: Codable {
    let description:String
    let external_urls:[String:String]
    let id:String
    let images:[ApiImage]
    let name:String
    let tracks :PlaylistTracksResponse
    
    
    
}
struct PlaylistTracksResponse : Codable{
    let items: [PlaylistItem]
}
struct PlaylistItem: Codable {
    let track: AudioTrack
}
