//
//  PlayerPresenter.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 12/2/2024.
//

import Foundation
import UIKit
import AVFoundation
protocol PlayerDataSource : AnyObject {
    var songName : String? {get}
    var subtitle : String? {get}
    var imageUrl : URL? {get}
}
final class PlayerPresenter {
    
    static let shared = PlayerPresenter()
    
    private var track : AudioTrack?
    private var tracks = [AudioTrack]()
    
    
    var playerVC: PlayerViewController?
    
    var player : AVPlayer?
    var playerQueue : AVQueuePlayer?
    
    var index = 0
    var currentTrack : AudioTrack?  {
        if let track = track, tracks.isEmpty {
            return track
        }else if let player = self.playerQueue, !tracks.isEmpty {
           
            
            return tracks[index]
            
        }
        return nil
    }
    
     func startPlayback(from viewController : UIViewController,track : AudioTrack){
         guard let url = URL(string: track.preview_url ?? "") else {return}
         player = AVPlayer(url: url)
         player?.volume = 0.5
         self.track = track
         self.tracks = []
        let vc = PlayerViewController()
        vc.title = track.name
         vc.datasource = self
         vc.delegate = self
         viewController.present(UINavigationController(rootViewController: vc), animated: true) {[weak self] in
             
             self?.player?.play()
         }
         self.playerVC = vc
        
    } 
    
     func startPlayback(from viewController : UIViewController,tracks : [AudioTrack]){
         
         let items :[AVPlayerItem] = tracks.compactMap({
             guard let url = URL(string: $0.preview_url ?? "") else {return nil}
           return  AVPlayerItem(url:url )
         })
         self.playerQueue?.volume = 0.5
         
         playerQueue = AVQueuePlayer(items: items)
         self.tracks = tracks
         self.track = nil
        
        let vc = PlayerViewController()
         vc.datasource = self
         vc.delegate = self

         viewController.present(UINavigationController(rootViewController: vc), animated: true) {
             [weak self] in
             self?.playerQueue?.play()
         }
         self.playerVC = vc
    }
    
   
}

extension PlayerPresenter : PlayerDataSource{
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageUrl: URL? {
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
    
    
}

extension PlayerPresenter :PlayerViewControllerDelegate{
    func didSlideSlider(value: Float) {
        player?.volume = value
        playerQueue?.volume = value
    }
    
    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            }else if player.timeControlStatus == .paused {
                player.play()
            }
        } 
        
        else if let playerQueue = playerQueue {
            if playerQueue.timeControlStatus == .playing {
                playerQueue.pause()
            }else if playerQueue.timeControlStatus == .paused {
                playerQueue.play()
            }
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty{
            player?.pause()
        }else{
            playerQueue?.advanceToNextItem()
            index+=1
            playerVC?.refreshUI()
        }
    }
    
    func didTapBackward() {
        if tracks.isEmpty{
            player?.pause()
            player?.play()
        }else if let firstItem = playerQueue?.items().first{
            
            playerQueue?.pause()
           // playerQueue?.removeAllItems()
            //playerQueue = AVQueuePlayer(items: [firstItem])
            playerQueue?.play()
            playerQueue?.volume = 0.5
        }
    }
    
    
}
