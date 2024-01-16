//
//  SearchResult.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 9/2/2024.
//

import Foundation

enum SearchResult{
    case artist(model:Artist)
    case album(model: Album)
    case track(model : AudioTrack)
    case playlist(model: Playlist)
}

