//
//  FileUpload.swift
//  WJMessage
//
//  Created by apple on 16/7/14.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit
//import Alamofire

class FileUpload: NSObject {
    class func uploadImage(file:String, completionHandler:((success:Bool,urlString:String?)->Void)) {
//        "http://t.ekangzhi.com:7080/pub/upfile"
//        upload(.POST, "http://t.ekangzhi.com:7080/pub/upfile", file: NSURL(fileURLWithPath: file)).responseJSON { (response) in
//            debugLog(response.result.value)
//            if response.result.error != nil {
//                completionHandler(success: false,urlString: nil)
//            } else {
//                let json = JSON(response.result.value!)
//                debugLog(json)
//                completionHandler(success: true,urlString: json["appFile"].stringValue)
//            }
//        }
        upload(.POST, "http://t.ekangzhi.com:7080/pub/upfile", multipartFormData: { (data) in
            data.appendBodyPart(fileURL:  NSURL(fileURLWithPath: file), name: "file")
        }) { (result) in
            switch result {
            case .Success(let upload,_,_) :
                upload.responseJSON(completionHandler: { (response) in
                    debugLog(response.result)
                    if response.result.error != nil {
                        completionHandler(success: false,urlString: nil)
                    } else {
                        let json = JSON(response.result.value!)
                        debugLog(json)
                        completionHandler(success: true,urlString: json["appFile"].stringValue)
                    }
                })
                break
            case .Failure(let encodingError):
                debugLog(encodingError)
                completionHandler(success: false,urlString: nil)
                break
            }
        }
    }
    
    class func createTempFile() -> String {
        let temp = NSTemporaryDirectory() + "FileUpload"
        let file = NSFileManager.defaultManager()
        if  !file.fileExistsAtPath(temp) {
            try! file.createDirectoryAtPath(temp, withIntermediateDirectories: true, attributes: nil)
        }
        return temp
    }
    
    class func saveTempFile(data:NSData, block:((Bool,String)->Void)) {
        
        let filePath = createTempFile() + "/\(Int64(NSDate().timeIntervalSince1970 * 1000)).jpg"
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            let file = NSFileManager.defaultManager()
            let res = file.createFileAtPath(filePath, contents: data, attributes: nil)
            dispatch_async(dispatch_get_main_queue(), { 
                //回调
                block(res,filePath)
            })
        }
    }
    
    class func deleteTempFile() {
        let file = NSFileManager.defaultManager()
        try! file.removeItemAtPath(createTempFile())
    }


}
