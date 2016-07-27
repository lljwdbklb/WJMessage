//
//  HHSessionModel.swift
//  WJMessage
//
//  Created by apple on 16/7/4.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import UIKit

@objc enum HHSessionType: Int {
    case Chat
    case GroupChat
}

class HHSessionModel: NSObject {
    
    var sessionId : String?
    var name : String?
    var unreadMessagesCount = 0
    var type = HHSessionType.Chat
    var lastMessage : HHMessageModel?
    
    
    
    
    
    class func loadSessions()->Array<HHSessionModel>? {
        var array = Array<HHSessionModel>()
        
        let session1 = HHSessionModel()
        session1.name = "哈哈"
        session1.type = .Chat
        session1.unreadMessagesCount = 5
        session1.sessionId = "user15"
        session1.lastMessage = HHMessageModel.loadMessages(session1.sessionId, messageId: nil, alime: 0)?.first
        array.append(session1)

        return array
    }
}
