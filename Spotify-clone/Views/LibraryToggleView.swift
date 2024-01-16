//
//  LibraryToggleView.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/2/2024.
//

import UIKit

protocol LibraryToggleViewDelegate : AnyObject {
    func didTapPlaylists(_ toggleView: LibraryToggleView)
    func didTapAlbums(_ toggleView: LibraryToggleView)
        
}

class LibraryToggleView: UIView {
    
    enum State{
        case Playlist
        case Album
    }
    
    var state:State = .Playlist
    weak var delegate : LibraryToggleViewDelegate?
    
    private let playlistsButton : UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.label, for: .normal)
        btn.setTitle("Playlists", for: .normal)
        return btn
    }()
    
    private let albumsButton : UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.label, for: .normal)
        btn.setTitle("Albums", for: .normal)
        return btn
    }()
    
    private let indicatorView : UIView = {
        let indicator  = UIView()
        indicator.backgroundColor = .systemGreen
        indicator.layer.masksToBounds = true
        indicator.layer.cornerRadius = 4
        return indicator
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(playlistsButton)
        addSubview(albumsButton)
        addSubview(indicatorView)
        playlistsButton.addTarget(self, action: #selector(didTapPlaylists), for: .touchUpInside)
        
        albumsButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playlistsButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        albumsButton.frame = CGRect(x: playlistsButton.right, y: 0, width: 100, height: 40)
       layoutIndicator()
    }
    
    
    @objc func didTapPlaylists(){
        state = .Playlist
        delegate?.didTapPlaylists(self)
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        
    }
    
    @objc func didTapAlbums(){
        state = .Album
        delegate?.didTapAlbums(self)
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        
    }
    
    
    func layoutIndicator(){
        switch state {
        case .Playlist:
            indicatorView.frame = CGRect(x: 0, y: playlistsButton.bottom, width: 100, height: 3)

        case .Album:
            indicatorView.frame = CGRect(x: 100, y: playlistsButton.bottom, width: 100, height: 3)

        }
    }
    
    
    func update(for state: State){
        self.state = state
        UIView.animate(withDuration: 0.2) {
            self.layoutIndicator()
        }
        
    }
    
    

}
