//
//  SettingsModels.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 18/1/2024.
//

import Foundation
struct Section {
    let title : String
    let options : [Options]
}
struct Options{
    let title:String
    let handler : ()->Void
}
