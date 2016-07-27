//
//  HHMessageTimeCell.swift
//  WJMessage
//
//  Created by apple on 16/7/6.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

class HHMessageTimeCell: UITableViewCell {
    
    static let MessageTimeCellPadding:CGFloat = 5.0
    static let cellIdentifier = "HHMessageTimeCell"
    
    var title = "" {
        didSet {
            self.titleLabel?.text = title
        }
    }
    
    var titleLabel: UILabel?
    var titleLabelColor: UIColor? {
        didSet {
            self.titleLabel?.textColor = self.titleLabelColor
        }
    }
    var titleLabelFont: UIFont? {
        didSet {
            self.titleLabel?.font = self.titleLabelFont
        }
    }
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        _setupSubView()
    }
    private func _setupSubView() {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.titleLabel = UILabel()
        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel?.backgroundColor = UIColor.clearColor()
        self.titleLabel?.textColor = self.titleLabelColor
        self.titleLabel?.font = self.titleLabelFont
        self.titleLabel?.textAlignment = .Center
        self.contentView.addSubview(self.titleLabel!)
        _setupTitleLabelConstraints()
    }
    
    private func _setupTitleLabelConstraints() {
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel!, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: HHMessageTimeCell.MessageTimeCellPadding))
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel!, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: -HHMessageTimeCell.MessageTimeCellPadding))
        
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel!, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: HHMessageTimeCell.MessageTimeCellPadding))
        self.addConstraint(NSLayoutConstraint(item: self.titleLabel!, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: -HHMessageTimeCell.MessageTimeCellPadding))
    }
}
