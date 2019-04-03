//
//  ViewController.swift
//
//  Based on the CoreMotion library created by Maxim Bilan on 21/01/2016.
//  Copyright © 2019 Gal Dubitski. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var mylabel: UILabel!
    @IBOutlet weak var movementLabel: UILabel!

	let motionManager = CMMotionManager()
	var timer: Timer!
	
    var noise = Noise()
    var detectingMovement = false
    
    override func viewDidLoad() {
		super.viewDidLoad()
        print("app has started!")
        
        view.backgroundColor = UIColor.white
		
		motionManager.startAccelerometerUpdates()
		motionManager.startGyroUpdates()
		motionManager.startMagnetometerUpdates()
		motionManager.startDeviceMotionUpdates()
        
        // 1. Create Button that when press, it will start recording the "noise" from the motion to remove false positives. It should do it for a period of 10 seconds.
        // 2. ....
		
	}
    
    func detectMovement() -> Bool {
        print("started detecting movement!")
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
                movementLabel.text = "Accelerometer!"
                detectedMovement = true
            }
        }
        if let gyroData = motionManager.gyroData {
            if
                gyroData.rotationRate.x < noise.accelerometerData.x.min ||
                gyroData.rotationRate.x > noise.accelerometerData.x.max ||
                gyroData.rotationRate.y < noise.accelerometerData.y.min ||
                gyroData.rotationRate.y > noise.accelerometerData.y.max ||
                gyroData.rotationRate.z < noise.accelerometerData.z.min ||
                gyroData.rotationRate.z > noise.accelerometerData.z.max
            {
                movementLabel.text = "Gyro!"
                detectedMovement = true
            }
        }
        if let magnetometerData = motionManager.magnetometerData {
            if
                magnetometerData.magneticField.x < noise.magnetometerData.x.min ||
                magnetometerData.magneticField.x > noise.magnetometerData.x.max ||
                magnetometerData.magneticField.y < noise.magnetometerData.y.min ||
                magnetometerData.magneticField.y > noise.magnetometerData.y.max ||
                magnetometerData.magneticField.z < noise.magnetometerData.z.min ||
                magnetometerData.magneticField.z > noise.magnetometerData.z.max
            {
                movementLabel.text = "Magnetometer!"
                detectedMovement = true
            }
        }
        return detectedMovement
    }
    
	@objc func update() {
        
        if let accelerometerData = motionManager.accelerometerData {
            print("**** accelerometerData ****")
//            print(accelerometerData)
            noise.captureMinMax(
                sensor: "accelerometer",
                x: accelerometerData.acceleration.x,
                y: accelerometerData.acceleration.y,
                z: accelerometerData.acceleration.z
            )
            print("minX: ")
            print(noise.accelerometerData.x.min)
            print("maxX: ")
            print(noise.accelerometerData.x.max)
        }
        
        if let gyroData = motionManager.gyroData {
            print("**** gyroData ****")
//            print(gyroData)
            noise.captureMinMax(
                sensor: "gyro",
                x: gyroData.rotationRate.x,
                y: gyroData.rotationRate.y,
                z: gyroData.rotationRate.z
            )
            print("minX: ")
            print(noise.gyroData.x.min)
            print("maxX: ")
            print(noise.gyroData.x.max)
        }
        
        if let magnetometerData = motionManager.magnetometerData {
            print("**** magnetometerData ****")
//            print(magnetometerData)
            noise.captureMinMax(
                sensor: "magnetometer",
                x: magnetometerData.magneticField.x,
                y: magnetometerData.magneticField.y,
                z: magnetometerData.magneticField.z
            )
            print("minX: ")
            print(noise.magnetometerData.x.min)
            print("maxX: ")
            print(noise.magnetometerData.x.max)
        }
        
//        if let deviceMotion = motionManager.deviceMotion {
//            print("**** deviceMotion ****")
//            print(deviceMotion)
//        }
	}
    
    //MARK: Actions
    @IBAction func filterNoise(_ sender: UIButton) {
        mylabel.text = "filtering noise..."

        // start filtering noise
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("started noise filtering!")
            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        }

        // finish filtering noise
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { // Change `2.0` to the desired number of seconds.
            self.mylabel.text = "ready!"
            print("finished noise filtering!")
            self.timer.invalidate()
            print("minX: ")
            print(self.noise.accelerometerData.x.min)
            print("maxX: ")
            print(self.noise.accelerometerData.x.max)
        }
    }
    
    @IBAction func detectMotion(_ sender: UIButton) {
        mylabel.text = "detecting motion..."
        movementLabel.text = "listening"
        while true {
            if self.detectMovement() {
                mylabel.text = "motion detected!"
                break
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.detectMotion(sender)
        }
    }

}
