//
//  Noise.swift
//
//  Copyright © 2019 Gal Dubitski. All rights reserved.
//

import Foundation

let VERY_SMALL_NUMBER = -9999999.99
let VERY_BIG_NUMBER = 9999999.99

class Noise {
    var accelerometerData = Coordinates()
    var gyroData = Coordinates()
    var magnetometerData = Coordinates()
    
    func saveNoiseMinMax(_ noise: Noise) {
        // saving accelerometer min/max values
        accelerometerData.x.min = noise.accelerometerData.x.min
        accelerometerData.x.max = noise.accelerometerData.x.max
        accelerometerData.y.min = noise.accelerometerData.y.min
        accelerometerData.y.max = noise.accelerometerData.y.max
        accelerometerData.z.min = noise.accelerometerData.z.min
        accelerometerData.z.max = noise.accelerometerData.z.max
        // saving gyro min/max values
        gyroData.x.min = noise.gyroData.x.min
        gyroData.x.max = noise.gyroData.x.max
        gyroData.y.min = noise.gyroData.y.min
        gyroData.y.max = noise.gyroData.y.max
        gyroData.z.min = noise.gyroData.z.min
        gyroData.z.max = noise.gyroData.z.max
        // saving magnetometer min/max values
        magnetometerData.x.min = noise.magnetometerData.x.min
        magnetometerData.x.max = noise.magnetometerData.x.max
        magnetometerData.y.min = noise.magnetometerData.y.min
        magnetometerData.y.max = noise.magnetometerData.y.max
        magnetometerData.z.min = noise.magnetometerData.z.min
        magnetometerData.z.max = noise.magnetometerData.z.max
    }
    
    func areNewLevelsDetected(_ noise: Noise) -> Bool {
        let accelerometerMinMaxCaptured =
            noise.accelerometerData.x.min < accelerometerData.x.min ||
            noise.accelerometerData.x.max > accelerometerData.x.max ||
            noise.accelerometerData.y.min < accelerometerData.y.min ||
            noise.accelerometerData.y.max > accelerometerData.y.max ||
            noise.accelerometerData.z.min < accelerometerData.z.min ||
            noise.accelerometerData.z.max > accelerometerData.z.max
        
        let gyroMinMaxCaptured =
            noise.gyroData.x.min < gyroData.x.min ||
                noise.gyroData.x.max > gyroData.x.max ||
                noise.gyroData.y.min < gyroData.y.min ||
                noise.gyroData.y.max > gyroData.y.max ||
                noise.gyroData.z.min < gyroData.z.min ||
                noise.gyroData.z.max > gyroData.z.max
        
        let magnetometerMinMaxCaptured =
            noise.magnetometerData.x.min < magnetometerData.x.min ||
                noise.magnetometerData.x.max > magnetometerData.x.max ||
                noise.magnetometerData.y.min < magnetometerData.y.min ||
                noise.magnetometerData.y.max > magnetometerData.y.max ||
                noise.magnetometerData.z.min < magnetometerData.z.min ||
                noise.magnetometerData.z.max > magnetometerData.z.max
        
        return accelerometerMinMaxCaptured || gyroMinMaxCaptured || magnetometerMinMaxCaptured
    }
    
    public func captureMinMax(sensor: String, x: Double, y: Double, z: Double) {
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
    
    private func accelerometerMinMax(x: Double, y: Double, z: Double) {
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
    
    private func gyroMinMax(x: Double, y: Double, z: Double) {
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
    
    private func magnetometerMinMax(x: Double, y: Double, z: Double) {
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
}
