//
//  AllCategoriesResponse.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 7/2/2024.
//

import Foundation
struct AllCategoriesResponse:Codable{
    let categories : Categories
    
}
struct Categories:Codable{
    let items : [Category]
}
struct Category : Codable {
    let id : String
    let name : String
    let icons : [ApiImage]
}
