//
//  Utilty.swift
//  WJMessage
//
//  Created by apple on 16/7/13.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

extension NSDate {
    class func date(string:String,format:String) -> NSDate? {
        let dateF = NSDateFormatter()
        dateF.dateFormat = format
        return dateF.dateFromString(string)
    }
    
    func string(format:String) -> String {
        let dateF = NSDateFormatter()
        dateF.dateFormat = format
        return dateF.stringFromDate(self)
    }
    
    func initial() -> NSDate {
        let str = string("yyyy-MM-dd") + " 00:00:00"
        return NSDate.date(str, format: "yyyy-MM-dd HH:mm:ss")!
    }
    
    func nextDay() -> NSDate {
        return NSDate(timeInterval: 60 * 60 * 24, sinceDate: self)
    }
    
    func yyyyMMddHHmmss() -> String {
        return string("yyyy-MM-dd HH:mm:ss")
    }

}