//
//  ChatPostCell.swift
//  Translation
//
//  Created by Kazuya Okamoto on 2017/03/04.
//  Copyright © 2017年 Try! Swift. All rights reserved.
//

import UIKit

private let margin: CGFloat = -8

class ChatPostCell: UITableViewCell {
    
    let titleLabel = PaddingLabel()
    let activeColor = UIColor(displayP3Red: 0, green: 166/255, blue: 233/255, alpha: 1.0)
    
    func fill(text: String, isTranslated: Bool) {
        titleLabel.text = isTranslated ? "\(text)" : text
        
    }
    
    open func initViews() {
        backgroundColor = UIColor(displayP3Red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        contentView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: margin).isActive = true
        contentView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -margin).isActive = true
        titleLabel.numberOfLines = 0
        titleLabel.layer.cornerRadius = 5
        titleLabel.clipsToBounds = true
        
        transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)

    }
    
}

class LeftCell: ChatPostCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initViews()
    }
    
    override func initViews() {
        super.initViews()
        contentView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: margin).isActive = true
        contentView.trailingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: -margin * 4).isActive = true
        
        titleLabel.backgroundColor = activeColor
        titleLabel.textColor = .white
    }
    
}

class RightCell: ChatPostCell {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initViews()
    }
    
    override func initViews() {
        super.initViews()
        titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: -margin * 4).isActive = true
        contentView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: -margin).isActive = true
        
        titleLabel.backgroundColor = .white
        titleLabel.textColor = .black
    }
    
}

