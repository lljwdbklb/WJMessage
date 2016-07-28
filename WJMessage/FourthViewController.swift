//
//  FourthViewController.swift
//  WJMessage
//
//  Created by apple on 16/7/19.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

class FourthViewController: UIViewController,HHScanViewControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLab: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "返回", style: .Plain, target: nil, action: nil)
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer)))
        self.textLab.text = "http://www.hao123.com"
        self.imageView.image = UIImage.qrcode(self.textLab.text!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    func tapGestureRecognizer() {
        if let image = imageView.image {
            let string = String.qrcodeString(image)
            let alert = UIAlertController(title: "提示", message: string, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "确认", style: .Cancel, handler: { (_) in
                if let str = string {
                    if str.hasPrefix("http://") || str.hasPrefix("https://")  {
                        let web = HHWebViewController()
                        web.urlStr = str
                        self.navigationController?.pushViewController(web, animated: true)
                    }
                }
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func clickBtn(sender: AnyObject) {
        let vc = HHScanViewController()
        vc.delegate = self
        self.presentViewController(vc, animated: true, completion: nil)
    }
    
    func didScanText(vc: HHScanViewController, text: String) {
        self.textLab.text = text
        vc.dismissViewControllerAnimated(true, completion: nil)
        self.imageView.image = UIImage.qrcode(text)
    }

}
