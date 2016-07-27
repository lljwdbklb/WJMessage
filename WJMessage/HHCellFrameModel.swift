//
//  HHCellFrameModel.swift
//  WJMessage
//
//  Created by apple on 16/7/6.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

class HHCellFrameModel: NSObject {
    var message : HHMessageModel?
    var messageId: String?{ get{return message?.messageId} }//消息Id
    var sessionId: String?{ get{return message?.sessionId} }//会话Id
    var from: String?{ get{return message?.from} } //发送方
    var to: String? { get{return message?.to} } //接收方
    var content: String?{ get{return message?.content} } //内容
    var url: String?{ get{return message?.url} } //内容
    var bodyType: HHMessageBodyType { get{return (message?.bodyType)!} } //内容
    var ext: Dictionary<String,AnyObject>?{ get{return message?.ext} } //扩展
    var time: String?{ get{return message?.time} } //时间 yyyy-MM-dd HH:mm:ss
    var isRead:Bool? { get{return message?.isRead} }//是否已读
    var status:HHMessageStatus?{ get{return message?.status} }
    var chatType:HHMessageType?{ get{return message?.chatType} }
    var direction:HHMessageDirection?{ get{return message?.direction} }
    var isSender:Bool { get{ return self.direction == .Send } }
    var cellHeight: CGFloat = 0.0
    var avatar: UIImage? = UIImage(named:"morentouxiang")//默认头像
    var avatarURLPath: String?
    var body = ""
    var attrBody: NSAttributedString?
    var image:UIImage?{ get{ return message?.image } }
    var failImage = UIImage(named: "default_photos_images_error")
    var loadImage = UIImage(named: "default_photos_images")
    
    init(message:HHMessageModel) {
        super.init()
        self.message = message
        _setContent()
    }
    func _setContent() {
        if message?.bodyType == .Text {
            self.body = self.message!.content!
        }
        
    }
}
