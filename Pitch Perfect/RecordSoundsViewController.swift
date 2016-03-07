//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Robert Chynoweth on 9/20/15.
//  Copyright (c) 2015 Robert Chynoweth. All rights reserved.
//

import AVFoundation
import UIKit

internal final class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet private weak var recordingLabel: UILabel!
    @IBOutlet private weak var stopButton: UIButton!
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var pauseButton: UIButton!
    @IBOutlet private weak var resumeButton: UIButton!
    
    private var audioRecorder: AVAudioRecorder!
    private var recordedAudio: RecordedAudio!
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override internal func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        stopButton.hidden = true
        recordButton.enabled = true
        pauseButton.enabled = false
        resumeButton.enabled = false
    }

    override internal func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction private func recordAudio(sender: UIButton) {
        updateUIHiddenFields(true)
        
        pauseButton.enabled = true
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
        
        let recordingName = "newTempWavFile.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try! audioRecorder = AVAudioRecorder(URL: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction internal func stopRecording(sender: UIButton) {
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        updateUIHiddenFields(false)
    }
    
    private func updateUIHiddenFields(isRecording: Bool) {
        recordingLabel.text = isRecording ? "Recording in Progress" : "Tap to Record"
        stopButton.hidden = !isRecording
        recordButton.enabled = !isRecording
    }
    
    internal func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag) {
            recordedAudio = RecordedAudio(filePathUrl: recorder.url, title: recorder.url.lastPathComponent!)
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        }
        else {
            updateUIHiddenFields(false)
        }
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        audioRecorder.pause()
        pauseResumeEnable(false)
    }
    
    @IBAction func resumeRecording(sender: UIButton) {
        audioRecorder.record()
        pauseResumeEnable(true)
    }
    
    private func pauseResumeEnable(paused: Bool) {
        pauseButton.enabled = paused
        resumeButton.enabled = !paused
    }
    
    override internal func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "stopRecording") {
            let playSoundsVC: PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
}
