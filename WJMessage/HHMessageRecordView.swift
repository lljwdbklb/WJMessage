//
//  HHMessageRecordView.swift
//  WJMessage
//
//  Created by apple on 16/8/5.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

class HHMessageRecordView: UIView {
    private let recordBtn = UIButton()
    private let recordTimeLab = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupSubView() {
        recordBtn.translatesAutoresizingMaskIntoConstraints = false
        recordBtn.setTitle("录音", forState: .Normal)
        recordBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        recordBtn.backgroundColor = UIColor.grayColor()
        recordBtn.layer.cornerRadius = 50
        
        addSubview(recordBtn)
        
        addConstraint(NSLayoutConstraint(item: recordBtn, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: recordBtn, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0))
        recordBtn.addConstraint(NSLayoutConstraint(item: recordBtn, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100))
        recordBtn.addConstraint(NSLayoutConstraint(item: recordBtn, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100))
        
        recordTimeLab.translatesAutoresizingMaskIntoConstraints = false
        recordTimeLab.textColor = UIColor.blackColor()
        recordTimeLab.text = "00:00"
        addSubview(recordTimeLab)
        
        addConstraint(NSLayoutConstraint(item: recordTimeLab, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: recordTimeLab, attribute: .Bottom, relatedBy: .Equal, toItem: recordBtn, attribute: .Top, multiplier: 1.0, constant: -5))
        
        
    }
}
