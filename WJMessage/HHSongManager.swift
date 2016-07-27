//
//  HHSongManager.swift
//  WJMessage
//
//  Created by apple on 16/7/27.
//  Copyright © 2016年 WhoJun. All rights reserved.
//

import Foundation
//typedef NS_ENUM(NSUInteger, TMSongType) {
//    TMSongTypeSong,
//    TMSongTypeShock,
//    TMSongTypeSongAndShock,
//};
enum HHSongType:Int {
    case SongAndShock
    case Song
    case Shock
    case None
}

class HHSongManager: NSObject {
    var type = HHSongType.SongAndShock {
        didSet {
            saveData()
        }
    }
    var songFile = "/System/Library/Audio/UISounds/sms-received1.caf" {
        didSet {
            saveData()
        }
    }
    private var fileName = ""
    
    //document/HHSong/fileName
    init(fileName:String) {
        super.init()
        self.fileName = fileName
        setup()
    }
    
    private func setup() {
        if let dict = songData() {
            type = HHSongType(rawValue: dict["type"] as! Int)!
            songFile = dict["songFile"] as! String
        }
    }
    
    private func songData() -> [String:AnyObject]? {
        let path = createDirectory() + "/" + fileName
        if let dict = NSDictionary(contentsOfFile: path) {
            return dict as? [String:AnyObject]
        }
        return nil
    }
    
    private func saveData() {
        let path = createDirectory() + "/" + fileName
        NSDictionary(dictionary: ["type":type.rawValue,"songFile":songFile]).writeToFile(path, atomically: true)
    }
    
    private func createDirectory() -> String {
        if let document =  NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first {
            let dire = document + "/HHSong"
            let file = NSFileManager.defaultManager()
            if  !file.fileExistsAtPath(dire) {
                try! file.createDirectoryAtPath(dire, withIntermediateDirectories: true, attributes: nil)
            }
            return dire
        }
        return ""
    }
    
    func playSong()  {
        switch type {
        case .SongAndShock:
            var soundID: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath: songFile),&soundID)
            AudioServicesPlaySystemSound(soundID)
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            break
        case .Shock:
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break
        case .Song:
            var soundID: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(NSURL(fileURLWithPath: songFile),&soundID)
            AudioServicesPlaySystemSound(soundID)
            break
        default:
            break;
        }
    }
}
