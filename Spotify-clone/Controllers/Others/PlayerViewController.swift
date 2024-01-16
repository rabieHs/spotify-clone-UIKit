//
//  PlayerViewController.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 16/1/2024.
//

import UIKit
import SDWebImage

protocol PlayerViewControllerDelegate:AnyObject {
    func didTapPlayPause()
    func didTapForward()
    func didTapBackward()
    func didSlideSlider(value : Float)
}
class PlayerViewController: UIViewController {
    
    private let controlsView = PlayerControlsView()
    weak var datasource : PlayerDataSource?
    weak var delegate : PlayerViewControllerDelegate?

    
    private let coverImage : UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(coverImage)
        configurePlayerButton()
        view.addSubview(controlsView)
        controlsView.delegate = self
        configure()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        coverImage.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        controlsView.frame = CGRect(x: 10, y: coverImage.bottom + 10, width: view.width-20, height: view.height-coverImage.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom - 15
        )
        
        
        
    }
    
    func configurePlayerButton(){
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
    }
    
    @objc func didTapClose(){
        dismiss(animated: true)
    }
    
    @objc func didTapAction(){
        
        //actions
    }
    
    
    func configure(){
        coverImage.sd_setImage(with: datasource?.imageUrl)
        controlsView.configure(with: PlayerControlsViewViewModel(title: datasource?.songName, subtitle: datasource?.subtitle))
    }

    func refreshUI(){
        configure()
    }


}
extension PlayerViewController : PlayerControlseViewDelegate{
    func didSlideVolumelider(_ playerControlView: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value: value)
    }
    
    
    func didTapPlayPause(_ playerControlView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
    
    func didTapForward(_ playerControlView: PlayerControlsView) {
        delegate?.didTapForward()
    }
    
    func didTapBackward(_ playerControlView: PlayerControlsView) {
        delegate?.didTapBackward()
    }
    
   
    
    
}
