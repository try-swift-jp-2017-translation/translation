//
//  ConnectionManager.swift
//  Translation
//
//  Created by Yusuke Kuroiwa on 2017/03/04.
//  Copyright © 2017年 Try! Swift. All rights reserved.
//

import Foundation
import PeerKit

enum Language: String {
    case english
    case japanese
}

struct ConnectionManager {
    
    enum Event: String {
        case language
        case text
    }
    
    private static let transceiveName = "translation"
    
    static func start() {
        PeerKit.transceive(serviceType: transceiveName)
    }
    
    static func onConnect(run: PeerBlock?) {
        PeerKit.onConnect = run
    }
    
    static func onDisconnect(run: PeerBlock?) {
        PeerKit.onDisconnect = run
    }
    
    static func onEvent(event: Event, run: ObjectBlock?) {
        if let run = run {
            eventBlocks[event.rawValue] = run
        } else {
            eventBlocks.removeValue(forKey: event.rawValue)
        }
    }
    
    static func setup(language: Language) {
        let object = ["language": language.rawValue] as AnyObject
        sendEvent(Event.language.rawValue, object: object)
    }
    
    static func sendTranslated(text: String) {
        let object = ["text": text] as AnyObject
        sendEvent(Event.text.rawValue, object: object)
    }
    
}
