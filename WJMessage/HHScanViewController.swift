//
//  HHScanViewController.swift
//  WJMessage
//
//  Created by apple on 16/7/19.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit
import AVFoundation

protocol HHScanViewControllerDelegate {
    func didScanText(vc:HHScanViewController ,text:String)
}

class HHScanViewController: UIViewController {
    private var captureSession:AVCaptureSession?
    private var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    private let scanCenterView = UIView()
    private let scanLineView = UIImageView()
    private let textLab = UILabel()
    private let scanView = UIView()
    
    var scanSuccess = false
    
    var delegate : HHScanViewControllerDelegate?
    
    var scanLineColor = UIColor.greenColor()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupLayout()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startAnimatied()
    }
    
    private func setup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didBecomeActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    @objc private func didBecomeActive() {
        startAnimatied()
    }
    
    private func setupLayout() {
        view.backgroundColor = UIColor.grayColor()
        
        scanView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanView)
        
        view.addConstraint(NSLayoutConstraint(item: scanView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: scanView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: scanView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: scanView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        
        scanCenterView.translatesAutoresizingMaskIntoConstraints = false
        scanCenterView.layer.borderWidth = 0.5
        scanCenterView.layer.borderColor = UIColor.whiteColor().CGColor
        view.addSubview(scanCenterView)
        
        view.addConstraint(NSLayoutConstraint(item: scanCenterView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: scanCenterView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1.0, constant: -40))
        scanCenterView.addConstraint(NSLayoutConstraint(item: scanCenterView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 200))
        scanCenterView.addConstraint(NSLayoutConstraint(item: scanCenterView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 200))
        
        scanLineView.translatesAutoresizingMaskIntoConstraints = false
        scanLineView.backgroundColor = scanLineColor
        scanCenterView.addSubview(scanLineView)
        scanCenterView.addConstraint(NSLayoutConstraint(item: scanLineView, attribute: .Top, relatedBy: .Equal, toItem: scanCenterView, attribute: .Top, multiplier: 1.0, constant: 5))
        scanLineView.addConstraint(NSLayoutConstraint(item: scanLineView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1))
        scanCenterView.addConstraint(NSLayoutConstraint(item: scanLineView, attribute: .Left, relatedBy: .Equal, toItem: scanCenterView, attribute: .Left, multiplier: 1.0, constant: 5))
        scanCenterView.addConstraint(NSLayoutConstraint(item: scanLineView, attribute: .Right, relatedBy: .Equal, toItem: scanCenterView, attribute: .Right, multiplier: 1.0, constant: -5))
        
        //黑色遮罩位置
        let color = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        let view1 = UIView()
        view1.translatesAutoresizingMaskIntoConstraints = false
        view1.backgroundColor = color
        view.addSubview(view1)
        view.addConstraint(NSLayoutConstraint(item: view1, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view1, attribute: .Bottom, relatedBy: .Equal, toItem: scanCenterView, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view1, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view1, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        
        let view2 = UIView()
        view2.translatesAutoresizingMaskIntoConstraints = false
        view2.backgroundColor = color
        view.addSubview(view2)
        view.addConstraint(NSLayoutConstraint(item: view2, attribute: .Top, relatedBy: .Equal, toItem: scanCenterView, attribute: .Bottom, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view2, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view2, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view2, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        
        let view3 = UIView()
        view3.translatesAutoresizingMaskIntoConstraints = false
        view3.backgroundColor = color
        view.addSubview(view3)
        view.addConstraint(NSLayoutConstraint(item: view3, attribute: .Top, relatedBy: .Equal, toItem: view1, attribute: .Bottom, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view3, attribute: .Bottom, relatedBy: .Equal, toItem: view2, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view3, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view3, attribute: .Right, relatedBy: .Equal, toItem: scanCenterView, attribute: .Left, multiplier: 1.0, constant: 0))
        
        let view4 = UIView()
        view4.translatesAutoresizingMaskIntoConstraints = false
        view4.backgroundColor = color
        view.addSubview(view4)
        view.addConstraint(NSLayoutConstraint(item: view4, attribute: .Top, relatedBy: .Equal, toItem: view1, attribute: .Bottom, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view4, attribute: .Bottom, relatedBy: .Equal, toItem: view2, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view4, attribute: .Left, relatedBy: .Equal, toItem: scanCenterView, attribute: .Right, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view4, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        
        //返回按钮
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("返回", forState: .Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.addTarget(self, action: #selector(back), forControlEvents: .TouchUpInside)
        view.addSubview(btn)
        
        view.addConstraint(NSLayoutConstraint(item: btn, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 30))
        view.addConstraint(NSLayoutConstraint(item: btn, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 10))
        
        textLab.translatesAutoresizingMaskIntoConstraints = false
        textLab.textColor = UIColor.whiteColor()
        textLab.font = UIFont.systemFontOfSize(15)
        textLab.textAlignment = .Center
        textLab.numberOfLines = 0
        view.addSubview(textLab)
        view.addConstraint(NSLayoutConstraint(item: textLab, attribute: .Top, relatedBy: .Equal, toItem: scanCenterView, attribute: .Bottom, multiplier: 1.0, constant: 30))
        view.addConstraint(NSLayoutConstraint(item: textLab, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: textLab, attribute: .Width, relatedBy: .LessThanOrEqual, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 250))
        
        setupCapture()
    }
    
    private func setupCapture() {
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice) as AVCaptureDeviceInput
            // Initialize the captureSession object.
            captureSession = AVCaptureSession()
            // Set the input device on the capture session.
            captureSession?.addInput(input as AVCaptureInput)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            scanView.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
            
        } catch let error as NSError {
            if error.code == -11814 {
                self.textLab.text = "该设备摄像头不可用。"
            } else {
                let infoDic = NSBundle.mainBundle().infoDictionary
                let appName = infoDic?["CFBundleName"]
                self.textLab.text = "请在iPhone的“设置-隐私-相机”选项中，允许\(appName!)访问你的相机。"
            }
        }
    }
    
    private func startAnimatied() {
        scanLineView.layer.removeAnimationForKey("MoreY")
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue = 5
        animation.toValue = self.scanCenterView.layer.frame.height - 5
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 2
        animation.repeatCount = MAXFLOAT
        animation.removedOnCompletion = true
        scanLineView.layer.addAnimation(animation, forKey: "MoreY")
    }
    
    @objc private func back() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension HHScanViewController:AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!,
                       didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection
        connection: AVCaptureConnection!) {
        if metadataObjects == nil || metadataObjects.count == 0 {
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        let barCodeObject = videoPreviewLayer?.transformedMetadataObjectForMetadataObject(metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
        
        if !scanSuccess && scanCenterView.layer.frame.contains(barCodeObject.bounds) {//是否在区域范围内
            scanSuccess = true
            debugPrint("\(scanCenterView.layer.frame) -- \(barCodeObject.bounds)")
            delegate?.didScanText(self,text: barCodeObject.stringValue)
        }
    }
}
