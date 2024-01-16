//
//  PlayerControllerView.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 12/2/2024.
//

import Foundation
import UIKit


struct PlayerControlsViewViewModel{
    let title : String?
    let subtitle : String?
}

protocol PlayerControlseViewDelegate : AnyObject {
    func didTapPlayPause(_ playerControlView : PlayerControlsView)
    func didTapForward(_ playerControlView : PlayerControlsView)
    func didTapBackward(_ playerControlView : PlayerControlsView)
    func didSlideVolumelider(_ playerControlView : PlayerControlsView, didSlideSlider value : Float )
        
    
}

class PlayerControlsView:UIView {
    
    
    weak var delegate : PlayerControlseViewDelegate?
    
    private var isPlaying = true
    
    private  let  volumeSlider:UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        return slider
    }()
    private  let  nameLabel:UILabel = {
        let label = UILabel()
        label.text = "This Is My Song!"
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 22,weight: .semibold)
        return label
    }()
    
    private  let  subtitleLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.text = "Drake ft samara"
        label.font = .systemFont(ofSize: 18,weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let backButton : UIButton = {
        let btn = UIButton()
        btn.tintColor = .label
        let image = UIImage(systemName: "backward.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        btn.setImage(image, for: .normal)
        return btn
    }()
    private let playPauseButton : UIButton = {
        let btn = UIButton()
        btn.tintColor = .label
        let image = UIImage(systemName: "pause",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        btn.setImage(image, for: .normal)
        return btn
    }()
    private let forwardButton : UIButton = {
        let btn = UIButton()
        btn.tintColor = .label
        let image = UIImage(systemName: "forward.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        btn.setImage(image, for: .normal)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        addSubview(nameLabel)
        addSubview(subtitleLabel)
        addSubview(volumeSlider)
        addSubview(backButton)
        addSubview(playPauseButton)
        addSubview(forwardButton)
        
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(didTapForwardButton), for: .touchUpInside)
        volumeSlider.addTarget(self, action: #selector(didSlideSlider), for: .valueChanged)
        
        clipsToBounds = true
        
    }
    
    
    

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        nameLabel.frame = CGRect(x: 0, y: 0, width: width, height: 50)
        subtitleLabel.frame = CGRect(x: 0, y: nameLabel.bottom+10, width: width, height: 50)
        volumeSlider.frame = CGRect(x: 10, y: subtitleLabel.bottom+20, width: width-20, height: 44)
        
        
        let buttonSize : CGFloat = 60
        playPauseButton.frame = CGRect(x:( width-buttonSize)/2, y: volumeSlider.bottom+30, width: buttonSize, height: buttonSize)
        
        backButton.frame = CGRect(x: playPauseButton.left - 80-buttonSize, y: playPauseButton.top, width: buttonSize, height: buttonSize)
        
        forwardButton.frame = CGRect(x:playPauseButton.right + 80, y: volumeSlider.bottom+30, width: buttonSize, height: buttonSize)
      
        
    }
    
    
    @objc func didSlideSlider(_ slider : UISlider){
        let value = slider.value
        
        delegate?.didSlideVolumelider(self, didSlideSlider: value)
    }
    @objc func didTapBackButton(){
        delegate?.didTapBackward(self)
    }
    
    @objc func didTapPlayPauseButton(){
        
        let pause = UIImage(systemName: "pause",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        
        let play = UIImage(systemName: "play.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))

        self.isPlaying = !isPlaying
        delegate?.didTapPlayPause(self)
        playPauseButton.setImage(isPlaying ? pause : play, for: .normal)
    }
    
    @objc func didTapForwardButton(){
        delegate?.didTapForward(self)
    }
    
    
    func configure(with viewModel :PlayerControlsViewViewModel ){
        nameLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
    }
}
