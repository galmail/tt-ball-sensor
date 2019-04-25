//
//  ViewController.swift
//
//  Based on the CoreMotion library created by Maxim Bilan on 21/01/2016.
//  Copyright © 2019 Gal Dubitski. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class MUILabel: UILabel {
    var lastTimeChanged: NSDate?
    var defaultText: String = ""
}

class MainViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var filterNoiseButton: UIButton!
    @IBOutlet weak var noiseFilterLabel: MUILabel!
    @IBOutlet weak var detectMotionLabel: MUILabel!
    @IBOutlet weak var bounceSoundLabel: MUILabel!
    @IBOutlet weak var numberOfBouncesLabel: MUILabel!
    
	var filterNoiseTimer: Timer!
    var detectMotionTimer: Timer!
    
    let detectMotionQueue = DispatchQueue(label: "detect-motion-queue")
    let detectSoundQueue = DispatchQueue(label: "detect-sound-queue")

    let bounceMotion = BounceMotion()
    let bounceSound = BounceSound()
    
    var player: AVAudioPlayer?

    override func viewDidLoad() {
		super.viewDidLoad()
        print("app has started!")
        view.backgroundColor = UIColor.white
        detectMotionLabel.defaultText = "No movement"
        noiseFilterLabel.defaultText = "No noise"
        bounceSoundLabel.defaultText = "No sound"
        numberOfBouncesLabel.defaultText = "No bounces"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(filterNoiseNormalTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        filterNoiseButton.addGestureRecognizer(tapGesture)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(filterNoiseLongTap(_:)))
        filterNoiseButton.addGestureRecognizer(longGesture)
        
        bounceMotion.startSensors()
	}
    
    override func didReceiveMemoryWarning() {
        NSLog("*** Memory!")
        super.didReceiveMemoryWarning()
    }
    
    func blinkScreen(_ on: Bool) {
        DispatchQueue.main.async {
            self._blinkScreen(on)
        }
    }
    
    // will change screen color for 1sec
    var lastTimeScreenBlinked: NSDate?
    func _blinkScreen(_ on: Bool) {
        if on {
            view.backgroundColor = UIColor.green
            lastTimeScreenBlinked = NSDate()
        }
        else {
            if lastTimeScreenBlinked == nil { return }
            let timeSinceScreenBlinked = abs(lastTimeScreenBlinked!.timeIntervalSinceNow)
            if timeSinceScreenBlinked > 1 {
                view.backgroundColor = UIColor.white
            }
        }
    }
    
    func showLabel(_ label: MUILabel!, _ message: String?) {
        DispatchQueue.main.async {
            self._showLabel(label, message)
        }
    }
    
    func _showLabel(_ label: MUILabel!, _ message: String?) {
        if message != nil {
            label.text = message
            label.lastTimeChanged = NSDate()
        }
        else {
            if label.lastTimeChanged == nil { return }
            let timePastSinceLastChanged = abs(label.lastTimeChanged!.timeIntervalSinceNow)
            if timePastSinceLastChanged > 1 {
                label.text = label.defaultText
            }
        }
    }
    
    // 1. subscribe to both sound and motion detectors
    // 2. if both are true during a short timeframe (~50ms) then show 'bounce detected'
    var showBounceOnScreen = false
    let BOUNCE_TIMEFRAME = 0.05 // 50ms
    var lastTimeMotionDetected: NSDate?
    var lastTimeSoundDetected: NSDate?
    var lastTimeBounceDetected: NSDate?
    var numberOfBouncesDetected = 0
    func detectBounce(_ sensor: String, _ bounced: Bool) {
        if lastTimeBounceDetected != nil {
            let lastTimeBounceDetectedInterval = abs(lastTimeBounceDetected!.timeIntervalSinceNow)
            if lastTimeBounceDetectedInterval < BOUNCE_TIMEFRAME {
                // bounce already detected during this timeframe, therefore we ignore...
                return
            }
        }
        if sensor == "motion" && bounced {
            lastTimeMotionDetected = NSDate()
        }
        if sensor == "sound" && bounced {
            lastTimeSoundDetected = NSDate()
        }
        if lastTimeMotionDetected == nil || lastTimeSoundDetected == nil { return }
        // now lets check
        let lastTimeMotionDetectedInterval = abs(lastTimeMotionDetected!.timeIntervalSinceNow)
        let lastTimeSoundDetectedInterval = abs(lastTimeSoundDetected!.timeIntervalSinceNow)
        if lastTimeMotionDetectedInterval < BOUNCE_TIMEFRAME && lastTimeSoundDetectedInterval < BOUNCE_TIMEFRAME {
            lastTimeBounceDetected = NSDate()
            numberOfBouncesDetected += 1
            if showBounceOnScreen {
                self.blinkScreen(true)
            }
        }
        else {
            if showBounceOnScreen {
                self.blinkScreen(false)
            }
        }
    }
    
    @objc func detectMovement() {
        let sensorDetected = bounceMotion.detectMotion()
        detectMotionQueue.async {
            self.detectBounce("motion", sensorDetected != nil)
        }
        self.showLabel(self.detectMotionLabel, sensorDetected)
    }
    
    var filteringNoise = false
    var timesWithoutFilteringNoise = 0
    @objc func noiseFiltering() -> Bool {
        var noiseWasDetected = false
        if filteringNoise { return true } // still filtering so we haven't finished
        filteringNoise = true
        var timesWithoutNoise = 0
        print("started noise filtering!")
        while timesWithoutNoise < 100000 {
            let noiseDetected = bounceMotion.captureNoise()
            if noiseDetected {
                noiseWasDetected = true
                print("timesWithoutNoise", timesWithoutNoise)
                self.showLabel(self.noiseFilterLabel, "More noise detected")
                timesWithoutNoise = 0
            }
            else {
                timesWithoutNoise += 1
            }
        }
        filteringNoise = false
        self.showLabel(self.noiseFilterLabel, nil)
        print("finished noise filtering!")
        if !noiseWasDetected {
            timesWithoutFilteringNoise += 1
            if timesWithoutFilteringNoise == 20 {
                // we are done, play sound and stop filtering!
                self.filterNoiseTimer.invalidate()
                noiseFilterLabel.text = "noise filtering stopped"
                filterNoiseButton.setTitle("Filter Noise", for: .normal)
                stopFilterNoiseBtnEnabled = false
                bounceMotion.saveNoiseLimits()
                playSound()
            }
        } else {
            timesWithoutFilteringNoise = 0
        }
        return noiseWasDetected
    }
    
    //MARK: Actions
    var stopDetectBounceBtnEnabled = false
    @IBAction func detectBounce(_ sender: UIButton) {
        if stopDetectBounceBtnEnabled {
            stopDetectBounceBtnEnabled = false
            sender.setTitle("Detect Bounce", for: .normal)
            showBounceOnScreen = false
            self.showLabel(self.numberOfBouncesLabel, "\(self.numberOfBouncesDetected) Bounces")
        }
        else {
            stopDetectBounceBtnEnabled = true
            sender.setTitle("Stop Detect Bounce", for: .normal)
            showBounceOnScreen = true
            numberOfBouncesDetected = 0
            self.showLabel(self.numberOfBouncesLabel, "Counting Bounces...")
        }
    }
    
    var stopListenForBounceBtnEnabled = false
    @IBAction func listenForBounce(_ sender: UIButton) {
        if stopListenForBounceBtnEnabled {
            stopDetectMotionBtnEnabled = false
            bounceSoundLabel.text = "stopped listening for bounce"
            sender.setTitle("Listen for Bounce", for: .normal)
            bounceSound.stopListening()
        }
        else {
            stopListenForBounceBtnEnabled = true
            bounceSoundLabel.text = "listening for bounce"
            sender.setTitle("Stop Listen for Bounce", for: .normal)
            let bounceSoundDetectedCallback: BounceSoundDetectedCallback = { (bouncedOnTable) -> Void in
                if bouncedOnTable {
                    self.showLabel(self.bounceSoundLabel, "sounds like a bounce")
                    self.detectSoundQueue.async {
                        self.detectBounce("sound", bouncedOnTable)
                    }
                } else {
                    self.showLabel(self.bounceSoundLabel, nil)
                }
            }
            self.bounceSound.startListening(bounceSoundDetectedCallback)
        }
    }
    
    var stopFilterNoiseBtnEnabled = false
    @objc func filterNoiseNormalTap(_ sender: UIGestureRecognizer){
//        print("Filter Noise Normal tap")
        if stopFilterNoiseBtnEnabled {
            self.filterNoiseTimer.invalidate()
            noiseFilterLabel.text = "noise filtering stopped"
            filterNoiseButton.setTitle("Filter Noise", for: .normal)
            stopFilterNoiseBtnEnabled = false
            bounceMotion.saveNoiseLimits()
        }
        else {
            noiseFilterLabel.text = "filtering noise..."
            filterNoiseButton.setTitle("Stop Filter Noise", for: .normal)
            stopFilterNoiseBtnEnabled = true
            self.filterNoiseTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainViewController.noiseFiltering), userInfo: nil, repeats: true)
        }
    }
    
    @objc func filterNoiseLongTap(_ sender: UIGestureRecognizer){
//        print("Filter Noise Long tap")
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            // clearing default noise values
            bounceMotion.clearNoiseLimits()
        }
        else if sender.state == .began {
//            print("UIGestureRecognizerStateBegan.")
        }
    }
    
