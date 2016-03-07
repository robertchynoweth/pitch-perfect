//
//  PlaySoundsViewController.swift
//  Pitch Perfect
//
//  Created by Robert Chynoweth on 9/23/15.
//  Copyright (c) 2015 Robert Chynoweth. All rights reserved.
//

import UIKit
import AVFoundation

internal final class PlaySoundsViewController: UIViewController {

    private var player: AVAudioPlayer!
    private var player2: AVAudioPlayer!
    internal var receivedAudio: RecordedAudio!
    private var audioEngine: AVAudioEngine!
    private var audioFile: AVAudioFile!
    private var reverbPlayers: [AVAudioPlayer] = []
    private let reverbPlayerCount: Int = 10
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        try! AVAudioSession.sharedInstance().setCategory(
            AVAudioSessionCategoryPlayAndRecord,
            withOptions:AVAudioSessionCategoryOptions.DefaultToSpeaker)

        player = try? AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
        player2 = try? AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
        
        player.enableRate = true
        
        audioEngine = AVAudioEngine()
        audioFile = try! AVAudioFile(forReading: receivedAudio.filePathUrl)
        
        for _ in 0...reverbPlayerCount {
            let temp = try? AVAudioPlayer(contentsOfURL: receivedAudio.filePathUrl)
            reverbPlayers.append(temp!)
        }
    }

    internal override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction private func playRecordingSlowly(sender: UIButton) {
        playRecording(0.5)
    }
    
    @IBAction private func playRecordingQuickly(sender: UIButton) {
        playRecording(2.0)
    }
    
    @IBAction private func playChipmunkAudio(sender: UIButton) {
        playAudioWithVariablePitch(1000)
    }
    
    @IBAction private func playDarthvaderAudio(sender: UIButton) {
        playAudioWithVariablePitch(-1000)
    }
    
    private func playAudioWithVariablePitch(pitch:Float){
        stopAll()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attachNode(audioPlayerNode)
        
        let changePitchEffect = AVAudioUnitTimePitch()
        changePitchEffect.pitch = pitch;
        audioEngine.attachNode(changePitchEffect)
        
        audioEngine.connect(audioPlayerNode, to: changePitchEffect, format: nil)
        audioEngine.connect(changePitchEffect, to: audioEngine.outputNode, format: nil)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        try! audioEngine.start()
        audioPlayerNode.play()
    }
    
    @IBAction private func playEchoAudio(sender: UIButton) {
        stopAll()
        
        player.currentTime = 0
        player.rate = 1.0
        player.play()
        
        let delay: NSTimeInterval = 0.1 //100 ms
        let playtime: NSTimeInterval = player2.deviceCurrentTime + delay
        
        player2.stop()
        player2.currentTime = 0
        player2.volume = 0.8
        player2.playAtTime(playtime)
    }
    
    @IBAction private func playReverbAudio(sender: UIButton) {
        stopAll()
        
        let delay: NSTimeInterval = 0.02
        for i in 0...reverbPlayerCount {
            let currentDelay:NSTimeInterval = delay * NSTimeInterval(i)
            let currentPlayer:AVAudioPlayer = reverbPlayers[i]
            //M_E is e=2.718
            //dividing by 2 made it sound ok for the case reverbPlayerCount=10
            let exponent:Double = -Double(i) / Double(reverbPlayerCount / 2)
            let volume = Float(pow(Double(M_E), exponent))
            currentPlayer.volume = volume
            currentPlayer.playAtTime(player.deviceCurrentTime + currentDelay)
        }
    }
    
    @IBAction private func stopPlayingRecording(sender: UIButton) {
        stopAll()
    }
    
    private func playRecording(rate: Float){
        stopAll()
        
        player.currentTime = 0
        player.rate = rate
        player.play()
    }
    
    private func stopAll() {
        player.stop()
        player2.stop()
        audioEngine.stop()
        audioEngine.reset()
        for i in 0...reverbPlayerCount {
            reverbPlayers[i].stop()
            reverbPlayers[i].currentTime = 0
        }
    }
}
