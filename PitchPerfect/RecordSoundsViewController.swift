//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Lawrence Nyakiso on 2016/01/28.
//  Copyright © 2016 KisoCloud. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var inPogresstext: UILabel!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var tapToStartText: UILabel!
    @IBOutlet weak var recordingInterval: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var flashingText: UILabel!
    
    var audioRecorder:AVAudioRecorder!
    var recordedAudio:RecordedAudio!
    var blinkTimer = NSTimer()
    var recorderTimer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        stopButton.hidden = true
        tapToStartText.hidden = false
        inPogresstext.hidden = true
        recordingInterval.hidden = true
        pauseButton.hidden = true
        resumeButton.hidden = true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func recordAudio(sender: UIButton) {
        //show stop button
        stopButton.hidden = false
        tapToStartText.hidden = true
        inPogresstext.hidden = false
        recordingInterval.hidden = false
        pauseButton.hidden = false
        
        //make the label blink while recording
        
        let blinker : Selector = "blinker"
        blinkTimer = NSTimer(timeInterval: 0.5, target: self, selector: blinker, userInfo: nil, repeats: true)
        //attach the timer to the NSRunLoop
        NSRunLoop.currentRunLoop().addTimer(blinkTimer, forMode: NSRunLoopCommonModes)
        
        //show the recording time/interval
        let recorderTime : Selector = "recorderTime"
        recorderTimer = NSTimer(timeInterval: 0.1, target: self, selector: recorderTime, userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(recorderTimer, forMode: NSRunLoopCommonModes)
        
        let fileName:String = "userVoice.wav"
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let fileURL = NSURL.fileURLWithPathComponents([documentDirectory,fileName])
        
        //start a recording session
        let recordingSession = AVAudioSession.sharedInstance()
        try! recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
    
        //setup AVAudio Recorder
        try! audioRecorder = AVAudioRecorder(URL: fileURL!, settings: [:])
        
        //record audio
        audioRecorder.delegate = self
        audioRecorder.prepareToRecord()
        audioRecorder.meteringEnabled = true
        audioRecorder.updateMeters()
        
        audioRecorder.record()
        
    }
    
    func blinker(){
        if(inPogresstext.alpha == 0){
            inPogresstext.alpha = 1
        }else{
            inPogresstext.alpha = 0
        }
    }
    
    func recorderTime(){
        
        let min:Int = Int(audioRecorder.currentTime / 60)
        let sec:Int = Int(audioRecorder.currentTime % 60)
        let time:String = "\(String(min)):\(String(sec))"
        recordingInterval.text = time
        audioRecorder.updateMeters()
        
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if(flag){
            //Improvement: contructor
            let recordedAudio = RecordedAudio(fileURL: recorder.url, fileTitle: recorder.url.lastPathComponent!)
        
            //navigate to the next screen, using the seque
            self.performSegueWithIdentifier("recordedSounds", sender: recordedAudio)
            
        }else{
            
            print("Looks like something went wrong")
            
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //hand over the data to the next view
        if(segue.identifier == "recordedSounds"){
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.recievedAudio = data
        }
    }
    
    @IBAction func stopRecording(sender: UIButton) {
        blinkTimer.invalidate()
        inPogresstext.hidden = false
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    @IBAction func pauseRecording(sender: UIButton) {
        pauseButton.hidden = true
        resumeButton.hidden = false
        audioRecorder.pause()
        flashingText.text = "PAUSED"
        
    }
    @IBAction func resumeRecording(sender: UIButton) {
        pauseButton.hidden = false
        resumeButton.hidden = true
        audioRecorder.record()
        flashingText.text = "RECORDING IN PROGRESS"
    }
}

