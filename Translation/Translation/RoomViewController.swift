//
//  RoomViewController.swift
//  Translation
//
//  Created by Kazuya Okamoto on 2017/03/04.
//  Copyright © 2017年 Try! Swift. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class RoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate let tableView = UITableView()
    
    fileprivate let viewModel = RoomViewModel()
    
    fileprivate var peers: [Peer]?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupConnection()
        
        viewModel.delegate = self
        
        // tableView
        addSubviewToWhole(subview: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        tableView.register(LeftCell.self, forCellReuseIdentifier: "left")
        tableView.register(RightCell.self, forCellReuseIdentifier: "right")
        tableView.backgroundColor = UIColor(displayP3Red: 239/255, green: 239/255, blue: 244/255, alpha: 1.0)
        tableView.separatorColor = UIColor.clear
        //        tableView.allowsSelection = false
        tableView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        func dequeue(chatPost: ChatPost) -> ChatPostCell? {
            if chatPost.isMyPost {
                return tableView.dequeueReusableCell(withIdentifier: "right") as? RightCell
            } else {
                return tableView.dequeueReusableCell(withIdentifier: "left") as? LeftCell
            }
        }
        
        let chatPost = viewModel.posts[indexPath.row]
        
        if let cell = dequeue(chatPost: chatPost) {
            cell.fill(text: chatPost.text, isTranslated: chatPost.isTranslated)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        let chatPost = viewModel.posts[didSelectRowAt.row]
        viewModel.translate(input: chatPost.text)
    }
}

extension UIViewController {
    func addSubviewForAutolayout(subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subview)
    }
    
    func addSubviewToWhole(subview: UIView) {
        addSubviewForAutolayout(subview: subview)
        topLayoutGuide.bottomAnchor.constraint(equalTo: subview.topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: subview.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: subview.trailingAnchor).isActive = true
        bottomLayoutGuide.topAnchor.constraint(equalTo: subview.bottomAnchor).isActive = true
    }
}

// MARK: - MultipeerConnectivity

extension RoomViewController {
    
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
        guard let languageValue = data["language"] as? String else { return }
        guard let language = Language(rawValue: languageValue) else { return }
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
        guard let language = data["language"] as? String else { return }
        print("displayName: \(peerID.displayName), language: \(language)")
    }
    
    /// 現在言語を送信する
    func sendLanguage() {
        ConnectionManager.setup(language: Environment.preferredLanguage)
    }
}

extension RoomViewController: RoomViewModelDelegate {
    func added() {
        let insertingIndexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [insertingIndexPath], with: .top)
    }
}



struct ChatPost {
    let isMyPost: Bool
    let isTranslated: Bool
    let text: String
}


