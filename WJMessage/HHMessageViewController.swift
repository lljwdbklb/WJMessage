//
//  HHMessageViewController.swift
//  WJMessage
//
//  Created by apple on 16/7/4.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

class HHMessageViewController: UIViewController,HHMessageMoreViewDelegate {
    let tableView = UITableView()
    var session: HHSessionModel?            //当前会话
    var moreView: HHMessageMoreView?        //多功能
    var recordView: UIView?                 //录音
    var faceView: HHMessageFaceView?        //表情
    var chatToolbar: HHMessageChatToolbar?  //输入框
    var chatToolBarBottomConstraint:NSLayoutConstraint?
    
    var faceViewHeight:CGFloat = 200
    var recordViewHeight:CGFloat = 200
    var moreViewHeight:CGFloat = 200
    
    var menuController = UIMenuController()   //菜单
    var copyMenuItem :UIMenuItem?           //拷贝
    var deleteMenuItem :UIMenuItem?         //删除
    var transpondMenuItem :UIMenuItem?     //分享
    var menuIndexPath: NSIndexPath?         //选中的cell位置
    var lpg :UILongPressGestureRecognizer?
    
    
    var messages = Array<AnyObject>()
    var messageQueue = dispatch_queue_create("ekangzhi.com", nil)
    
    var timeCellHeight:CGFloat = 30.0
    var messageTimeIntervalTag:NSTimeInterval = -1
    
    var timeFont = UIFont.systemFontOfSize(12)
    
