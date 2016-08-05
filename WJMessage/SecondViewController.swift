//
//  SecondViewController.swift
//  WJMessage
//
//  Created by apple on 16/7/4.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController,UITextViewDelegate {
    @IBOutlet weak var phoneTf: UITextField!
    @IBOutlet weak var callDetailLab: UILabel!
    var backgroundTime: NSDate?
    var isCall = false
    @IBOutlet weak var testBtn: UIButton!
    var timer :NSTimer?

//    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "电话监听通话时间"
        callDetailLab.text = ""
        // Do any additional setup after loading the view, typically from a nib.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplicationWillResignActiveNotification, object: nil)
        
        self.view .addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func testClick(sender: AnyObject) {
        if self.timer == nil {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(test), userInfo: nil, repeats: true)
        } else {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    func test() {
        let text = ["adfasdfasdf","fasdfasd","ads"]
        testBtn.setTitle(text[Int(arc4random_uniform(UInt32(text.count)))], forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func applicationDidBecomeActive() {
        if isCall {
            let time = NSDate().timeIntervalSince1970 - self.backgroundTime!.timeIntervalSince1970
            let since = NSDate.date("2016-07-12 00:00:00", format: "yyyy-MM-dd HH:mm:ss")
            let date = NSDate(timeInterval: time, sinceDate: since!)
            let format = NSDateFormatter()
            format.dateFormat = "HH时mm分ss秒"
            callDetailLab.text = "通话时间: \(format.stringFromDate(date)) \n" + callDetailLab.text!
            isCall = false
        }
    }
    
    func applicationWillResignActive() {
        self.backgroundTime = NSDate()
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            debugLog("text -- \(text) \n lenght -- \(text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))")
        }
        return true
    }
    
    @IBAction func call(sender: AnyObject) {
        if let url = NSURL(string: "tel://" + "\(phoneTf.text!)") {
            if UIApplication.sharedApplication().canOpenURL(url) {
                let alert = UIAlertController(title: "呼叫 " + "\(phoneTf.text!)", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "呼叫", style: UIAlertActionStyle.Default, handler: { (action) in
                    self.isCall = true
                    UIApplication.sharedApplication().openURL(url)
                }))
                alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (_) in
                    
                }))
                presentViewController(alert, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "该设备不支持呼叫！", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: { (_) in
                    
                }))
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

