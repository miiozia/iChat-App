//
//  AudioRecorder.swift
//  iChat
//
//  Created by Marta Miozga on 09/11/2024.
//

import Foundation
import AVFoundation

class AudioRecorder: NSObject, AVAudioRecorderDelegate{
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var isAudioRecording: Bool!
    
    static let shared = AudioRecorder()
    
    private override init(){
        super.init()
        checkForRecordPermission()
    }
    
    func checkForRecordPermission(){
        switch AVAudioSession.sharedInstance().recordPermission{
        case .granted:
            isAudioRecording = true
            break
        case .denied:
            isAudioRecording = false
            break
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { isAllowed in
                self.isAudioRecording = isAllowed
            }
        default:
            break
            
        }
    }
    
    func setupRecord(){
        if isAudioRecording {
            recordingSession = AVAudioSession.sharedInstance()
            do{
                try recordingSession.setCategory(.playAndRecord, mode: .default)
                try recordingSession.setActive(true)
            }catch{
                print("error setting up audio recorder ", error.localizedDescription)
            }
        }
    }
    
    func startRecording(fileName: String){
        let audioName = getURL().appendingPathComponent(fileName + ".m4a", isDirectory: false)
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey : 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            
        ]
        
        do{
            audioRecorder = try  AVAudioRecorder(url: audioName, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        }catch{
            print("Error recording", error.localizedDescription)
            stopRecording()
        }
    }
    
    func stopRecording(){
        if audioRecorder != nil{
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
}
