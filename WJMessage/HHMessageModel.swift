//
//  HHMessageModel.swift
//  WJMessage
//
//  Created by apple on 16/7/4.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

enum HHMessageStatus: Int {
    case Pending    //准备发送。。未开始
    case Delivering //正在发送中
    case Successed  //发送成功
    case Failed     //发送失败
}

enum HHMessageType: Int {//聊天类型
    case Chat//单聊
    case GroupChat//群聊
}

enum HHMessageDirection: Int {//消息方向
    case Send//发送
    case Receive//接收
}

enum HHMessageBodyType: Int {
    case Text//文本内容
    case Image//图片内容
}

class HHMessageModel: NSObject {
    var messageId: String?                      //消息Id
    var sessionId: String?                      //会话Id
    var from: String?                           //发送方
    var to: String?                             //接收方
    var content: String?                        //内容文本
    var bodyType = HHMessageBodyType.Text       //消息类型
    var url: String?                            //文件url字符串 图片 语音 等文件
    var image:UIImage?                          //准备上传的图片
    var ext: Dictionary<String,AnyObject>?      //扩展
    var time: String?                           //时间 yyyy-MM-dd HH:mm:ss
    var isRead = false                          //是否已读
    var status = HHMessageStatus.Pending
    var chatType = HHMessageType.Chat
    var direction = HHMessageDirection.Send
    
    class func loadMessages(sessionId:String!,messageId:String?,alime:Int) -> Array<HHMessageModel>? {
        var array = Array<HHMessageModel>()
        if sessionId == "user15" {
            let message = HHMessageModel()
            message.messageId = "1"
            message.sessionId = sessionId
            message.content = "哈哈1"
            message.status = HHMessageStatus.Successed
            message.direction = .Receive
            message.from = "user1"
            message.to = sessionId
            message.time = "2016-07-01 20:35:15"
            array.append(message)
            
            let message1 = HHMessageModel()
            message1.messageId = "2"
            message1.sessionId = sessionId
            message1.content = "哈哈3"
            message1.status = HHMessageStatus.Failed
            message1.direction = .Send
            message1.from = sessionId
            message1.to = "user1"
            message1.time = "2016-07-01 20:35:50"
            array.append(message1)
            
            
            let message2 = HHMessageModel()
            message2.messageId = "3"
            message2.sessionId = sessionId
            message2.content = "哈哈1"
            message2.status = HHMessageStatus.Successed
            message2.direction = .Receive
            message2.from = "user1"
            message2.to = sessionId
            message2.time = "2016-07-01 20:36:15"
            array.append(message2)
            
            
            let message3 = HHMessageModel()
            message3.messageId = "4"
            message3.sessionId = sessionId
            message3.content = "哈哈1"
            message3.status = HHMessageStatus.Successed
            message3.direction = .Receive
            message3.from = "user1"
            message3.to = sessionId
            message3.time = "2016-07-01 20:37:05"
            array.append(message3)
            
            
            let message4 = HHMessageModel()
            message4.messageId = "5"
            message4.sessionId = sessionId
            message4.content = "哈哈afsdkjlkasdjfajsdfkl1jfdlksajflka附近阿克琉斯减肥卢卡斯江东父老卡是对方"
            message4.status = HHMessageStatus.Successed
            message4.direction = .Receive
            message4.from = "user1"
            message4.to = sessionId
            message4.time = "2016-07-02 21:11:15"
            array.append(message4)
            
            let message5 = HHMessageModel()
            message5.messageId = "6"
            message5.sessionId = sessionId
            message5.content = "哈哈1"
            message5.status = HHMessageStatus.Successed
            message5.direction = .Receive
            message5.from = "user1"
            message5.to = sessionId
            message5.time = "2016-07-02 22:35:15"
            array.append(message5)
            
            let message6 = HHMessageModel()
            message6.messageId = "7"
            message6.sessionId = sessionId
            message6.content = "哈哈1"
            message6.status = HHMessageStatus.Successed
            message6.direction = .Receive
            message6.from = "user1"
            message6.to = sessionId
            message6.time = "2016-07-02 22:35:50"
            array.append(message6)
            
            let message7 = HHMessageModel()
            message7.messageId = "8"
            message7.sessionId = sessionId
            message7.url = "iphone_plus"
            message7.bodyType = .Image
            message7.status = HHMessageStatus.Successed
            message7.direction = .Receive
            message7.from = "user1"
            message7.to = sessionId
            message7.time = "2016-07-02 22:36:50"
            array.append(message7)
            
            let message8 = HHMessageModel()
            message8.messageId = "9"
            message8.sessionId = sessionId
            message8.url = "morentouxiang"
            message8.bodyType = .Image
            message8.status = HHMessageStatus.Successed
            message8.direction = .Send
            message8.from = sessionId
            message8.to =  "user1"
            message8.time = "2016-07-02 22:37:50"
            array.append(message8)
            
            let message9 = HHMessageModel()
            message9.messageId = "10"
            message9.sessionId = sessionId
            message9.url = ""
            message9.bodyType = .Image
            message9.status = HHMessageStatus.Failed
            message9.direction = .Receive
            message9.from = "user1"
            message9.to = sessionId
            message9.time = "2016-07-02 22:36:50"
            array.append(message9)
            
            let message10 = HHMessageModel()
            message10.messageId = "11"
            message10.sessionId = sessionId
            message10.url = ""
            message10.bodyType = .Image
            message10.status = HHMessageStatus.Successed
            message10.direction = .Send
            message10.from = sessionId
            message10.to =  "user1"
            message10.time = "2016-07-02 22:37:50"
            array.append(message10)

        }
        
        return array
    }

    
    
    
}
