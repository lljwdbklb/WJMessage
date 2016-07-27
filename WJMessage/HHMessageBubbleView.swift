//
//  HHMessageBubbleView.swift
//  WJMessage
//
//  Created by apple on 16/7/6.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

class HHMessageBubbleView: UIView {
    var textLabel:UILabel?
    var imageView:UIImageView?
    var backgroundImageView: UIImageView?
    
    var bodyType = HHMessageBodyType.Text
    var margin = UIEdgeInsetsZero
    
    convenience init(margin: UIEdgeInsets,bodyType: HHMessageBodyType) {
        self.init()
        self.margin = margin
        self.bodyType = bodyType
        _setupSubView()
    }
    
    private func _setupSubView() {
//        self.backgroundColor = UIColor.redColor()
        backgroundImageView = UIImageView()
        backgroundImageView?.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView?.backgroundColor = UIColor.clearColor()
        addSubview(self.backgroundImageView!)
        if bodyType == .Text {
            textLabel = UILabel()
            textLabel?.translatesAutoresizingMaskIntoConstraints = false
            textLabel?.backgroundColor = UIColor.clearColor()
            textLabel?.numberOfLines = 0
            addSubview(textLabel!)
        } else {
            imageView = UIImageView()
            imageView?.translatesAutoresizingMaskIntoConstraints = false
            imageView?.backgroundColor = UIColor.clearColor()
            imageView?.contentMode = .ScaleAspectFill
            imageView?.layer.masksToBounds = true
            imageView?.layer.cornerRadius = 5
            addSubview(imageView!)
        }
        _setupLayout()
    }
    
    private func _setupLayout() {
        
        addConstraint(NSLayoutConstraint(item: backgroundImageView!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: backgroundImageView!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: backgroundImageView!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: backgroundImageView!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0))
        
        if bodyType == .Text {
            addConstraint(NSLayoutConstraint(item: textLabel!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: margin.top))
            addConstraint(NSLayoutConstraint(item: textLabel!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -margin.bottom))
            addConstraint(NSLayoutConstraint(item: textLabel!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: margin.left))
            addConstraint(NSLayoutConstraint(item: textLabel!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: -margin.right))
        } else {
            addConstraint(NSLayoutConstraint(item: imageView!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: margin.top))
            addConstraint(NSLayoutConstraint(item: imageView!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: margin.left))
            addConstraint(NSLayoutConstraint(item: imageView!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: -margin.right))
            addConstraint(NSLayoutConstraint(item: imageView!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: -margin.bottom))
        }
    }
    
    func setImage(image:UIImage?,size:CGSize) {
        if bodyType == .Image {
            imageView?.image = image
            setMask(size)
        }
    }
    
    private func setMask(size:CGSize) {
//        let imageViewMask = UIImageView(image: self.backgroundImageView?.image)
//        imageViewMask.frame = CGRect(origin: CGPointZero, size: size)
//        imageView?.layer.mask = imageViewMask.layer
    }

}
