//
//  RoomViewController.swift
//  Translation
//
//  Created by Kazuya Okamoto on 2017/03/04.
//  Copyright © 2017年 Try! Swift. All rights reserved.
//

import UIKit

class RoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate let tableView = UITableView()
    
    fileprivate var chatPosts = [
        ChatPost(isMyPost: true, text: "こんにちわ"),
        ChatPost(isMyPost: false, text: "Hello"),
        ChatPost(isMyPost: true, text: "おはよ\n\n\n\nう"),
        ChatPost(isMyPost: false, text: "Good morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morningGood morning"),
        ChatPost(isMyPost: true, text: "こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  こんにちわ  "),
        ChatPost(isMyPost: false, text: "Hello"),
        ChatPost(isMyPost: true, text: "おはよ\n\n\n\nう"),
        ChatPost(isMyPost: false, text: "Good morning"),
        ChatPost(isMyPost: true, text: "こんにちわ"),
        ChatPost(isMyPost: false, text: "Hello"),
        ChatPost(isMyPost: true, text: "おはよ\n\n\n\nう"),
        ChatPost(isMyPost: false, text: "Good morning"),
        ChatPost(isMyPost: true, text: "こんにちわ"),
        ChatPost(isMyPost: false, text: "Hello"),
        ChatPost(isMyPost: true, text: "おはよ\n\n\n\nう"),
        ChatPost(isMyPost: false, text: "Good morning"),
        ChatPost(isMyPost: true, text: "こんにちわ"),
        ChatPost(isMyPost: false, text: "Hello"),
        ChatPost(isMyPost: true, text: "おはよ\n\n\n\nう"),
        ChatPost(isMyPost: false, text: "Good morning"),
        ChatPost(isMyPost: true, text: "こんにちわ"),
        ChatPost(isMyPost: false, text: "Hello"),
        ChatPost(isMyPost: true, text: "おはよ\n\n\n\nう"),
        ChatPost(isMyPost: false, text: "Good morning"),
        ChatPost(isMyPost: true, text: "こんにちわ"),
        ChatPost(isMyPost: false, text: "Hello"),
        ChatPost(isMyPost: true, text: "おはよ\n\n\n\nう"),
        ChatPost(isMyPost: false, text: "Good morning"),
        ChatPost(isMyPost: true, text: "こんにちわ"),
        ChatPost(isMyPost: false, text: "Hello"),
        ChatPost(isMyPost: true, text: "おはよ\n\n\n\nう"),
        ChatPost(isMyPost: false, text: "Good morning"),
        ChatPost(isMyPost: true, text: "こんにちわ"),
        ChatPost(isMyPost: false, text: "Hello"),
        ChatPost(isMyPost: true, text: "おはよ\n\n\n\nう"),
        ChatPost(isMyPost: false, text: "Good morning"),
        ]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatPosts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        func dequeue(chatPost: ChatPost) -> ChatPostCell? {
            if chatPost.isMyPost {
                return tableView.dequeueReusableCell(withIdentifier: "right") as? RightCell
            } else {
                return tableView.dequeueReusableCell(withIdentifier: "left") as? LeftCell
            }
        }
        
        let chatPost = chatPosts[indexPath.row]
        
        if let cell = dequeue(chatPost: chatPost) {
            cell.fill(text: chatPost.text)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt: IndexPath) {
        let chatPost = chatPosts[didSelectRowAt.row]
        addChatPost(chatPost: chatPost)
    }
    
    func addChatPost(chatPost: ChatPost) {
        let insertingIndexPath = IndexPath(row: chatPosts.count, section: 0)
        var newPosts = chatPosts
        newPosts.append(chatPost)
        
        chatPosts = newPosts
        tableView.insertRows(at: [insertingIndexPath], with: .bottom)
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



struct ChatPost {
    let isMyPost: Bool
    let text: String
}