//    var stopFilterNoiseBtnEnabled = false
//    @IBAction func filterNoise(_ sender: UIButton) {
//        if stopFilterNoiseBtnEnabled {
//            self.filterNoiseTimer.invalidate()
//            noiseFilterLabel.text = "noise filtering stopped"
//            sender.setTitle("Filter Noise", for: .normal)
//            stopFilterNoiseBtnEnabled = false
//            bounceMotion.saveNoiseLimits()
//        }
//        else {
//            noiseFilterLabel.text = "filtering noise..."
//            sender.setTitle("Stop Filter Noise", for: .normal)
//            stopFilterNoiseBtnEnabled = true
//            self.filterNoiseTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainViewController.noiseFiltering), userInfo: nil, repeats: true)
//        }
//    }

    var stopDetectMotionBtnEnabled = false
    @IBAction func detectMotion(_ sender: UIButton) {
        if stopDetectMotionBtnEnabled {
            self.detectMotionTimer.invalidate()
            detectMotionLabel.text = "motion detect stopped"
            sender.setTitle("Detect Motion", for: .normal)
            stopDetectMotionBtnEnabled = false
        }
        else {
            detectMotionLabel.text = "detecting motion..."
            sender.setTitle("Stop Detect Motion", for: .normal)
            stopDetectMotionBtnEnabled = true
            self.detectMotionTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(MainViewController.detectMovement), userInfo: nil, repeats: true)
        }
    }
    
    
    
    func playSound() {
        print("playSound()")
        guard let url = Bundle.main.url(forResource: "dora_success_tone", withExtension: "mp3") else {
            print("cant find dora_success_tone.mp3")
            return
        }
        
        do {
            if #available(iOS 10, *) {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            } else {
                try AVAudioSession.sharedInstance().setCategory(.playback)
            }
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }

}
