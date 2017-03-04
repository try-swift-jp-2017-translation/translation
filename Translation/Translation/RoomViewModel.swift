//
//  RoomViewModel.swift
//  Translation
//
//  Created by Kazuya Okamoto on 2017/03/04.
//  Copyright © 2017年 Try! Swift. All rights reserved.
//

import Foundation
import MultipeerConnectivity


class RoomViewModel {
    let translater = TryTranslate()
    
    fileprivate var peers: [Peer]?
    
    weak var delegate: RoomViewModelDelegate?
    
    private(set) var posts: [ChatPost] =  [
        ChatPost(isMyPost: true, isTranslated: false, text: "こんにちわ"),
        ChatPost(isMyPost: false, isTranslated: false, text: "Hello"),
        ChatPost(isMyPost: true, isTranslated: false, text: "おはよう"),
        ChatPost(isMyPost: false, isTranslated: false,  text: "Good morning"),
    ]
    
    func translate(input: String) {
        
        add(chatPost: ChatPost(isMyPost: true, isTranslated: false, text: input))
        
        let translateType: TranslateType = {
            if Environment.isJapanese {
                return .j2e
            } else {
                return .e2j
            }
        }()
        translater.translate(inputText: input, type: translateType, callback: { translated in
            DispatchQueue.main.async {
                ConnectionManager.sendTranslated(text: translated)
            }
        })
    }
    
    func add(chatPost: ChatPost) {
        posts.insert(chatPost, at: 0)
        delegate?.added()
    }
    
}

extension RoomViewModel {
    
    /// 接続開始
    /// 各種イベントを受け取る
    func setupConnection() {
        ConnectionManager.start()
        receiveEvent()
    }
    
    /// 各種イベントを受け取る
    func receiveEvent() {
        ConnectionManager.onConnect { [weak self] (myPeerID, peerID) in
            print("特定の端末が接続された: \(myPeerID.displayName), \(peerID.displayName)")
            self?.sendLanguage()
        }
        
        ConnectionManager.onDisconnect { [weak self] (myPeerID, peerID)  in
            print("特定の端末が切断された: \(myPeerID.displayName), \(peerID.displayName)")
            self?.receive(removePeerID: peerID)
        }
        
        ConnectionManager.onEvent(event: .language) { [weak self] (peerID, object) in
            print("言語を受け取りました \(peerID): \(object)")
            self?.receive(language: object, from: peerID)
        }
        
        ConnectionManager.onEvent(event: .text) { [weak self] (peerID, object) in
            print("テキストを受け取りました \(peerID): \(object)")
            self?.receive(text: object, from: peerID)
        }
        
        //        ConnectionManager.sendTranslated(text: "hogehoge translated text.")
    }
    
    private func receive(removePeerID: MCPeerID) {
        // TODO: remove impl.
    }
    
    /// 言語を受け取る
    ///
    /// - Parameters:
    ///   - language: 言語
    ///   - peerID: PeerID
    private func receive(language: AnyObject?, from peerID: MCPeerID) {
        guard let data = language else { return }
        guard let language = data["language"] as? String else { return }
        print("displayName: \(peerID.displayName), language: \(language)")
        let peer = Peer(peerID: peerID, language: language)
        peers?.append(peer)
    }
    
    /// 変換されたテキストを受け取る
    ///
    /// - Parameters:
    ///   - text: テキスト
    ///   - peerID: PeerID
    private func receive(text: AnyObject?, from peerID: MCPeerID) {
        guard let data = text else { return }
        guard let text = data["text"] as? String else { return }
        print("displayName: \(peerID.displayName), text: \(text)")
        DispatchQueue.main.async {
            self.add(chatPost: ChatPost(isMyPost: false, isTranslated: true, text: text))
            // 画面描画
        }
    }
    
    /// 現在言語を送信する
    func sendLanguage() {
        ConnectionManager.setup(language: Environment.preferredLanguage)
    }
}

protocol RoomViewModelDelegate: class {
    func added()
}
