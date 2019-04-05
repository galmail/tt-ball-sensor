//
//  ViewController.swift
//
//  Based on the CoreMotion library created by Maxim Bilan on 21/01/2016.
//  Copyright © 2019 Gal Dubitski. All rights reserved.
//

import UIKit
import CoreMotion

class MUILabel: UILabel {
    var lastTimeChanged: NSDate?
    var defaultText: String = ""
}

class MainViewController: UIViewController {
    
    //MARK: Properties

    @IBOutlet weak var movementLabel: MUILabel!
    @IBOutlet weak var noiseFilterLabel: MUILabel!
    
	let motionManager = CMMotionManager()
	var timer: Timer!
	
    let noise = Noise()
    let noiseSnapshot = Noise()
    var filteringNoise = false
    var detectingMovement = false
    var lastMovementDetected: NSDate?
    var lastNoiseDetected: NSDate?
    
    func showLabel(_ label: MUILabel!, _ message: String?) {
        if message != nil {
            label.text = message
            label.lastTimeChanged = NSDate()
        }
        else {
            if label.lastTimeChanged == nil { return }
            // check last time changed
            let timePastSinceLastChanged = label.lastTimeChanged!.timeIntervalSinceNow
            if timePastSinceLastChanged < -1 {
                label.text = label.defaultText
            }
        }
    }
    
    override func viewDidLoad() {
		super.viewDidLoad()
        print("app has started!")
        
        view.backgroundColor = UIColor.white
        movementLabel.defaultText = "No movement"
        noiseFilterLabel.defaultText = "No noise"
		
		motionManager.startAccelerometerUpdates()
		motionManager.startGyroUpdates()
		motionManager.startMagnetometerUpdates()
		motionManager.startDeviceMotionUpdates()
		
	}
    
    @objc func detectMovement() -> Bool {
        var detectedMovement = false
        if let accelerometerData = motionManager.accelerometerData {
            if
                accelerometerData.acceleration.x < noise.accelerometerData.x.min ||
                accelerometerData.acceleration.x > noise.accelerometerData.x.max ||
                accelerometerData.acceleration.y < noise.accelerometerData.y.min ||
                accelerometerData.acceleration.y > noise.accelerometerData.y.max ||
                accelerometerData.acceleration.z < noise.accelerometerData.z.min ||
                accelerometerData.acceleration.z > noise.accelerometerData.z.max
            {
                print("Accelerometer detected!!")
                print(
                    noise.accelerometerData.x.min,
                    noise.accelerometerData.x.max,
                    accelerometerData.acceleration.x
                )
                print(
                    noise.accelerometerData.y.min,
                    noise.accelerometerData.y.max,
                    accelerometerData.acceleration.y
                )
                print(
                    noise.accelerometerData.z.min,
                    noise.accelerometerData.z.max,
                    accelerometerData.acceleration.z
                )
                self.showLabel(self.movementLabel, "Accelerometer")
                detectedMovement = true
            }
        }
        if let gyroData = motionManager.gyroData {
            if
                gyroData.rotationRate.x < noise.gyroData.x.min ||
                gyroData.rotationRate.x > noise.gyroData.x.max ||
                gyroData.rotationRate.y < noise.gyroData.y.min ||
                gyroData.rotationRate.y > noise.gyroData.y.max ||
                gyroData.rotationRate.z < noise.gyroData.z.min ||
                gyroData.rotationRate.z > noise.gyroData.z.max
            {
                print("Gyro detected!!")
                print(
                    noise.gyroData.x.min,
                    noise.gyroData.x.max,
                    gyroData.rotationRate.x
                )
                print(
                    noise.gyroData.y.min,
                    noise.gyroData.y.max,
                    gyroData.rotationRate.y
                )
                print(
                    noise.gyroData.z.min,
                    noise.gyroData.z.max,
                    gyroData.rotationRate.z
                )
                self.showLabel(self.movementLabel, "Gyro")
                detectedMovement = true
            }
        }
        if let magnetometerData = motionManager.magnetometerData {
            if
                magnetometerData.magneticField.x < noise.magnetometerData.x.min ||
                magnetometerData.magneticField.x > noise.magnetometerData.x.max {
                print("Magnetometer X axis detected!!")
                print(noise.magnetometerData.x.min)
                print(noise.magnetometerData.x.max)
                print(magnetometerData.magneticField.x)
                self.showLabel(self.movementLabel, "Magnetometer X")
                detectedMovement = true
            }
            if  magnetometerData.magneticField.y < noise.magnetometerData.y.min ||
                magnetometerData.magneticField.y > noise.magnetometerData.y.max {
                print("Magnetometer Y axis detected!!")
                print(noise.magnetometerData.y.min)
                print(noise.magnetometerData.y.max)
                print(magnetometerData.magneticField.y)
                self.showLabel(self.movementLabel, "Magnetometer Y")
                detectedMovement = true
            }
            if  magnetometerData.magneticField.z < noise.magnetometerData.z.min ||
                magnetometerData.magneticField.z > noise.magnetometerData.z.max
            {
                print("Magnetometer Z axis detected!!")
                print(noise.magnetometerData.z.min)
                print(noise.magnetometerData.z.max)
                print(magnetometerData.magneticField.z)
                self.showLabel(self.movementLabel, "Magnetometer Z")
                detectedMovement = true
            }
        }
        if !detectedMovement { self.showLabel(self.movementLabel, nil) }
        return detectedMovement
    }
    
	@objc func captureNoise() {
        
        if let accelerometerData = motionManager.accelerometerData {
            noise.captureMinMax(
                sensor: "accelerometer",
                x: accelerometerData.acceleration.x,
                y: accelerometerData.acceleration.y,
                z: accelerometerData.acceleration.z
            )
        }
        
        if let gyroData = motionManager.gyroData {
            noise.captureMinMax(
                sensor: "gyro",
                x: gyroData.rotationRate.x,
                y: gyroData.rotationRate.y,
                z: gyroData.rotationRate.z
            )
        }
        
        if let magnetometerData = motionManager.magnetometerData {
            noise.captureMinMax(
                sensor: "magnetometer",
                x: magnetometerData.magneticField.x,
                y: magnetometerData.magneticField.y,
                z: magnetometerData.magneticField.z
            )
        }
        
//        if let deviceMotion = motionManager.deviceMotion {
//            print("**** deviceMotion ****")
//            print(deviceMotion)
//        }
	}
    
    @objc func noiseFiltering() {
        if filteringNoise { return }
        filteringNoise = true
        var timesWithoutNoise = 0
        print("started noise filtering!")
        while timesWithoutNoise < 100000 {
            self.noiseSnapshot.saveNoiseMinMax(self.noise)
            self.captureNoise()
            if self.noiseSnapshot.areNewLevelsDetected(self.noise) {
                print("timesWithoutNoise", timesWithoutNoise)
                self.showLabel(self.noiseFilterLabel, "Got Noise")
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
    
    @IBAction func filterNoise(_ sender: UIButton) {
        noiseFilterLabel.text = "filtering noise..."
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainViewController.noiseFiltering), userInfo: nil, repeats: true)
        }
    }

    @IBAction func detectMotion(_ sender: UIButton) {
        movementLabel.text = "detecting..."
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(MainViewController.detectMovement), userInfo: nil, repeats: true)
    }

}