    var seletedIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setup()
        _setupSubView()
        loadData()
    }
    
    private func _setup()  {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(didHideMenuNotification), name: UIMenuControllerDidHideMenuNotification, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(keyBoardHidden(_:))))
        lpg = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        lpg?.minimumPressDuration = 0.5
        view.addGestureRecognizer(lpg!)
    }
    
    func didHideMenuNotification() {
        self.menuIndexPath = nil
        self.menuController.menuItems = nil
    }

    
    func keyBoardHidden(tapRecognizer:UITapGestureRecognizer)  {
        if tapRecognizer.state == UIGestureRecognizerState.Ended {
            self.chatToolbar?.endEditing(true)
        }
    }
    
    func handleLongPress(recognizer:UILongPressGestureRecognizer)  {
        if recognizer.state == .Began && messages.count > 0 {
            let location = recognizer.locationInView(self.tableView)
            if let indexPath = tableView.indexPathForRowAtPoint(location) {
                let obj = messages[indexPath.row]
                if !(obj is String) {
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as! HHMessageCell
                    if !self.chatToolbar!.textView.isFirstResponder() {
                        cell.becomeFirstResponder()
                    }
                    menuIndexPath = indexPath
                    _showMenu(cell.bubbleView!, indexPath: indexPath, messageType: cell.model!.message!.bodyType)
                }
            }
        }
    }
    
    func loadData()  {
        dispatch_async(messageQueue, {//异步加载处理数据
            if let ms = HHMessageModel.loadMessages(self.session!.sessionId, messageId: nil, alime: 10) {
                if ms.count == 0 {
                    return
                }
                let formatMessages = self.formatMessages(ms)//数据处理
                let scrollToIndex = self.messages.count
                self.messages = formatMessages + self.messages
                if let last = self.messages.last as? HHCellFrameModel {
                    let date = NSDate.date(last.message!.time!, format: "yyyy-MM-dd HH:mm:ss")
                    let timestamp = date!.timeIntervalSince1970
                    self.messageTimeIntervalTag = timestamp
                }
                //刷新
                dispatch_async(dispatch_get_main_queue(), {//主线程刷新
                    self.tableView.reloadData()
                    self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.messages.count - scrollToIndex - 1, inSection: 0), atScrollPosition: .Top, animated: false)
                })
                
            }
        })
    }
    
    //MARK: - Private
    private func formatMessages(messages:Array<HHMessageModel>)->Array<AnyObject> {
        var formatArray = Array<AnyObject>()
        if messages.count <= 0 {
            return formatArray
        }
        for message in messages {
            let date = NSDate.date(message.time!, format: "yyyy-MM-dd HH:mm:ss")
            let timestamp = date!.timeIntervalSince1970
            let interval = (self.messageTimeIntervalTag - timestamp)
            if self.messageTimeIntervalTag < 0 || interval > 60 || interval < -60 {
                formatArray.append(message.time!)
                self.messageTimeIntervalTag = timestamp;
            }
            
            let frame = HHCellFrameModel(message: message)
            formatArray.append(frame)
        }
        return formatArray
    }
    
    private func _setupSubView() {
        title = session?.name
        view.backgroundColor = UIColor .whiteColor()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .None
        view.addSubview(self.tableView)
        
        chatToolbar = HHMessageChatToolbar()
        chatToolbar?.delegate = self
        chatToolbar?.translatesAutoresizingMaskIntoConstraints = false
        chatToolbar?.backgroundColor = UIColor.whiteColor()
        view.addSubview(self.chatToolbar!)
        
        faceView = HHMessageFaceView()
        faceView?.translatesAutoresizingMaskIntoConstraints = false
        faceView?.hidden = true
        faceView?.backgroundColor = UIColor.whiteColor()
        faceView?.delegate = self
        view.addSubview(faceView!)
        
        recordView = UIView()
        recordView?.translatesAutoresizingMaskIntoConstraints = false
        recordView?.hidden = true
        recordView?.backgroundColor = UIColor.purpleColor()
        view.addSubview(recordView!)
        
        moreView = HHMessageMoreView()
        moreView?.translatesAutoresizingMaskIntoConstraints = false
        moreView?.hidden = true
        moreView?.delegate = self
        moreView?.backgroundColor = UIColor.clearColor()
        view.addSubview(moreView!)
        
        _setupLayout()
        _setupEmotion()
        _setupMoreItem()
        
        HHMessageCell.appearance().bubbleSendImage = UIImage(named: "chatto_bg_normal")
        HHMessageCell.appearance().bubbleReceiveImage = UIImage(named: "chatfrom_bg_normal")
    }
    
    private func _setupLayout() {
        chatToolBarBottomConstraint = NSLayoutConstraint(item: chatToolbar!, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        view.addConstraint(chatToolBarBottomConstraint!)
        view.addConstraint(NSLayoutConstraint(item: chatToolbar!, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: chatToolbar!, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
    
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: chatToolbar, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        
        _setupRecordView()
        _setupFaceView()
        _setupMoreView()
    }
    
    private func _setupRecordView() {
        view.addConstraint(NSLayoutConstraint(item: recordView!, attribute: .Top, relatedBy: .Equal, toItem: chatToolbar, attribute: .Bottom, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: recordView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: recordViewHeight))
        view.addConstraint(NSLayoutConstraint(item: recordView!, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: recordView!, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
    }
    
    private func _setupFaceView() {
        view.addConstraint(NSLayoutConstraint(item: faceView!, attribute: .Top, relatedBy: .Equal, toItem: chatToolbar, attribute: .Bottom, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: faceView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: faceViewHeight))
        view.addConstraint(NSLayoutConstraint(item: faceView!, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: faceView!, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
    }
    
    private func _setupMoreView() {
        view.addConstraint(NSLayoutConstraint(item: moreView!, attribute: .Top, relatedBy: .Equal, toItem: chatToolbar, attribute: .Bottom, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: moreView!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: moreViewHeight))
        view.addConstraint(NSLayoutConstraint(item: moreView!, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: moreView!, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        
    }
    
    private func _setupEmotion() {
        var array = Array<EaseEmotion>()
        for str in EaseEmoji.allEmoji() {
            let name = str as! String
            let emotion = EaseEmotion(name: "", emotionId: name, emotionThumbnail: name, emotionOriginal: name, emotionOriginalURL: "", emotionType: .Default)
             array.append(emotion)
        }
        let emotion = array.first
        let manager = EaseEmotionManager(type: .Default, emotionRow: 3, emotionCol: 7, emotions: array, tagImage: UIImage(named: (emotion?.emotionId)!))
        faceView?.emotionManagers = [manager]
        
    }
    
    private func _setupMoreItem() {
        var array = Array<HHMoreItem>()
        let item1 = HHMoreItem()
        item1.title = "随访表"
        item1.icon = UIImage(named: "sfb")
        array.append(item1)
        let item2 = HHMoreItem()
        item2.title = "随访单"
        item2.icon = UIImage(named: "sftc_")
        array.append(item2)
        moreView?.items = array
    }
    
    //MARK: Public
    func _scrollViewToBottom(animated: Bool) {
        if self.tableView.contentSize.height > self.tableView.frame.size.height {
            let offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
            self.tableView.setContentOffset(offset, animated: animated)
        }
    }
    //MARK: 选择更多菜单
    func didSelectMoreItem(index: Int) {
        debugPrint("\(index)")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}

//MARK: - UITableViewDelegate UITableViewDataSource
extension HHMessageViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        if message is String {
            var timeCell = tableView.dequeueReusableCellWithIdentifier(HHMessageTimeCell.cellIdentifier) as? HHMessageTimeCell
            
            if timeCell == nil {
                timeCell = HHMessageTimeCell(style: UITableViewCellStyle.Default, reuseIdentifier: HHMessageTimeCell.cellIdentifier)
            }
            timeCell?.titleLabelFont = self.timeFont
            timeCell?.title = message as! String
            return timeCell!
        }
        let cellIdentifier = HHMessageCell.cellIdentifier(message as! HHCellFrameModel)
        var messageCell = tableView .dequeueReusableCellWithIdentifier(cellIdentifier) as? HHMessageCell
        if messageCell == nil {
            messageCell = HHMessageCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier,model: message as! HHCellFrameModel)
        }
        debugPrint("\(messageCell?.statusSize)")
        messageCell?.model = message as? HHCellFrameModel
        messageCell?.delegate = self
        return messageCell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message = messages[indexPath.row]
        if message is String {
            return timeCellHeight
        } else {
            return HHMessageCell.cellHeight(message as! HHCellFrameModel)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

//MARK: - HHMessageChatToolbarDelegate
extension HHMessageViewController:HHMessageChatToolbarDelegate {
    func shouldChangeBottomBtn(index: Int) -> Bool {
        if index == 1 {
            self.chatToolbar?.endEditing(true)
            if !HHPhotoController.sharedInstance.openPhotoLibrary(self, count: 1, complation: { (images) in
                if images.count > 0 {
                    self._sendMessageImage(images.first!)
                }
            }) {
                let infoDic = NSBundle.mainBundle().infoDictionary
                let appName = infoDic?["CFBundleName"]
                let text = "请在iPhone的“设置-隐私-照片”选项中，允许\(appName!)访问你的照片。"
                let alert = UIAlertController(title: text, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            }
            return false
        } else if index == 2 {
            self.chatToolbar?.endEditing(true)
            if !HHPhotoController.sharedInstance.openCamera(self, count: 1, complation: { (images) in
                if images.count > 0 {
                    self._sendMessageImage(images.first!)
                }
            }) {
                let infoDic = NSBundle.mainBundle().infoDictionary
                let appName = infoDic?["CFBundleName"]
                let text = "请在iPhone的“设置-隐私-相机”选项中，允许\(appName!)访问你的相机。"
                let alert = UIAlertController(title: text, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "确定", style: .Cancel, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            }
            return false
        }
        return true
    }
    
    func didSendText(text: String) {
        _sendMessageText(text)
    }
    
    func showKeyboard(height: CGFloat) {
        self.chatToolBarBottomConstraint?.constant = -height
        self.view.layoutIfNeeded()
        _scrollViewToBottom(false)
    }
    
    func chatToolbarDidChangeFrameToHeight(height: CGFloat) {
        self.view.layoutIfNeeded()
        _scrollViewToBottom(false)
    }
    
    func didCancelBottomBtn() {
        self.faceView?.hidden = true
        self.moreView?.hidden = true
        self.recordView?.hidden = true
        self.chatToolBarBottomConstraint?.constant = 0
        self.view.layoutIfNeeded()
        seletedIndex = -1
    }
    
    func didSelectedBottomBtn(index: Int) {
        seletedIndex = index
        var constant:CGFloat = 0
        if index == 0 {
            self.recordView?.hidden = false
            constant = -recordViewHeight
        } else if index == 3 {
            self.faceView?.hidden = false
            constant = -faceViewHeight
        } else if index == 4 {
            self.moreView?.hidden = false
            constant = -moreViewHeight
        }
        self.chatToolBarBottomConstraint?.constant = constant
        self.view.layoutIfNeeded()
        self._scrollViewToBottom(false)
    }
    
    func shouldTextViewMenuPaste() -> Bool {
        return self.menuIndexPath == nil
    }
}
extension HHMessageViewController:HHMessageFaceViewDelegate {
    func sendFace() {
        self.chatToolbar!.textView(self.chatToolbar!.textView, shouldChangeTextInRange: NSMakeRange(0, 0), replacementText: "\n")
    }
    
    func selectedFaceView(str: String?, isDelete: Bool) {
        let chatText = self.chatToolbar!.textView.text
        if !isDelete && str?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            self.chatToolbar?.textView.text = ""
            self.chatToolbar?.textView.text = chatText + str!
            self.chatToolbar?.textViewDidChange(self.chatToolbar!.textView)
        } else {
            self.chatToolbar?.textView.deleteBackward()
        }
    }
}
//MARK: - 消息菜单
extension HHMessageViewController {
    func _showMenu(showInView:UIView,indexPath:NSIndexPath,messageType:HHMessageBodyType) {
        if deleteMenuItem == nil {
            deleteMenuItem = UIMenuItem(title: "删除", action: #selector(deleteMenuAction))
        }
        
        if copyMenuItem == nil {
            copyMenuItem = UIMenuItem(title: "拷贝", action: #selector(copyMenuAction))
        }
        
        if transpondMenuItem == nil {
            transpondMenuItem = UIMenuItem(title: "转发", action: #selector(transpondMenuAction))
        }
        
        if messageType == .Text {
            self.menuController.menuItems = [deleteMenuItem!,copyMenuItem!]
        } else if messageType == .Image {
            self.menuController.menuItems = [deleteMenuItem!]
        } else {
            self.menuController.menuItems = [deleteMenuItem!]
        }
        self.menuController.setTargetRect(showInView.frame, inView: showInView.superview!)
        self.menuController.setMenuVisible(true, animated: true)
    }
    
    func deleteMenuAction() {
    }
    
    func copyMenuAction() {
    }
    
    func transpondMenuAction() {
    }
}

extension HHMessageViewController: HHMessageCellDelegate {
    func didSelectCell(model: HHCellFrameModel) {
        var imgs = Array<UIImage>()
        var index = 0
        var selIndex = 0
        if model.bodyType == .Image {
            for (_,obj) in self.messages.enumerate() {
                if obj is HHCellFrameModel {
                    let m = obj as! HHCellFrameModel
                    if m.bodyType == .Image {
                        if model == m {
                            selIndex = index
                        }
                        if let image = m.image {
                            imgs.append(image)
                        } else if let url = m.url {
                            if let image = UIImage(named: url) {
                                imgs.append(image)
                            } else {
                                //网络图片
                            }
                        } else {
                            let image:UIImage
                            if m.status == .Failed {
                                image = m.failImage!
                            } else {
                                image = m.loadImage!
                            }
                            imgs.append(image)
                        }
                        index += 1
                    }
                }
            }
            HHPhotoController.sharedInstance.show(imgs, index: selIndex)
        }
    }
    
    func didStatusButton(model: HHCellFrameModel) {
        //模拟网络请求发送
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(UInt64(arc4random_uniform(5)) * NSEC_PER_SEC)), dispatch_get_main_queue()) {
            model.message!.status = .Successed
            model.cellHeight = 0
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
            })
        }
    }
}

//MARK: - 发送消息
extension HHMessageViewController {
    func _sendMessageText(text:String) {
        if text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) <= 0 {
            return
        }
        //在这发送消息
        let message = HHMessageModel()
        message.sessionId = session?.sessionId
        message.content = text
        _sendMessage(message)
    }
    func _sendMessageImage(image:UIImage) {
        //在这发送消息
        let message = HHMessageModel()
        message.sessionId = session?.sessionId
//        message.content = text
        message.image = image
        message.bodyType = .Image
        
        _sendMessage(message)
    }
    
    func _sendMessage(message: HHMessageModel) {
        message.status = .Delivering
        message.direction = .Send
        message.from = session?.sessionId
        message.to = "user1"
        message.time = NSDate().string("yyyy-MM-dd HH:mm:ss")
        
        
        dispatch_async(messageQueue) {
            let formatMessages = self.formatMessages([message])
            dispatch_async(dispatch_get_main_queue(), {
                self.messages += formatMessages
                self.tableView.reloadData()
                self._scrollViewToBottom(true)
            })
        }
        
        if message.bodyType == .Text {
            
            //模拟网络请求发送
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(UInt64(arc4random_uniform(5)) * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                message.status = .Successed
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        } else {
            FileUpload.saveTempFile(UIImageJPEGRepresentation(message.image!, 0.8)!) { (success, filePath) in
                debugPrint(filePath)
                if success {
                    FileUpload.uploadImage(filePath, completionHandler: { (success, urlString) in
                        debugPrint("")
                        message.url = urlString
                        //模拟网络请求发送
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(UInt64(arc4random_uniform(5)) * NSEC_PER_SEC)), dispatch_get_main_queue()) {
                            message.status = .Successed
                            dispatch_async(dispatch_get_main_queue(), {
                                self.tableView.reloadData()
                            })
                        }
                        FileUpload.deleteTempFile()
                    })
                    
                }
            }
        }
    }
}



