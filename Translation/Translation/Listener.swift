//
//  Listener.swift
//  Listener
//
//  Created by Yu Sugawara on 2017/03/04.
//  Copyright © 2017年 Yu Sugawara. All rights reserved.
//

import Foundation
import Speech
import Accelerate

public class Listener: NSObject, SFSpeechRecognizerDelegate {
    
    public static var bufferCount: Int64 = 6
    
    public enum Language {
        case english
        case japanese
        
        fileprivate var locale: Locale {
            return Locale(identifier: identifier)
        }
        
        private var identifier: String {
            switch self {
            case .english:
                return "en-US"
            case .japanese:
                return "ja-JP"
            }
        }
    }
    
    private let speechRecognizer: SFSpeechRecognizer
    
    public init(language: Language) {
        speechRecognizer = SFSpeechRecognizer(locale: language.locale)!
        super.init()
        speechRecognizer.delegate = self
    }
    
    // MARK: - Authrization
    
    public enum AuthorizationResult {
        case success
        case failure(Error)
    }
    
    private var didChangeAvailability: ((Bool) -> Void)?
    private var didReceiveResult: ((RecognitionResult) -> Void)?
    
    public func requestAuthorization(authorizationCompletion: @escaping ((AuthorizationResult) -> Void),
                                     didChangeAvailability: @escaping ((Bool) -> Void),
                                     didReceiveResult: @escaping ((RecognitionResult) -> Void))
    {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self.didChangeAvailability = didChangeAvailability
                    self.didReceiveResult = didReceiveResult
                    authorizationCompletion(.success)
                case .denied:
                    authorizationCompletion(.failure(NSError(domain: "com.yusuga.Listener",
                                                code: 0,
                                                userInfo: [NSLocalizedDescriptionKey: "denied"])))
                case .restricted:
                    authorizationCompletion(.failure(NSError(domain: "com.yusuga.Listener",
                                                code: 0,
                                                userInfo: [NSLocalizedDescriptionKey: "restricted"])))
                case .notDetermined:
                    authorizationCompletion(.failure(NSError(domain: "com.yusuga.Listener",
                                                code: 0,
                                                userInfo: [NSLocalizedDescriptionKey: "notDetermined"])))
                }
            }
        }
    }
    
    // MARK: - Recognition
    
    private let audioEngine = AVAudioEngine()
    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?

    private var startTime: AVAudioTime?
    private var receivedTime: AVAudioTime?
    private var recognizedTime: AVAudioTime?
    private var recognizedString: String? {
        didSet {
            if recognizedString != nil {
                print("update")
                recognizedTime = receivedTime
            }
        }
    }
    
    public enum RecognitionResult {
        case newString(String)
        case stop
    }
    
    public func startRecording() throws {
        stopRecording()
        print("start")
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                self.recognizedString = result.bestTranscription.formattedString
                print(self.recognizedString)
            }
            
            if let error = error {
//                self.stopRecording()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            if self.startTime == nil {
                self.startTime = when
            }
            
            if let recognizedTime = self.recognizedTime {
                let diff = when.sampleTime - recognizedTime.sampleTime
//                print("diff: \(diff)")
                if diff > 4410*Listener.bufferCount {
                    try! self.startRecording()
                    return
                }
            } else if let startTime = self.startTime {
                let diff = when.sampleTime - startTime.sampleTime
                if diff > 4410 * 30 {
                    print("timeout")
                    try! self.startRecording()
                    return
                }
            }
            
            self.receivedTime = when
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
    }
    
    public func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode?.removeTap(onBus: 0)
        
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        
        startTime = nil
        receivedTime = nil
        recognizedTime = nil
        
        if let recognizedString = self.recognizedString {
            didReceiveResult?(.newString(recognizedString))
            self.recognizedString = nil
        } else {
            didReceiveResult?(.stop)
        }
    }
    
    // MARK: SFSpeechRecognizerDelegate
    
    @nonobjc public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        didChangeAvailability?(available)
    }    
    
}
