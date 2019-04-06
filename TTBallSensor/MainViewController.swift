//
//  ViewController.swift
//
//  Based on the CoreMotion library created by Maxim Bilan on 21/01/2016.
//  Copyright © 2019 Gal Dubitski. All rights reserved.
//

import UIKit

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
    var detectSoundTimer: Timer!

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
            let timePastSinceLastChanged = label.lastTimeChanged!.timeIntervalSinceNow
            if timePastSinceLastChanged < -1 {
                label.text = label.defaultText
            }
        }
    }
    
    var ballSoundBounced = false
    @objc func detectSound() {
        if ballSoundBounced {
            self.showLabel(self.bounceSoundLabel, "sounds like a bounce")
        }
        else {
            self.showLabel(self.bounceSoundLabel, nil)
        }
    }
    
    @objc func detectMovement() {
        let sensorDetected = bounceMotion.detectMotion()
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
//            self.detectSoundTimer.invalidate()
            stopDetectBounceBtnEnabled = false
            sender.setTitle("Detect Bounce", for: .normal)
        }
        else {
            stopDetectBounceBtnEnabled = true
            sender.setTitle("Stop Detect Bounce", for: .normal)
//            self.detectSoundTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(MainViewController.detectSound), userInfo: nil, repeats: true)
//
            
        }
        
        
        // 1. subscribe to both sound and motion detectors
        // 2. if both are true during a short timeframe (~50ms) then show 'bounce detected'
        
        
    }
    
    var stopListenForBounceBtnEnabled = false
    @IBAction func listenForBounce(_ sender: UIButton) {
        if stopListenForBounceBtnEnabled {
//            self.detectSoundTimer.invalidate()
            stopDetectMotionBtnEnabled = false
            bounceSoundLabel.text = "stopped listening for bounce"
            sender.setTitle("Listen for Bounce", for: .normal)
            bounceSound.stopListening()
        }
        else {
            stopListenForBounceBtnEnabled = true
            bounceSoundLabel.text = "listening for bounce"
            sender.setTitle("Stop Listen for Bounce", for: .normal)
//            self.detectSoundTimer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(MainViewController.detectSound), userInfo: nil, repeats: true)
            let bounceSoundDetectedCallback: BounceSoundDetectedCallback = { (bouncedOnTable) -> Void in
//                self.ballSoundBounced = bouncedOnTable
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.filterNoiseTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainViewController.noiseFiltering), userInfo: nil, repeats: true)
            }
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
