//
//  RoomViewModel.swift
//  Translation
//
//  Created by Kazuya Okamoto on 2017/03/04.
//  Copyright © 2017年 Try! Swift. All rights reserved.
//

import Foundation

class RoomViewModel {
    let translater = TryTranslate()
    
    weak var delegate: RoomViewModelDelegate?
    
    private(set) var posts: [ChatPost] =  [
        ChatPost(isMyPost: true, isTranslated: false, text: "こんにちわ"),
        ChatPost(isMyPost: false, isTranslated: false, text: "Hello"),
        ChatPost(isMyPost: true, isTranslated: false, text: "おはよう"),
        ChatPost(isMyPost: false, isTranslated: false,  text: "Good morning"),
    ]
    
    func translate(input: String) {
        
        add(chatPost: ChatPost(isMyPost: true, isTranslated: false, text: input))
        
        translater.translate(inputText: input, type: .j2e, callback: { translated in
            DispatchQueue.main.async {
                self.add(chatPost: ChatPost(isMyPost: true, isTranslated: true, text: translated))
            }
        })
    }
    
    private func add(chatPost: ChatPost) {
        posts.insert(chatPost, at: 0)
        delegate?.added()
    }
    
}

protocol RoomViewModelDelegate: class {
    func added()
}
