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
    
    fileprivate let viewModel = RoomViewModel()
    
    var listener: Listener?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let listener = Listener(language: Environment.isJapanese ? . japanese : .english)
        self.listener = listener
        listener.requestAuthorization(authorizationCompletion: { (result) in
            switch result {
            case .success:
                print("auth success")
            case .failure(let error):
                print("auth error: \(error)")
            }
        }, didChangeAvailability: { (available) in
            print("available: \(available)")
        }) { [unowned self] (result) in
            switch result {
            case .newString(let string):
                print("翻訳します: \(string)")
                self.viewModel.translate(input: string)
            case .stop:
                print("stop")
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        viewModel.setupConnection()
        
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

extension RoomViewController: RoomViewModelDelegate {
    func added() {
        let insertingIndexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [insertingIndexPath], with: .top)
    }
}

// MARK: - MultipeerConnectivity

struct ChatPost {
    let isMyPost: Bool
    let isTranslated: Bool
    let text: String
}
