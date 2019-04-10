//
//  Bounce.swift
//  TTBallSensor
//
//  Created by Gal Dubitski on 4/6/19.
//  Based on the CoreMotion library created by Maxim Bilan.
//  Copyright © 2019 Gal Dubitski. All rights reserved.
//

import Foundation
import CoreMotion

class BounceMotion {
    
    let motionManager = CMMotionManager()
    let noise = Noise(restoreDefaults: true)
    let noiseSnapshot = Noise(restoreDefaults: false)
    
    func startSensors() {
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startDeviceMotionUpdates()
    }
    
    func clearNoiseLimits() {
        noise.clearLimits()
        noise.printLimits()
    }
    
    func saveNoiseLimits() {
        noise.saveLimits()
        noise.printLimits()
    }
    
    func detectMotion() -> String? {
        if let accelerometerData = motionManager.accelerometerData {
            if accelerometerData.acceleration.x < noise.accelerometerData.x.min {
                return "accelerometer.x.min"
            }
            if accelerometerData.acceleration.x > noise.accelerometerData.x.max {
                return "accelerometer.x.max"
            }
            if accelerometerData.acceleration.y < noise.accelerometerData.y.min {
                return "accelerometer.y.min"
            }
            if accelerometerData.acceleration.y > noise.accelerometerData.y.max {
                return "accelerometer.y.max"
            }
            if accelerometerData.acceleration.z < noise.accelerometerData.z.min {
                return "accelerometer.z.min"
            }
            if accelerometerData.acceleration.z > noise.accelerometerData.z.max {
                return "accelerometer.z.max"
            }
        }
        if let gyroData = motionManager.gyroData {
            if gyroData.rotationRate.x < noise.gyroData.x.min {
                return "gyro.x.min"
            }
            if gyroData.rotationRate.x > noise.gyroData.x.max {
                return "gyro.x.max"
            }
            if gyroData.rotationRate.y < noise.gyroData.y.min {
                return "gyro.y.min"
            }
            if gyroData.rotationRate.y > noise.gyroData.y.max {
                return "gyro.y.max"
            }
            if gyroData.rotationRate.z < noise.gyroData.z.min {
                return "gyro.z.min"
            }
            if gyroData.rotationRate.z > noise.gyroData.z.max {
                return "gyro.z.max"
            }
        }
        if let magnetometerData = motionManager.magnetometerData {
            if magnetometerData.magneticField.x < noise.magnetometerData.x.min {
                return "magnetometer.x.min"
            }
            if magnetometerData.magneticField.x > noise.magnetometerData.x.max {
                return "magnetometer.x.max"
            }
            if magnetometerData.magneticField.y < noise.magnetometerData.y.min {
                return "magnetometer.y.min"
            }
            if magnetometerData.magneticField.y > noise.magnetometerData.y.max {
                return "magnetometer.y.max"
            }
            if magnetometerData.magneticField.z < noise.magnetometerData.z.min {
                return "magnetometer.z.min"
            }
            if magnetometerData.magneticField.z > noise.magnetometerData.z.max {
                return "magnetometer.z.max"
            }
        }
        return nil
    }
    
    func captureNoise() -> Bool {
        noiseSnapshot.saveNoiseMinMax(noise)
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
        return noiseSnapshot.areNewLevelsDetected(noise)
    }
    
    
    
    
    
}


