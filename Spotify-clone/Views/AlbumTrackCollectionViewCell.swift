//
//  AlbumTrackCollectionViewCell.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 4/2/2024.
//

import Foundation
import UIKit
class AlbumTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "AlbumTrackCollectionViewCell"
    
    private let  albumCoverImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 4
        return imageView
    }()
    private let trackNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular)
        return label
    }()
  
    private let artistNameLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0

        label.font = .systemFont(ofSize: 15, weight: .thin)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.clipsToBounds = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        artistNameLabel.frame = CGRect(x: 10, y: contentView.height/2, width: contentView.width-15, height: contentView.height/2)
        
        trackNameLabel.frame = CGRect(x: 10, y: 0, width: contentView.width-15, height: contentView.height/2)
        
       

       
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }
    
    func configure(with viewModel : AlbumCellViewModel){
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        
    }
}
