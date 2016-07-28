//
//  HHWebViewController.swift
//  WJMessage
//
//  Created by apple on 16/7/25.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

class HHWebViewController: UIViewController,NJKWebViewProgressDelegate {
    let webView : UIWebView = UIWebView()
    
    var progressView :NJKWebViewProgressView?
    var progressProxy :NJKWebViewProgress?
    
    var timer: NSTimer?
    var loading = false
    
    var snapShotsArray = Array<Dictionary<NSURLRequest,UIView>>()
    var isSwipingBack = false
    var currentSnapShotView:UIView?
    var prevSnapShotView:UIView?
    
    var urlStr:String? {
        didSet {
            self.loadReqest()
        }
    }
    
    //MARK: - 重写
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        setupLayout()
        loadReqest()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController != nil && progressView != nil {
            self.navigationController!.navigationBar.addSubview(progressView!)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        progressView?.removeFromSuperview()
    }
    
    override func navigationShouldPop() -> Bool {
        if webView.canGoBack {
            snapShotsArray.removeLast()
            webView.goBack()
            return false
        } else {
            return true
        }
    }
    
    //MARK: - private
    private func setup() {
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    private func setupLayout() {
        webView.scalesPageToFit = true
        let swipePanGesture = UIPanGestureRecognizer(target: self, action: #selector(swipePanGestureHandler(_:)))
        webView.addGestureRecognizer(swipePanGesture)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        
        progressProxy = NJKWebViewProgress()
        webView.delegate = progressProxy
        progressProxy?.webViewProxyDelegate = self
        progressProxy?.progressDelegate = self
        
        let progressBarHeight:CGFloat = 2.0
        let navigationBarBounds = self.navigationController!.navigationBar.bounds
        let barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
        progressView = NJKWebViewProgressView(frame: barFrame)
        progressView?.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]

    }
    
    private func updateNavigationItems() {
        if webView.canGoBack {
            let back = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action: #selector(closeItemClicked))
            navigationController?.interactivePopGestureRecognizer?.enabled = false
            navigationItem.setLeftBarButtonItems([back], animated: false)
        } else {
            navigationController?.interactivePopGestureRecognizer?.enabled = true
            navigationItem.leftBarButtonItems = nil
        }
    }
    
    private func pushCurrentSnapshotViewWithRequest(request:NSURLRequest) {
        let lastRequest = snapShotsArray.last?.keys.first
        if request.URL?.absoluteString == "about:blank" {
            return;
        }
        
        if request.URL?.absoluteString == lastRequest?.URL?.absoluteString {
            return;
        }
        let currentSnapShotView = self.webView.snapshotViewAfterScreenUpdates(true)
        snapShotsArray.append([request:currentSnapShotView])
    }
    
    @objc private func closeItemClicked() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @objc private func swipePanGestureHandler(swipe:UIPanGestureRecognizer) {
        let translation = swipe.translationInView(self.webView)
        let location = swipe.locationInView(self.webView)
        if (swipe.state == .Began) {
            if location.x <= 50 && translation.x >= 0 {  //开始动画
                self.startPopSnapshotView()
            }
        }else if swipe.state == .Cancelled || swipe.state == .Ended {
            self.endPopSnapShotView()
        }else if swipe.state == .Changed{
            popSnapShotViewWithPanGestureDistance(translation.x)
        }
    }
    
    private func startPopSnapshotView() {
        if isSwipingBack {
            return
        }
        if !self.webView.canGoBack {
            return
        }
        isSwipingBack = true
        var center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
        currentSnapShotView = self.webView.snapshotViewAfterScreenUpdates(true)
        currentSnapShotView?.layer.shadowColor = UIColor.blackColor().CGColor
        currentSnapShotView?.layer.shadowOffset = CGSizeMake(3, 3);
        currentSnapShotView?.layer.shadowRadius = 5;
        currentSnapShotView?.layer.shadowOpacity = 0.75;
        currentSnapShotView?.center = center
        
        prevSnapShotView = snapShotsArray.last?.values.first
        center.x -= 60
        prevSnapShotView?.center = center
        prevSnapShotView?.alpha = 1
        view.backgroundColor = UIColor.blackColor()
        
        view.addSubview(prevSnapShotView!)
        view.addSubview(currentSnapShotView!)
    }
    
    private func popSnapShotViewWithPanGestureDistance(distance:CGFloat)  {
        if !isSwipingBack {
            return
        }
        
        if distance <= 0 {
            return
        }
        
        var currentSnapshotViewCenter = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2)
        currentSnapshotViewCenter.x += distance
        var prevSnapshotViewCenter = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2)
        prevSnapshotViewCenter.x -= (view.bounds.size.width - distance)*60/view.bounds.size.width
        
        self.currentSnapShotView?.center = currentSnapshotViewCenter
        self.prevSnapShotView?.center = prevSnapshotViewCenter
    }
    
    private func endPopSnapShotView() {
        if !isSwipingBack {
            return
        }
        view.userInteractionEnabled = false
        
        
        if currentSnapShotView?.center.x >= view.bounds.size.width {
            // pop success
            UIView.animateWithDuration(0.2, animations: {
                UIView.setAnimationCurve(.EaseInOut)
                self.currentSnapShotView?.center = CGPointMake(self.view.bounds.size.width*3/2, self.view.bounds.size.height/2)
                self.prevSnapShotView?.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)
            }) {(finished) in
                self.prevSnapShotView?.removeFromSuperview()
                self.currentSnapShotView?.removeFromSuperview()
                self.webView.goBack()
                self.snapShotsArray.removeLast()
                self.view.userInteractionEnabled = true
                self.isSwipingBack = false
            }
        }else{
            //pop fail
            UIView.animateWithDuration(0.2, animations: {
                UIView.setAnimationCurve(.EaseInOut)
                self.currentSnapShotView?.center = CGPointMake(self.view.bounds.size.width*3/2, self.view.bounds.size.height/2)
                self.prevSnapShotView?.center = CGPointMake(self.view.bounds.size.width/2-60, self.view.bounds.size.height/2)
                self.prevSnapShotView?.alpha = 1
            }) {(finished) in
                self.prevSnapShotView?.removeFromSuperview()
                self.currentSnapShotView?.removeFromSuperview()
                self.view.userInteractionEnabled = true
                self.isSwipingBack = false
            }
        }
    }
    
    //MARK: - public
    func loadReqest() {
        if urlStr == nil {
            return
        }
        if let url = NSURL(string:urlStr!) {
            let request = NSURLRequest(URL: url,cachePolicy: .UseProtocolCachePolicy,timeoutInterval: 30)
            webView.loadRequest(request)
        }
    }
    
    //MARK: - NJKWebViewProgressDelegate
    func webViewProgress(webViewProgress: NJKWebViewProgress!, updateProgress progress: Float) {
        progressView?.setProgress(progress, animated: true)
    }
    
}

//MARK: WebViewDelegate
extension HHWebViewController:UIWebViewDelegate {
    func webViewDidStartLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        loading = true
        self.title = "加载中..."
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        var title = webView.stringByEvaluatingJavaScriptFromString("document.title")
        if title?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 15 {
            title = "网页"
        }
        self.title = title
        loading = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        loading = false
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        switch (navigationType) {
        case .LinkClicked:
            pushCurrentSnapshotViewWithRequest(request)
            break
        case .FormSubmitted:
            pushCurrentSnapshotViewWithRequest(request)
            break
        case .BackForward: break
        case .Reload:break
        case .FormResubmitted:break
        case .Other:
            pushCurrentSnapshotViewWithRequest(request)
            break
        }
        updateNavigationItems()
        return true
    }
}
