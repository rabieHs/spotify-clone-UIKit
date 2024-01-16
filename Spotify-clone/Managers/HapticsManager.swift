//
//  HapticsManager.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/1/2024.
//

import Foundation
import UIKit
class HapticsManager {
    static let shared = HapticsManager()
    
    private init(){
        
    }
    
    public func vibrateForSelection(){
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()
            generator.selectionChanged()
        }
    }
    
    public func vibrate(for type : UINotificationFeedbackGenerator.FeedbackType){
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }
}
