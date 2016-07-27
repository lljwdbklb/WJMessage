//
//  HHMessageFaceView.swift
//  WJMessage
//
//  Created by apple on 16/7/11.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

protocol HHMessageFaceViewDelegate {
    func selectedFaceView(str:String?, isDelete:Bool)
    func sendFace()
}

class HHMessageFaceView: UIView {
    let bottomScrollView = UIScrollView()
    var currentSelectIndex:Int = 0
    var delegate:HHMessageFaceViewDelegate?
    
    var emotionManagers = Array<EaseEmotionManager>() {
        didSet {
            for em in emotionManagers {
                if em.emotionType != .Gif {
                    var array = em.emotions
                    let maxRow = em.emotionRow
                    let maxCol = em.emotionCol
                    var count = 1
                    while true {
                        let index = maxRow * maxCol * count - 1
                        if index >= array.count {
                            array.append("")
                            break
                        } else {
                            array.insert("", atIndex: index)
                        }
                        count += 1
                    }
                    em.emotions = array
                }
            }
            _setupButtonScrollView()
        }
    }
    
    let facialView = HHMessageFacialView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupSubViews()
    }
    override func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if newSuperview != nil {
            reloadEmotionData()
        }
    }
    
    private func _setupSubViews() {
        currentSelectIndex = 1000
        facialView.translatesAutoresizingMaskIntoConstraints = false
        facialView.delegate = self
        bottomScrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(facialView)
        addSubview(bottomScrollView)
        let sendBtn = UIButton(type: .Custom)
        sendBtn.translatesAutoresizingMaskIntoConstraints = false
        sendBtn.setTitle("发送", forState: .Normal)
        sendBtn.titleLabel?.font = UIFont.systemFontOfSize(15)
        sendBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        sendBtn.backgroundColor = UIColor.blueColor()
        sendBtn.addTarget(self, action: #selector(sendFace), forControlEvents: .TouchUpInside)
        addSubview(sendBtn)
        
        addConstraint(NSLayoutConstraint(item: facialView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: facialView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: facialView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0))
        facialView.addConstraint(NSLayoutConstraint(item: facialView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 150))
        
        addConstraint(NSLayoutConstraint(item: sendBtn, attribute: .Right, relatedBy: .Equal, toItem: facialView, attribute: .Right, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: sendBtn, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: sendBtn, attribute: .Top, relatedBy: .Equal, toItem: facialView, attribute: .Bottom, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: sendBtn, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 40))
        
        addConstraint(NSLayoutConstraint(item: bottomScrollView, attribute: .Left, relatedBy: .Equal, toItem: facialView, attribute: .Left, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: bottomScrollView, attribute: .Top, relatedBy: .Equal, toItem: facialView, attribute: .Bottom, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: bottomScrollView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: bottomScrollView, attribute: .Right, relatedBy: .Equal, toItem: sendBtn, attribute: .Left, multiplier: 1.0, constant: 0))
        
        _setupButtonScrollView()
    }
    
    private func _setupBtns() {
    }
    
    func _setupButtonScrollView() {
        let number = emotionManagers.count
        if number <= 1 {
            reloadEmotionData()
            return;
        }
        
        for view in bottomScrollView.subviews {
            view.removeFromSuperview()
        }
        for i in 0...number {
            let defaultButton = UIButton(type: .Custom)
            defaultButton.frame = CGRectMake(CGFloat(i) * CGRectGetWidth(bottomScrollView.frame) / (5-1), 0, CGRectGetWidth(bottomScrollView.frame) / (5-1), CGRectGetHeight(bottomScrollView.frame))
            let emotionManager = emotionManagers[i]
            if emotionManager.emotionType == .Default {
                let emotion = emotionManager.emotions.first as? EaseEmotion
                defaultButton.setTitle(emotion?.emotionThumbnail, forState: .Normal)
            } else {
                defaultButton.setImage(emotionManager.tagImage, forState: .Normal)
                defaultButton.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
                defaultButton.imageView?.contentMode = .ScaleAspectFit
            }
            defaultButton.backgroundColor = UIColor.clearColor()
            defaultButton.layer.borderWidth = 0.5
            defaultButton.layer.borderColor = UIColor.whiteColor().CGColor
            defaultButton.addTarget(self, action: #selector(didSelect(_:)), forControlEvents: .TouchUpInside)
            defaultButton.tag = 1000 + i
            bottomScrollView.addSubview(defaultButton)
        }
        bottomScrollView.contentSize = CGSize(width: CGFloat(number) * CGRectGetWidth(bottomScrollView.frame) / (5-1), height: CGRectGetHeight(bottomScrollView.frame))
        reloadEmotionData()
    }
    
    func reloadEmotionData() {
        let index = currentSelectIndex - 1000
        if index < emotionManagers.count {
            facialView.loadFacialView(emotionManagers,size:CGSize(width: 30, height: 30))
        }
    }
    
    func didSelect(sender:UIButton) {
        let lastBtn = bottomScrollView.viewWithTag(currentSelectIndex) as! UIButton
        lastBtn.selected = false
        
        currentSelectIndex = sender.tag
        sender.selected = true
        let index = sender.tag - 1000;
        facialView.loadFacialView(index)
    }
    
    func sendFace() {
        delegate?.sendFace()
    }
}

extension HHMessageFaceView : HHMessageFacialViewDelegate {
    
    func selectedFacialView(str:String?) {
        delegate?.selectedFaceView(str, isDelete: false)
    }
    
    func deleteSelected() {
        delegate?.selectedFaceView(nil, isDelete: true)
    }
}
