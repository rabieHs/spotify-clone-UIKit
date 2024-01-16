//
//  LibraryViewController.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/1/2024.
//

import UIKit

class LibraryViewController: UIViewController {
    
   private let playlistsVC = LibraryPlaylistsViewController()
    private let albumsVC = LibraryAlbumsViewController()
    
    private let toggleView = LibraryToggleView()
    
    private let scrollView:UIScrollView = {
        let scrollView = UIScrollView()
        
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        view.addSubview(toggleView)
        toggleView.delegate = self
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: view.width*2, height: scrollView.height)
        
        addChilder()
        updateBarButton()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.width, height: view.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-55)
        toggleView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: 200, height: 55)
        
    }
    
    
    private func addChilder(){
        addChild(playlistsVC)
        scrollView.addSubview(playlistsVC.view)
        playlistsVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
        playlistsVC.didMove(toParent: self)
        
        
        addChild(albumsVC)
        scrollView.addSubview(albumsVC.view)
        albumsVC.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height)
        albumsVC.didMove(toParent: self)
    }

    
}
extension LibraryViewController : UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x >= (view.width-(view.width/2)){
            toggleView.update(for: .Album)
            updateBarButton()
        }else{
            toggleView.update(for: .Playlist)
            updateBarButton()
        }
    }
    
    
}
extension LibraryViewController : LibraryToggleViewDelegate{
    func didTapPlaylists(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        updateBarButton()
    }
    
    func didTapAlbums(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: view.width , y: 0), animated: true)
        updateBarButton()

    }
    
    private func  updateBarButton(){
        switch toggleView.state {
        case .Playlist:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        case .Album:
            navigationItem.rightBarButtonItem = nil
        }
    }

    
    @objc func didTapAdd(){
        playlistsVC.showCreationUI()
    }
}
