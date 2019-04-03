//
//  ViewController.swift
//
//  Based on the CoreMotion library created by Maxim Bilan on 21/01/2016.
//  Copyright © 2019 Gal Dubitski. All rights reserved.
//

import UIKit
import CoreMotion

class MainViewController: UIViewController {
    
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
//                movementLabel.text = "Accelerometer!"
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
//                movementLabel.text = "Gyro!"
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
                detectedMovement = true
            }
            if  magnetometerData.magneticField.y < noise.magnetometerData.y.min ||
                magnetometerData.magneticField.y > noise.magnetometerData.y.max {
                print("Magnetometer Y axis detected!!")
                print(noise.magnetometerData.y.min)
                print(noise.magnetometerData.y.max)
                print(magnetometerData.magneticField.y)
                detectedMovement = true
            }
            if  magnetometerData.magneticField.z < noise.magnetometerData.z.min ||
                magnetometerData.magneticField.z > noise.magnetometerData.z.max
            {
                print("Magnetometer Z axis detected!!")
                print(noise.magnetometerData.z.min)
                print(noise.magnetometerData.z.max)
                print(magnetometerData.magneticField.z)
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

        noise.magnetometerData.x.sensitivity = 0.65
        noise.magnetometerData.y.sensitivity = 0.65
        noise.magnetometerData.z.sensitivity = 0.2

        mylabel.text = "filtering noise..."

        // start filtering noise
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            print("started noise filtering!")
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MainViewController.update), userInfo: nil, repeats: true)
        }

        // finish filtering noise
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { // Change `2.0` to the desired number of seconds.
            print("finished noise filtering!")
            self.mylabel.text = "ready!"
            self.timer.invalidate()
            self.noise.calibrateSensitivity()
        }
    }

    @IBAction func detectMotion(_ sender: UIButton) {
        mylabel.text = "detecting motion..."
        movementLabel.text = "listening"
        self.timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(MainViewController.detectMovement), userInfo: nil, repeats: true)
    }

}
