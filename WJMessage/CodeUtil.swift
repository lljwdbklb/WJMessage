//
//  UIImage+Code.swift
//  WJMessage
//
//  Created by apple on 16/7/22.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

extension UIImage {
    class func qrcode(string:String) -> UIImage {
        let filer = CIFilter(name: "CIQRCodeGenerator")
        filer?.setDefaults()
        let data = string.dataUsingEncoding(NSUTF8StringEncoding)
        filer?.setValue(data, forKey: "inputMessage")
        let outImage = filer?.outputImage
        return UIImage(CIImage: outImage!)
    }
}


extension String {
    //ios8
    static func qrcodeString(image:UIImage) -> String? {
        let content = CIContext(options: nil)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: content, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        if let i = image.CGImage {
            let img = CIImage(CGImage: i)
            let features = detector .featuresInImage(img)
            let feature = features.first as! CIQRCodeFeature
            return feature.messageString
        } else if let i = image.CIImage {
            let features = detector .featuresInImage(i)
            let feature = features.first as! CIQRCodeFeature
            return feature.messageString
        }
        return nil
    }

}