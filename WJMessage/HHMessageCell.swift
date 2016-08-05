//
//  HHMessageCell.swift
//  WJMessage
//
//  Created by apple on 16/7/6.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

protocol HHMessageCellDelegate {
    func didStatusButton(model:HHCellFrameModel)
    func didSelectCell(model:HHCellFrameModel)
}

class HHMessageCell: UITableViewCell {
    
    static let HHMessageCellTextIdentifier = "HHMessageCellText"
    static let HHMessageCellReceiveTextIdentifier = "HHMessageCellReceiveText"
    static let HHMessageCellImageIdentifier = "HHMessageCellImage"
    static let HHMessageCellReceiveImageIdentifier = "HHMessageCellReceiveImage"
    static let HHMessageCellPadding:CGFloat = 10
    
    var model: HHCellFrameModel? {
        didSet {
            setContent()
        }
    }
    var avatarView: UIImageView?
    var statusButton:UIButton?
    var activity:UIActivityIndicatorView?
    var bubbleView:HHMessageBubbleView?
    var bubbleMaxWidthConstraint:NSLayoutConstraint?
    
    var delegate:HHMessageCellDelegate?
    
    
    dynamic var avatarSize: CGFloat = HHMessageCell.appearance().avatarSize
    dynamic var statusSize: CGFloat = HHMessageCell.appearance().statusSize
    dynamic var activitySize: CGFloat = HHMessageCell.appearance().activitySize
    dynamic var bubbleMaxWidth: CGFloat = HHMessageCell.appearance().bubbleMaxWidth
    dynamic var bubbleMargin: UIEdgeInsets = HHMessageCell.appearance().bubbleMargin
    dynamic var leftBubbleMargin: UIEdgeInsets = HHMessageCell.appearance().leftBubbleMargin
    dynamic var rightBubbleMargin: UIEdgeInsets = HHMessageCell.appearance().rightBubbleMargin
    dynamic var messageTextFont: UIFont = HHMessageCell.appearance().messageTextFont
    dynamic var messageTextColor: UIColor = HHMessageCell.appearance().messageTextColor
    
    dynamic var bubbleSendImage: UIImage? = HHMessageCell.appearance().bubbleSendImage
    dynamic var bubbleReceiveImage: UIImage? = HHMessageCell.appearance().bubbleReceiveImage
    
