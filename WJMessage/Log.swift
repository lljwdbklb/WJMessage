//
//  Log.swift
//  WJMessage
//
//  Created by apple on 16/8/5.
//  Copyright © 2016年 WhoJun. All rights reserved.
//
// 安装插件 https://github.com/robbiehanson/XcodeColors

import Foundation


public func debugLog<T>(any:T ,file:String = #file,function:String = #function , line:Int = #line) {
    Log.defaultLog.printLog(.Debug,file:file, function: function, line: line, any: any)
}
public func errorLog<T>(any:T ,file:String = #file,function:String = #function , line:Int = #line) {
    Log.defaultLog.printLog(.Error,file:file, function: function, line: line, any: any)
}
public func warnLog<T>(any:T ,file:String = #file,function:String = #function , line:Int = #line) {
    Log.defaultLog.printLog(.Warnning,file:file, function: function, line: line, any: any)
}

enum LogType : Int {
    case Debug
    case Warnning
    case Error
    func string() -> String {
        var str = "DEBUG"
        if self == .Warnning {
            str = "WARNNING"
        } else if self == .Error {
            str = "ERROR"
        }
        return str
    }
}

class Log: NSObject {
    static let defaultLog = Log()
    static let ESCAPE = "\u{001b}["
    static let RESET = ESCAPE + ";"
    func printLog<T>(type:LogType, file:String,function:String,line:Int, any:T) {
        let str : String = ((file as NSString).lastPathComponent as NSString).stringByDeletingPathExtension
        print("\(type.string())-[\(NSDate().string("yyyy-MM-dd HH:mm:ss"))]\(str).\(function)[\(line)]: \n\(any)")
    }
}