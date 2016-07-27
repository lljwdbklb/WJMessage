//
//  HHFingerprint.swift
//  WJMessage
//
//  Created by apple on 16/7/27.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit
import LocalAuthentication

typealias HHFingerprintComp = (success:Bool, error:NSError?) -> Void

class HHFingerprint: NSObject {
    class func openAuthentication(reason:String?, comp:HHFingerprintComp) {
        if UIDevice.currentDevice().systemVersion.compare("8.0") ==  NSComparisonResult.OrderedSame || UIDevice.currentDevice().systemVersion.compare("8.0") ==  NSComparisonResult.OrderedDescending
        {
            // Get the local authentication context.
            let context = LAContext()
            // Declare a NSError variable.
            var error: NSError?
            // Set the reason string that will appear on the authentication alert.
            
            let reasonString:String
            if reason != nil {
                reasonString = reason!
            } else {
                reasonString = "通过Home键验证已有手机指纹"
            }
            // Check if the device can evaluate the policy.
            if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &error)
            {
                context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in //放到主线程执行，这里特别重要
                        
                        comp(success: success,error: evalPolicyError)
                    })
                })
            }
            else
            {
                // If the security policy cannot be evaluated then show a short message depending on the error.
                let errorStr:String
                switch error!.code
                {
                    case LAError.TouchIDNotEnrolled.rawValue:
                    errorStr = "您还没有保存TouchID指纹"
                    case LAError.PasscodeNotSet.rawValue:
                    errorStr = "您还没有设置密码"
                    default:
                    // The LAError.TouchIDNotAvailable case.
                    errorStr = "TouchID不可用"
                }
                // Optionally the error description can be displayed on the console.
                // Show the custom alert view to allow users to enter the password.
                error = NSError(domain: errorStr, code: error!.code, userInfo: [NSLocalizedDescriptionKey:errorStr])
                comp(success: false,error: error)
            }
        }
    }

}
