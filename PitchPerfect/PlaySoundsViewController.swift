//
//  PlaySoundsViewController.swift
//  PitchPerfect
//
//  Created by Lawrence Nyakiso on 2016/01/28.
//  Copyright © 2016 KisoCloud. All rights reserved.
//

import UIKit
import AVFoundation

class PlaySoundsViewController: UIViewController {
    
    var recievedAudio:RecordedAudio!
    var audioPlayerEngine:AVAudioEngine!
    var audioFile:AVAudioFile!
    var audioPlayer:AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //set up the player and get the recorded audio
        try! audioPlayer = AVAudioPlayer(contentsOfURL: recievedAudio.fileURL)
        audioPlayer.enableRate = true
        audioPlayerEngine = AVAudioEngine()
        try! audioFile = AVAudioFile(forReading: recievedAudio.fileURL)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func playBackSlow(sender: UIButton) {
        playAudioRate(0.5)
    }

    @IBAction func playBackFast(sender: UIButton) {
        playAudioRate(2.0)
    }
    
    @IBAction func playBackStop(sender: UIButton) {
       stopAudioAndEngine()
    }

    @IBAction func chipMunkEffect(sender: UIButton) {
        playBackPitchEffectVariable(1000)
    }
    
    @IBAction func vaderEffect(sender: UIButton) {
        playBackPitchEffectVariable(-1000)
    }
    
    
    @IBAction func echoEffect(sender: UIButton) {
        echoAndReverbEffects("echo")
    }
    
    @IBAction func reverbEffect(sender: UIButton) {
        echoAndReverbEffects("reverb")
    }
    
    
    func playAudioRate(rate : Float){
        stopAudioAndEngine()
        audioPlayer.rate = rate
        audioPlayer.play()
    }
    
    func playBackPitchEffectVariable(pitchVariable: Float){
        
        stopAudioAndEngine()
        
        let audioPitch = AVAudioUnitTimePitch()
        audioPitch.pitch = pitchVariable
        audioPlayerEngine.attachNode(audioPitch)
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioPlayerEngine.attachNode(audioPlayerNode)
        
        audioPlayerEngine.connect(audioPlayerNode, to: audioPitch, format: audioFile.processingFormat)
        audioPlayerEngine.connect(audioPitch, to: audioPlayerEngine.outputNode, format: audioFile.processingFormat)
        
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioPlayerEngine.prepare()
        try! audioPlayerEngine.start()
        audioPlayerNode.play()
        
    }
    
    func echoAndReverbEffects(type : String){
        
        stopAudioAndEngine()
        
        let audioPlayerNode = AVAudioPlayerNode()
        audioPlayerEngine.attachNode(audioPlayerNode)
        
        if(type == "echo"){
            let audioEcho = AVAudioUnitDelay()
            audioEcho.delayTime = NSTimeInterval(0.3)
            audioPlayerEngine.attachNode(audioEcho)
            
            audioPlayerEngine.connect(audioPlayerNode, to: audioEcho, format: audioFile.processingFormat)
            audioPlayerEngine.connect(audioEcho, to: audioPlayerEngine.outputNode, format: audioFile.processingFormat)
        }else if(type == "reverb"){
            
            let audioReverb = AVAudioUnitReverb()
            audioReverb.loadFactoryPreset(.SmallRoom)
            
            audioPlayerEngine.attachNode(audioReverb)
            audioPlayerEngine.connect(audioPlayerNode, to: audioReverb, format: audioFile.processingFormat)
            audioPlayerEngine.connect(audioReverb, to: audioPlayerEngine.outputNode, format: audioFile.processingFormat)
        }

        //schedule and play the effect
        audioPlayerNode.scheduleFile(audioFile, atTime: nil, completionHandler: nil)
        audioPlayerEngine.prepare()
        try! audioPlayerEngine.start()
        audioPlayerNode.play()
        
    }
    
    func stopAudioAndEngine(){
        audioPlayer.stop()
        audioPlayerEngine.stop()
        audioPlayerEngine.reset()
    }
    /*
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
