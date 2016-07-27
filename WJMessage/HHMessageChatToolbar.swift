//
//  HHMessageChatToolbar.swift
//  WJMessage
//
//  Created by apple on 16/7/7.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

protocol HHMessageChatToolbarDelegate {
    func showKeyboard(height:CGFloat)
    func chatToolbarDidChangeFrameToHeight(height:CGFloat)
    func didSendText(text:String)
    func shouldTextViewMenuPaste() -> Bool
    
    //bottom btns
    func shouldChangeBottomBtn(index:Int) -> Bool
    func didCancelBottomBtn()
    func didSelectedBottomBtn(index:Int)
    
}

class HHMessageChatToolbar: UIView {
    static let HHMessageToolBarPadding:CGFloat = 5
    static let HHMessageToolBarDefaultHeight:CGFloat = 33.0
    static let HHMessageToolBarMaxHeight:CGFloat = 150.0
    static let HHMessageToolBarBottomDefaultHeight:CGFloat = 40
    
    var topView = UIView()
    var textView = HHMessageTextView()
    var bottomView = UIView()
    var bottomBtns = Array<UIButton>()
    var bottomSelectedBtn:UIButton?
    
    
    dynamic var textViewFont: UIFont? = HHMessageChatToolbar.appearance().textViewFont
    
    var textViewHeightConstraint :NSLayoutConstraint?
    var previousTextViewContentHeight:CGFloat = 0.0
    
    var delegate:HHMessageChatToolbarDelegate?
    
    override class func initialize()  {
        let bar = self.appearance()
        bar.textViewFont = UIFont.systemFontOfSize(14)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setupSubView()
    }
    
