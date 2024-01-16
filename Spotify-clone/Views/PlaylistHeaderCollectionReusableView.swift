//
//  PlaylistHeaderCollectionReusableView.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 3/2/2024.
//

import UIKit
import SDWebImage

protocol PlaylistHeaderCollectionReusableViewDelegate: AnyObject {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header :PlaylistHeaderCollectionReusableView )
}

final class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
    weak var delegate:PlaylistHeaderCollectionReusableViewDelegate?
        static let identifier = "PlaylistHeaderCollectionReusableView"
    private let nameLabel : UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    private let descriptionLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    private let ownerLabel : UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel

        label.font = .systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    private let imageView:UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "photo")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let playAllButton:UIButton = {
        let image = UIImage(systemName: "play.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular))
        let btn = UIButton(type: .system)
        btn.backgroundColor = .systemGreen
        btn.setImage(image, for: .normal)
        btn.tintColor = .white
        btn.layer.cornerRadius = 30
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
        return btn
    }()
    
    //MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(ownerLabel)
        addSubview(playAllButton)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize : CGFloat = height/1.8
        imageView.frame = CGRect(x: (width-imageSize)/2, y: 20, width: imageSize, height: imageSize)
        nameLabel.frame = CGRect(x: 10, y: imageView.bottom, width: width-20, height: 44)
        descriptionLabel.frame = CGRect(x: 10, y: nameLabel.bottom, width: width-20, height: 44)
        ownerLabel.frame = CGRect(x: 10, y: descriptionLabel.bottom, width: width-20, height: 44)
        playAllButton.frame = CGRect(x: width-80, y: height-80, width: 60, height: 60)

    }
    
    func configure(with viewModel:PlaylistHeaderViewModel){
        nameLabel.text = viewModel.name
        ownerLabel.text = viewModel.ownerName
        descriptionLabel.text = viewModel.description
        imageView.sd_setImage(with: viewModel.artworkURL,placeholderImage: UIImage(systemName: "music.note"))
    }
    @objc func didTapPlayAll(){
        delegate?.playlistHeaderCollectionReusableViewDidTapPlayAll(self)
    }
    
}
