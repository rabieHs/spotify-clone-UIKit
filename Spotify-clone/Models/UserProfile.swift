//
//  UserProfile.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/1/2024.
//

import Foundation
struct UserProfile : Codable{
    let country : String
    let display_name: String
    let explicit_content : [String : Bool]
    let external_urls: [String : String]
   // let followers: [String : Codable]
   let id : String
    let product: String
    let images : [ApiImage]?
    let email : String
    
}




