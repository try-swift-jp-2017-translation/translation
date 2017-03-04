//
//  TryTranslate.swift
//  Translation
//
//  Created by 勝田和徳 on 2017/03/04.
//  Copyright © 2017年 Try! Swift. All rights reserved.
//

import Foundation

enum TranslateMethod {
    case Google     // Google翻訳
    case Microsoft  // Microsoft翻訳
}

enum TranslateType {
    case e2j    // 英語　→　日本語
    case j2e    // 日本語　→　英語
    case setInInit      // init(srcLang, dstLang)にて設定
}


let googleApi = "https://www.googleapis.com/language/translate/v2"
let microsoftApi = "http://api.microsofttranslator.com/v2/Http.svc/Translate"

class TryTranslate {
    
    /// Google Translate API Key of 勝田個人のっす（もう使えません）
    private var apiKeyOfGoogle = "APIキーを入れてね❤️"
    
    private var apiKeyOfMicrosoft = ""
    
    private var translateMethod: TranslateMethod = .Google  // Default is Google translate
    private var srcLang = "en"                              // default source is English
    private var dstLang = "ja"                              // default destination is Japanese

    // コンストラクタ
    public init() {
        self.translateMethod = .Google
        self.srcLang = "en"
        self.dstLang = "ja"
    }

    public init(method: TranslateMethod) {
        self.translateMethod = method
    }

    public init(method: TranslateMethod, type: TranslateType) {
        
        self.translateMethod = method
        
        switch type {
        case .e2j:
            self.srcLang = "en"
            self.dstLang = "ja"
            break
        case .j2e:
            self.srcLang = "ja"
            self.dstLang = "en"
            break
        case .setInInit: break
        }
    }

    public init(method: TranslateMethod, srcLang: String, dstLang: String) {
        
        self.translateMethod = method

        self.srcLang = srcLang
        self.dstLang = dstLang
    }
    
    func translate(inputText: String, type: TranslateType, callback:@escaping (_ translatedText:String) -> ()) {
        
        // When input text is empty not to request via http
        guard (inputText != "") else {
            return callback("-")
        }
        
        if self.translateMethod == .Google {
            
            switch type {
            case .e2j:
                self.srcLang = "en"
                self.dstLang = "ja"
                break
            case .j2e:
                self.srcLang = "ja"
                self.dstLang = "en"
                break
            case .setInInit: break
            }

            if let urlEncodedText = inputText.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                if let url = URL(string: "\(googleApi)?key=\(self.apiKeyOfGoogle)&q=\(urlEncodedText)&source=\(self.srcLang)&target=\(self.dstLang)&format=text") {
                    
                    print(url.absoluteString)
                    
                    let httprequest = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                        guard error == nil else {
                            print("Something went wrong: \(error?.localizedDescription)")
                            return
                        }
                        
                        if let httpResponse = response as? HTTPURLResponse {
                            
                            guard httpResponse.statusCode == 200 else {
                                
                                if let data = data {
                                    print("Response [\(httpResponse.statusCode)] - \(data)")
                                }
                                
                                return
                            }
                            
                            do {
                                // Parsing JSON data
//                                Example of JSON from Google
//                                {
//                                    "data": {
//                                        "translations": [
//                                        {
//                                        "translatedText": "こんにちは"
//                                        }
//                                        ]
//                                    }
//                                }
                                if let data = data {
                                    if let json = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                                        if let jsonData = json["data"] as? [String : Any] {
                                            if let translations = jsonData["translations"] as? [NSDictionary] {
                                                if let translation = translations.first as? [String : Any] {
                                                    if let translatedText = translation["translatedText"] as? String {
                                                        callback(translatedText)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } catch {
                                print("Serialization failed: \(error.localizedDescription)")
                            }
                        }
                    })
                    
                    httprequest.resume()
                }
            }
        }
    }
}