    private func _setupSubView()  {
        
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = UIColor.clearColor()
        self.addSubview(topView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor.whiteColor()
        textView.font = self.textViewFont
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor.grayColor().CGColor
        textView.delegate = self
        topView.addSubview(textView)
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = UIColor.clearColor()
        self.addSubview(bottomView)
        
        _setupLayout()
        
        _setupDefaultBottomBtns()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(chatKeyboardWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil
        )
    }
    
    private func _setupLayout()  {
        //bottom
        self.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
        bottomView.addConstraint(NSLayoutConstraint(item: bottomView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: HHMessageChatToolbar.HHMessageToolBarBottomDefaultHeight))
        //top
        self.addConstraint(NSLayoutConstraint(item: topView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: topView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: topView, attribute: .Bottom, relatedBy: .Equal, toItem: bottomView, attribute: .Top, multiplier: 1.0, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: topView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1.0, constant: 0))
        
        _setupTopViewLayout()
        
    }
    
    private func _setupTopViewLayout()  {
        topView.addConstraint(NSLayoutConstraint(item: textView, attribute: .Left, relatedBy: .Equal, toItem: topView, attribute: .Left, multiplier: 1.0, constant: HHMessageChatToolbar.HHMessageToolBarPadding))
        topView.addConstraint(NSLayoutConstraint(item: textView, attribute: .Top, relatedBy: .Equal, toItem: topView, attribute: .Top, multiplier: 1.0, constant: HHMessageChatToolbar.HHMessageToolBarPadding))
        topView.addConstraint(NSLayoutConstraint(item: textView, attribute: .Right, relatedBy: .Equal, toItem: topView, attribute: .Right, multiplier: 1.0, constant: -HHMessageChatToolbar.HHMessageToolBarPadding))
        topView.addConstraint(NSLayoutConstraint(item: textView, attribute: .Bottom, relatedBy: .Equal, toItem: topView, attribute: .Bottom, multiplier: 1.0, constant: -HHMessageChatToolbar.HHMessageToolBarPadding))
        textViewHeightConstraint = NSLayoutConstraint(item: textView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: HHMessageChatToolbar.HHMessageToolBarDefaultHeight)
        textView.addConstraint(textViewHeightConstraint!)
    }
    
    private func _setupDefaultBottomBtns()  {
        let titles = ["语音","照片","拍照","表情","更多"]
        for (idx,title) in titles.enumerate() {
            let btn = UIButton(type: .Custom)
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.setTitle(title, forState: .Normal)
            btn.setTitleColor(UIColor.grayColor(), forState: .Normal)
            btn.setTitleColor(UIColor.blueColor(), forState: .Selected)
            btn.setTitleColor(UIColor.blueColor(), forState: .Highlighted)
            btn.addTarget(self, action: #selector(btnAction(_:)), forControlEvents: .TouchUpInside)
            bottomView.addSubview(btn)
            //layout
            if idx == 0 {
                bottomView.addConstraint(NSLayoutConstraint(item: btn, attribute: .Left, relatedBy: .Equal, toItem: bottomView, attribute: .Left, multiplier: 1.0, constant: 0))
            } else {
                bottomView.addConstraint(NSLayoutConstraint(item: btn, attribute: .Left, relatedBy: .Equal, toItem: bottomBtns.last, attribute: .Right, multiplier: 1.0, constant: 0))
                bottomView.addConstraint(NSLayoutConstraint(item: btn, attribute: .Width, relatedBy: .Equal, toItem: bottomBtns.last, attribute: .Width, multiplier: 1.0, constant: 0))
            }
            bottomView.addConstraint(NSLayoutConstraint(item: btn, attribute: .Top, relatedBy: .Equal, toItem: bottomView, attribute: .Top, multiplier: 1.0, constant: 0))
            bottomView.addConstraint(NSLayoutConstraint(item: btn, attribute: .Bottom, relatedBy: .Equal, toItem: bottomView, attribute: .Bottom, multiplier: 1.0, constant: 0))
            
            bottomBtns.append(btn)
        }
        bottomView.addConstraint(NSLayoutConstraint(item: bottomBtns.last!, attribute: .Right, relatedBy: .Equal, toItem: bottomView, attribute: .Right, multiplier: 1.0, constant: 0))
    }
    
    //MARK: - Keyboard
    @objc private func chatKeyboardWillChangeFrame(notification:NSNotification) {
        
        let userInfo = notification.userInfo!
        let endFrame = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        let beginFrame = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue()
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey]!.integerValue
        let animated = {() in
            self._willShowKeyboard(beginFrame, endFrame: endFrame)
        }
        animated()
        UIView.animateWithDuration(duration, delay: 0.0, options: [UIViewAnimationOptions(rawValue:UInt(curve)),UIViewAnimationOptions.BeginFromCurrentState], animations: {
            self.layoutIfNeeded()
            }, completion: nil)
    }
    
    private func _willShowKeyboard(beginFrame:CGRect,endFrame:CGRect) {
        let bounds = UIScreen.mainScreen().bounds
        if beginFrame.origin.y == bounds.size.height {
            self._willShowBottomHeight(endFrame.size.height)
        } else if endFrame.origin.y == bounds.size.height {
            self._willShowBottomHeight(0)
        } else {
            self._willShowBottomHeight(endFrame.size.height)
        }
    }
    
    private func _willShowBottomHeight(height:CGFloat) {
        self.delegate?.showKeyboard(height)
    }
    
    override func resignFirstResponder() -> Bool {
        if let b = bottomSelectedBtn {
            btnAction(b)
        }
        return super.resignFirstResponder()
    }
    
    override func endEditing(force: Bool) -> Bool {
        if let b = bottomSelectedBtn {
            btnAction(b)
        }
        return super.endEditing(force)
    }
    
    //MARK: - click
    func btnAction(sender:UIButton)  {
        textView.resignFirstResponder()
        if sender.selected {
            sender.selected = false
            if bottomSelectedBtn != nil {
                self.delegate?.didCancelBottomBtn()
            }
            bottomSelectedBtn = nil
        } else {
            bottomSelectedBtn?.selected = false
            if bottomSelectedBtn != nil {
                self.delegate?.didCancelBottomBtn()
            }
            bottomSelectedBtn = nil
            if let flag = self.delegate?.shouldChangeBottomBtn(bottomBtns.indexOf(sender)!) {
                sender.selected = flag
                if flag {
                    bottomSelectedBtn = sender
                    self.delegate?.didSelectedBottomBtn(bottomBtns.indexOf(bottomSelectedBtn!)!)
                }
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
//MARK: - UITextViewDelegate
extension HHMessageChatToolbar:HHMessageTextViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if let b = bottomSelectedBtn {
            btnAction(b)
        }
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.becomeFirstResponder()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    func textViewDidChange(textView: UITextView) {
        _willShowInputTextViewToHeight(_getTextViewContentH(textView))
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.delegate?.didSendText(textView.text)
            textView.text = ""
            _willShowInputTextViewToHeight(_getTextViewContentH(textView))
            return false
        }
        return true
    }
    
    func _getTextViewContentH(textView:UITextView) ->CGFloat {
        return textView.sizeThatFits(textView.frame.size).height
    }
    
    func _willShowInputTextViewToHeight(toHeight:CGFloat)  {
        var height = toHeight
        if toHeight < HHMessageChatToolbar.HHMessageToolBarDefaultHeight {
            height = HHMessageChatToolbar.HHMessageToolBarDefaultHeight
        }
        if (toHeight > HHMessageChatToolbar.HHMessageToolBarMaxHeight) {
            height = HHMessageChatToolbar.HHMessageToolBarMaxHeight
        }
        if height == previousTextViewContentHeight {
            return
        } else {
            debugPrint(height)
            textViewHeightConstraint?.constant = height
            previousTextViewContentHeight = height
            self.delegate?.chatToolbarDidChangeFrameToHeight(height)
        }
    }
    
    func shouldTextViewMenuPaste() -> Bool {
        return true == delegate?.shouldTextViewMenuPaste()
    }
}
