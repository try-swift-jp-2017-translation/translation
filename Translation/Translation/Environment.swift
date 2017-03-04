//
//  Environment.swift
//  Translation
//
//  Created by Yusuke Kuroiwa on 2017/03/04.
//  Copyright © 2017年 Try! Swift. All rights reserved.
//

import Foundation

struct Environment {
    
    static var preferredLanguage: String {
        return Locale.preferredLanguages.first!
    }
}
