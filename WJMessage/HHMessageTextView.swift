//
//  HHMessageTextView.swift
//  WJMessage
//
//  Created by apple on 16/7/12.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

protocol HHMessageTextViewDelegate:UITextViewDelegate {
    func shouldTextViewMenuPaste() -> Bool
}

class HHMessageTextView: UITextView {
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(paste(_:)) {
            return (delegate as? HHMessageTextViewDelegate)!.shouldTextViewMenuPaste()
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
