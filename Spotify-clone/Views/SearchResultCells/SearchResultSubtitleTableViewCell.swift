//
//  SearchResultDefaultTableViewCell.swift
//  Spotify-clone
//
//  Created by rabie houssaini on 11/2/2024.
//

import UIKit
import SDWebImage




class SearchResultSubtitleTableViewCell: UITableViewCell {

static let identifier = "SearchResultSubtitleTableViewCell"
    
    
    let label : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    let subtitleLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .secondaryLabel
        return label
    }()
    
    
    let iconImageView : UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height - 10
        let labelHeight = contentView.height / 2
        iconImageView.frame = CGRect(x: 10, y: 5, width: imageSize, height: imageSize)
   
        label.frame = CGRect(x: iconImageView.right + 10 , y: 0, width: contentView.width-iconImageView.right - 15, height: labelHeight)
        
        subtitleLabel.frame = CGRect(x: iconImageView.right + 10 , y: label.bottom, width: contentView.width-iconImageView.right - 15, height: labelHeight)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        subtitleLabel.text = nil
    }
    
    func configure(with viewModel : SearchResultSubtitleTableViewCellViewModel){
        label.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        iconImageView.sd_setImage(with: viewModel.artworkURL, placeholderImage: UIImage(systemName: "music.note.list",withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .thin)))
    }
    
}
