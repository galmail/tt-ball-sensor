//
//  Noise.swift
//
//  Based on the CoreMotion library created by Maxim Bilan on 21/01/2016.
//  Copyright © 2019 Gal Dubitski. All rights reserved.
//

import Foundation

let VERY_SMALL_NUMBER = -9999999.99
let VERY_BIG_NUMBER = 9999999.99

class Noise {
    var accelerometerData = Coordinates()
    var gyroData = Coordinates()
    var magnetometerData = Coordinates()
    
    @objc public func calibrateSensitivity() {
        
        print("noise.magnetometerData.y.sensitivity", magnetometerData.y.sensitivity)
        
        // calibrating accelerometer
        accelerometerData.x.min -= accelerometerData.x.sensitivity
        accelerometerData.x.max += accelerometerData.x.sensitivity
        accelerometerData.y.min -= accelerometerData.y.sensitivity
        accelerometerData.y.max += accelerometerData.y.sensitivity
        accelerometerData.z.min -= accelerometerData.z.sensitivity
        accelerometerData.z.max += accelerometerData.z.sensitivity
        
        // calibrating gyro
        gyroData.x.min -= gyroData.x.sensitivity
        gyroData.x.max += gyroData.x.sensitivity
        gyroData.y.min -= gyroData.y.sensitivity
        gyroData.y.max += gyroData.y.sensitivity
        gyroData.z.min -= gyroData.z.sensitivity
        gyroData.z.max += gyroData.z.sensitivity
        
        // calibrating magnetometer
        magnetometerData.x.min -= magnetometerData.x.sensitivity
        magnetometerData.x.max += magnetometerData.x.sensitivity
        magnetometerData.y.min -= magnetometerData.y.sensitivity
        magnetometerData.y.max += magnetometerData.y.sensitivity
        magnetometerData.z.min -= magnetometerData.z.sensitivity
        magnetometerData.z.max += magnetometerData.z.sensitivity
    }
    
    @objc public func captureMinMax(sensor: String, x: Double, y: Double, z: Double) {
        if sensor == "accelerometer" {
            self.accelerometerMinMax(x: x, y: y, z: z)
        }
        else if sensor == "gyro" {
            self.gyroMinMax(x: x, y: y, z: z)
        }
        else if sensor == "magnetometer" {
            self.magnetometerMinMax(x: x, y: y, z: z)
        }
        else {
            print("unknown sensor!")
        }
    }
    
    @objc private func accelerometerMinMax(x: Double, y: Double, z: Double) {
        // capturing x limits
        if x < accelerometerData.x.min {
            accelerometerData.x.min = x
        }
        if x > accelerometerData.x.max {
            accelerometerData.x.max = x
        }
        // capturing y limits
        if y < accelerometerData.y.min {
            accelerometerData.y.min = y
        }
        if y > accelerometerData.y.max {
            accelerometerData.y.max = y
        }
        // capturing z limits
        if z < accelerometerData.z.min {
            accelerometerData.z.min = z
        }
        if z > accelerometerData.z.max {
            accelerometerData.z.max = z
        }
    }
    
    @objc private func gyroMinMax(x: Double, y: Double, z: Double) {
        // capturing x limits
        if x < gyroData.x.min {
            gyroData.x.min = x
        }
        if x > gyroData.x.max {
            gyroData.x.max = x
        }
        // capturing y limits
        if y < gyroData.y.min {
            gyroData.y.min = y
        }
        if y > gyroData.y.max {
            gyroData.y.max = y
        }
        // capturing z limits
        if z < gyroData.z.min {
            gyroData.z.min = z
        }
        if z > gyroData.z.max {
            gyroData.z.max = z
        }
    }
    
    @objc private func magnetometerMinMax(x: Double, y: Double, z: Double) {
        // capturing x limits
        if x < magnetometerData.x.min {
            magnetometerData.x.min = x
        }
        if x > magnetometerData.x.max {
            magnetometerData.x.max = x
        }
        // capturing y limits
        if y < magnetometerData.y.min {
            magnetometerData.y.min = y
        }
        if y > magnetometerData.y.max {
            magnetometerData.y.max = y
        }
        // capturing z limits
        if z < magnetometerData.z.min {
            magnetometerData.z.min = z
        }
        if z > magnetometerData.z.max {
            magnetometerData.z.max = z
        }
    }
}

struct Coordinates {
    var x = Limits()
    var y = Limits()
    var z = Limits()
}

struct Limits {
    var min = VERY_BIG_NUMBER
    var max = VERY_SMALL_NUMBER
    var sensitivity = 0.01
}
