//
//  ViewController.swift
//
//  Based on the CoreMotion library created by Maxim Bilan on 21/01/2016.
//  Copyright © 2019 Gal Dubitski. All rights reserved.
//

import UIKit
import Foundation

class MUILabel: UILabel {
    var lastTimeChanged: NSDate?
    var defaultText: String = ""
}

class MainViewController: UIViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var noiseFilterLabel: MUILabel!
    @IBOutlet weak var detectMotionLabel: MUILabel!
    @IBOutlet weak var bounceSoundLabel: MUILabel!
    
	var filterNoiseTimer: Timer!
    var detectMotionTimer: Timer!
    
    let detectMotionQueue = DispatchQueue(label: "detect-motion-queue")
    let detectSoundQueue = DispatchQueue(label: "detect-sound-queue")

    let bounceMotion = BounceMotion()
    let bounceSound = BounceSound()

    override func viewDidLoad() {
		super.viewDidLoad()
        print("app has started!")
        view.backgroundColor = UIColor.white
        detectMotionLabel.defaultText = "No movement"
        noiseFilterLabel.defaultText = "No noise"
        bounceSoundLabel.defaultText = "No sound"
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
    
    func detectBounce(_ sensor: String, _ bounced: Bool) {
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
    @objc func noiseFiltering() {
        if filteringNoise { return }
        filteringNoise = true
        var timesWithoutNoise = 0
        print("started noise filtering!")
        while timesWithoutNoise < 100000 {
            let noiseDetected = bounceMotion.captureNoise()
            if noiseDetected {
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
    }
    
    //MARK: Actions
    var stopDetectBounceBtnEnabled = false
    @IBAction func detectBounce(_ sender: UIButton) {
        if stopDetectBounceBtnEnabled {
            stopDetectBounceBtnEnabled = false
            sender.setTitle("Detect Bounce", for: .normal)
            showBounceOnScreen = false
        }
        else {
            stopDetectBounceBtnEnabled = true
            sender.setTitle("Stop Detect Bounce", for: .normal)
            showBounceOnScreen = true
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
                self.detectSoundQueue.async {
                    self.detectBounce("sound", bouncedOnTable)
                }
                if bouncedOnTable {
                    self.showLabel(self.bounceSoundLabel, "sounds like a bounce")
                } else {
                    self.showLabel(self.bounceSoundLabel, nil)
                }
            }
            self.bounceSound.startListening(bounceSoundDetectedCallback)
        }
    }
    
    var stopFilterNoiseBtnEnabled = false
    @IBAction func filterNoise(_ sender: UIButton) {
        if stopFilterNoiseBtnEnabled {
            self.filterNoiseTimer.invalidate()
            noiseFilterLabel.text = "noise filtering stopped"
            sender.setTitle("Filter Noise", for: .normal)
            stopFilterNoiseBtnEnabled = false
        }
        else {
            noiseFilterLabel.text = "filtering noise..."
            sender.setTitle("Stop Filter Noise", for: .normal)
            stopFilterNoiseBtnEnabled = true
            self.filterNoiseTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainViewController.noiseFiltering), userInfo: nil, repeats: true)
        }
    }

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

}