    // MARK: Init
    override class func initialize()  {
        let cell = self.appearance()
        cell.avatarSize = 30
        cell.statusSize = 20
        cell.activitySize = 20;
        cell.bubbleMaxWidth = 200;
        cell.leftBubbleMargin = UIEdgeInsetsMake(8, 15, 8, 10);
        cell.rightBubbleMargin = UIEdgeInsetsMake(8, 10, 8, 15);
        cell.bubbleMargin = UIEdgeInsetsMake(8, 0, 8, 0);
        cell.messageTextFont = UIFont.systemFontOfSize(15)
        cell.messageTextColor = UIColor.blackColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
 
    init(style: UITableViewCellStyle, reuseIdentifier: String?,model:HHCellFrameModel) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.model = model
        _setupSubView(model.isSender,bodyType: (model.message?.bodyType)!)
        _setup()
        
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // MARK: Private
    private func _setupSubView(isSender:Bool,bodyType:HHMessageBodyType) {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        //警告
        statusButton = UIButton()
        statusButton?.translatesAutoresizingMaskIntoConstraints = false
        statusButton?.hidden = true
        statusButton?.setTitle("!", forState: .Normal)
        statusButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        statusButton?.backgroundColor = UIColor.redColor()
        statusButton?.layer.cornerRadius = statusSize / 2
        statusButton?.layer.masksToBounds = true
        statusButton?.addTarget(self, action: #selector(clickStatus), forControlEvents: .TouchUpInside)
        self.contentView.addSubview(statusButton!)
        //菊花
        activity = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activity?.translatesAutoresizingMaskIntoConstraints = false
        activity?.hidden = true
        self.contentView.addSubview(activity!)
        //头像
        avatarView = UIImageView()
        avatarView?.translatesAutoresizingMaskIntoConstraints = false
        avatarView?.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(avatarView!)
        //气泡
        let bubbleImage = isSender ? self.bubbleSendImage : self.bubbleReceiveImage
        bubbleMargin = isSender ? rightBubbleMargin : leftBubbleMargin;
        bubbleView = HHMessageBubbleView(margin: bubbleMargin,bodyType:bodyType)
        bubbleView?.translatesAutoresizingMaskIntoConstraints = false
        bubbleView?.backgroundColor = UIColor.clearColor()
        bubbleView?.backgroundImageView?.image = bubbleImage
        self.contentView.addSubview(bubbleView!)
        
        _setupLayout(isSender)
    }
    private func _setup() {
        bubbleView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickBubbleView)))
    }
    
    @objc private func clickBubbleView() {
        delegate?.didSelectCell(self.model!)
    }
    
    @objc private func clickStatus() {
        delegate?.didStatusButton(self.model!)
    }
    
    private func _setupLayout(isSender:Bool)  {
        if isSender {
            _setupSendLayout()
        } else {
            _setupRevLayout()
        }
    }
    
    private func _setupSendLayout() {
        /**
         * activit     ------------------  -----
         *      ---    |               /   |   | avatarView
         *      | |    |  bubbleView   |   -----
         *      ---    |               |
         * statusBtn   -----------------
         */
        //avatarView
        addConstraint(NSLayoutConstraint(item: avatarView!, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1.0, constant: HHMessageCell.HHMessageCellPadding))
        addConstraint(NSLayoutConstraint(item: avatarView!, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1.0, constant: -HHMessageCell.HHMessageCellPadding))
        
        avatarView?.addConstraint(NSLayoutConstraint(item: avatarView!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: avatarSize))
        avatarView?.addConstraint(NSLayoutConstraint(item: avatarView!, attribute: .Height, relatedBy: .Equal, toItem: avatarView, attribute: .Width, multiplier: 1.0, constant: 0))
        
        //bubbleView
        addConstraint(NSLayoutConstraint(item: bubbleView!, attribute: .Top, relatedBy: .Equal, toItem: avatarView, attribute: .Top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: bubbleView!, attribute: .Right, relatedBy: .Equal, toItem: avatarView, attribute: .Left, multiplier: 1.0, constant: -HHMessageCell.HHMessageCellPadding))
        addConstraint(NSLayoutConstraint(item: bubbleView!, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1.0, constant: -HHMessageCell.HHMessageCellPadding))
        bubbleMaxWidthConstraint = NSLayoutConstraint(item: bubbleView!, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: bubbleMaxWidth)
        bubbleView?.addConstraint(bubbleMaxWidthConstraint!)
        
        //statusButton
        addConstraint(NSLayoutConstraint(item: statusButton!, attribute: .Right, relatedBy: .Equal, toItem: bubbleView, attribute: .Left, multiplier: 1.0, constant: -HHMessageCell.HHMessageCellPadding))
        addConstraint(NSLayoutConstraint(item: statusButton!, attribute: .CenterY, relatedBy: .Equal, toItem: bubbleView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        statusButton?.addConstraint(NSLayoutConstraint(item: statusButton!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: statusSize))
        statusButton?.addConstraint(NSLayoutConstraint(item: statusButton!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: statusSize))
        
        addConstraint(NSLayoutConstraint(item: activity!, attribute: .Left, relatedBy: .Equal, toItem: statusButton, attribute: .Left, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: activity!, attribute: .Right, relatedBy: .Equal, toItem: statusButton, attribute: .Right, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: activity!, attribute: .Top, relatedBy: .Equal, toItem: statusButton, attribute: .Top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: activity!, attribute: .Bottom, relatedBy: .Equal, toItem: statusButton, attribute: .Bottom, multiplier: 1.0, constant: 0))
    }
    
    func _setupRevLayout()  {
        /**
         *     -----  ------------------  activit
         *     |   |   \               |   ---
         *     -----   |  bubbleView   |   | |
         * avatarView  |               |   ---
         *             -----------------  statusBtn
         */
        //avatarView
        self.addConstraint(NSLayoutConstraint(item: self.avatarView!, attribute: .Top, relatedBy: .Equal, toItem: self.contentView, attribute: .Top, multiplier: 1.0, constant: HHMessageCell.HHMessageCellPadding))
        self.addConstraint(NSLayoutConstraint(item: self.avatarView!, attribute: .Left, relatedBy: .Equal, toItem: self.contentView, attribute: .Left, multiplier: 1.0, constant: HHMessageCell.HHMessageCellPadding))
        
        self.avatarView?.addConstraint(NSLayoutConstraint(item: self.avatarView!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.avatarSize))
        self.avatarView?.addConstraint(NSLayoutConstraint(item: self.avatarView!, attribute: .Height, relatedBy: .Equal, toItem: self.avatarView, attribute: .Width, multiplier: 1.0, constant: 0))
        
        //bubbleView
        self.addConstraint(NSLayoutConstraint(item: self.bubbleView!, attribute: .Top, relatedBy: .Equal, toItem: self.avatarView, attribute: .Top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.bubbleView!, attribute: .Left, relatedBy: .Equal, toItem: self.avatarView, attribute: .Right, multiplier: 1.0, constant: HHMessageCell.HHMessageCellPadding))
        self.addConstraint(NSLayoutConstraint(item: self.bubbleView!, attribute: .Bottom, relatedBy: .Equal, toItem: self.contentView, attribute: .Bottom, multiplier: 1.0, constant: -HHMessageCell.HHMessageCellPadding))
        self.bubbleMaxWidthConstraint = NSLayoutConstraint(item: self.bubbleView!, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.bubbleMaxWidth)
        self.bubbleView?.addConstraint(self.bubbleMaxWidthConstraint!)
        
        //statusButton
        addConstraint(NSLayoutConstraint(item: statusButton!, attribute: .Left, relatedBy: .Equal, toItem: bubbleView, attribute: .Right, multiplier: 1.0, constant: HHMessageCell.HHMessageCellPadding))
        addConstraint(NSLayoutConstraint(item: statusButton!, attribute: .CenterY, relatedBy: .Equal, toItem: bubbleView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        statusButton?.addConstraint(NSLayoutConstraint(item: statusButton!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: statusSize))
        statusButton?.addConstraint(NSLayoutConstraint(item: statusButton!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: statusSize))
        
        addConstraint(NSLayoutConstraint(item: activity!, attribute: .Left, relatedBy: .Equal, toItem: statusButton, attribute: .Left, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: activity!, attribute: .Right, relatedBy: .Equal, toItem: statusButton, attribute: .Right, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: activity!, attribute: .Top, relatedBy: .Equal, toItem: statusButton, attribute: .Top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: activity!, attribute: .Bottom, relatedBy: .Equal, toItem: statusButton, attribute: .Bottom, multiplier: 1.0, constant: 0))
    }
    
    func setContent()  {
        debugLog(self.messageTextFont)
        
        self.avatarView?.image = self.model?.avatar
        if model?.bodyType == .Text {
            self.bubbleView?.textLabel?.font = self.messageTextFont
            self.bubbleView?.textLabel?.textColor = self.messageTextColor
            let text:NSAttributedString
            if self.model?.attrBody != nil {
                text = model!.attrBody!
            } else {
                text = NSAttributedString(string: model!.body,attributes: [NSFontAttributeName:self.messageTextFont])
            }
            self.bubbleView?.textLabel?.attributedText = text
        } else {
            //            self.bubbleView?.imageView?.setNeedsDisplay()
            
            if let image = model!.image {
                var size:CGSize
                if image.size.width > 200.0 {
                    let scalc = image.size.width / 200.0
                    size = CGSize(width: 200,height: image.size.height * scalc)
                } else {
                    size = image.size
                }
                if size.height > 200.0 {
                    size.height = 200.0
                }
                bubbleView?.setImage(image,size: size)
            } else if let url = model!.url {
                if let image = UIImage(named: url) {
                    var size:CGSize
                    if image.size.width > 200.0 {
                        let scalc = image.size.width / 200.0
                        size = CGSize(width: 200,height: image.size.height * scalc)
                    } else {
                        size = image.size
                    }
                    if size.height > 200.0 {
                        size.height = 200.0
                    }
                    bubbleView?.setImage(image,size: size)
                } else {
                    //网络请求
                }
            } else {
                if model?.status == .Failed {
                    bubbleView?.setImage(model?.failImage, size: CGSize(width: 100, height: 100))
                } else {
                    bubbleView?.setImage(model?.loadImage, size: CGSize(width: 100, height: 100))
                }
            }
        }
        
        self.statusButton?.hidden = true
        self.activity?.hidden = true
        self.activity?.stopAnimating()
        if .Delivering == self.model?.status {
            self.activity?.hidden = false
            self.activity?.startAnimating()
        } else if .Failed == self.model?.status {
            self.statusButton?.hidden = false
        }
    }
    
    class func cellHeight(model:HHCellFrameModel) -> CGFloat {
        if model.cellHeight > 0 {
            return model.cellHeight;
        }
        
        let cell = self.appearance()
        let minHeight = cell.avatarSize + HHMessageCell.HHMessageCellPadding * 2
        var height: CGFloat = 0
        if UIDevice.currentDevice().systemVersion == "7.0" {
            height = 15;
        }
        
        var bubbleMaxWidth = cell.bubbleMaxWidth
        bubbleMaxWidth -= (cell.leftBubbleMargin.left + cell.leftBubbleMargin.right + cell.rightBubbleMargin.left + cell.rightBubbleMargin.right) / 2.0
        var bubbleHeight = HHMessageCell.HHMessageCellPadding + cell.bubbleMargin.top + cell.bubbleMargin.bottom
        if model.bodyType == .Text {
            //text
            let text:NSAttributedString
            if model.attrBody != nil {
                text = model.attrBody!
            } else {
                text = NSAttributedString(string: model.body,attributes: [NSFontAttributeName:cell.messageTextFont])
            }
            let label = UILabel()
            label.font = cell.messageTextFont
            label.numberOfLines = 0
            label.attributedText = text
            let rect = label.textRectForBounds(CGRect(origin: CGPointZero, size: CGSize(width: bubbleMaxWidth, height: CGFloat.max)), limitedToNumberOfLines: 0)
            bubbleHeight += (rect.size.height > 20 ? rect.size.height : 20) + 10
        } else {
            if let image = model.image {
                if image.size.width > 200.0 {
                    let scalc = 200.0 / image.size.width
                    bubbleHeight += image.size.height * scalc
                } else {
                    bubbleHeight += image.size.height + 10
                }
                if bubbleHeight > 200.0 {
                    bubbleHeight = 200.0
                }
            } else if let url = model.url {
                if let image = UIImage(named: url) {
                    if image.size.width > 200.0 {
                        let scalc = 200.0 / image.size.width
                        bubbleHeight += image.size.height * scalc
                    } else {
                        bubbleHeight += image.size.height + 10
                    }
                    if bubbleHeight > 200.0 {
                        bubbleHeight = 200.0
                    }
                } else {
                    //网络请求
                }
            } else {
                let image: UIImage
                if model.status == .Failed {
                    image = model.failImage!
                } else {
                    image = model.loadImage!
                }
                bubbleHeight += image.size.height + 10
            }
        }
        bubbleHeight += HHMessageCell.HHMessageCellPadding
        
        height += -HHMessageCell.HHMessageCellPadding + bubbleHeight
        height = height > minHeight ? height : minHeight;
        model.cellHeight = height
        return height
    }
    
    class func cellIdentifier(model:HHCellFrameModel) -> String {
        if model.bodyType == .Image {
            if model.isSender {
                return HHMessageCell.HHMessageCellImageIdentifier
            }
            return HHMessageCell.HHMessageCellReceiveImageIdentifier
        }
        if model.isSender {
            return HHMessageCell.HHMessageCellTextIdentifier
        }
        return HHMessageCell.HHMessageCellReceiveTextIdentifier
    }


}
