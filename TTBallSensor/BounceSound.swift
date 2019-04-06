//
//  BounceSound.swift
//  TTBallSensor
//
//  Created by Gal Dubitski on 4/6/19.
//  Based on the TempiHarness library created by John Scalo.
//  Copyright © 2019 Gal Dubitski. All rights reserved.
//

import Foundation
import AVFoundation

typealias BounceSoundDetectedCallback = (
    _ bouncedOnTable: Bool
) -> Void

class BounceSound {
    
    var ballBounced = false
    var maxMagnitudeBounce = Float(0)
    var freq = Float(0)
    var band = 0
    //    var iterations = 0
    
    let lowestFreq = Float(920)
    let highestFreq = Float(1300)
    let minBand = 14
    let maxBand = 14
    let minMagnitude = Float(2)
    
    var records = 0
    var audioInput: TempiAudioInput!
    
    func startListening(_ callback: @escaping BounceSoundDetectedCallback) {
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.gotSomeAudio(callback, timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }
        
        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1)
        audioInput.startRecording()
    }
    
    func stopListening() {
        audioInput.stopRecording()
    }
    
    func gotSomeAudio(_ callback: @escaping BounceSoundDetectedCallback, timeStamp: Double, numberOfFrames: Int, samples: [Float]) {
        var ballSoundBounced = false
        let fft = TempiFFT(withSize: numberOfFrames, sampleRate: 44100.0)
        fft.windowType = TempiFFTWindowType.hanning
        fft.fftForward(samples)
        
        //        print("processing audio signal");
        // Map FFT data to logical bands. This gives 4 bands per octave across 7 octaves = 28 bands.
        fft.calculateLogarithmicBands(minFrequency: 100, maxFrequency: 11025, bandsPerOctave: 4)
        
        //        iterations += 1
        //        if (iterations % 500 == 0) {
        //            print("resetting maxMagnitude...");
        //            // maxMagnitude = 0;
        //        }
        
        // Process some data
        for i in 0..<fft.numberOfBands {
            let f = fft.frequencyAtBand(i)
            let m = fft.magnitudeAtBand(i)
            
            if (
                f >= lowestFreq &&
                    f <= highestFreq &&
                    i >= minBand &&
                    i <= maxBand
                ) {
                if (m >= minMagnitude) {
                    // start recording
                    records += 1
                    print("magnitude: ", Int(m));
                    if (m > maxMagnitudeBounce) {
                        maxMagnitudeBounce = m
                        records = 1
                    }
                }
                else {
                    if (records >= 4 && records < 8) {
                        print("\n")
                        print("ball bounced on the table! maxMagnitude: ", Int(maxMagnitudeBounce))
                        print("total bounces since maxMagnitudeBounce: ", records)
                        print("\n")
                        ballSoundBounced = true
                    }
                    else if (records >= 8) {
                        print("\n")
                        print("ball bounced on the floor! maxMagnitude: ", Int(maxMagnitudeBounce))
                        print("total bounces since maxMagnitudeBounce: ", records)
                        print("\n")
                    }
                    if (records > 0) {
                        print("\n")
                        records = 0
                        maxMagnitudeBounce = 0
                    }
                }
            }
            
            // Bounce on floor (8 to 10 records)
            // Bounce on table (6 to 8 records) with maxMagnitude > 1100
            
            
            //////////// Ball bounces on the bat ////////////
            //            magnitude - frequency - band  283.15903 1076.6602 14
            //            magnitude - frequency - band  94.33679 1248.9258 15
            
            
            
            //            if (m > maxMagnitude){
            //                maxMagnitude = m;
            //                freq = f;
            //                band = i;
            //                print("magnitude - frequency - band ", m, f, i);
            //            }
            // print("frequencyAtBand ", i, f);
            // print("magnitudeAtBand ", i, m);
        }
        
        
        // Interpoloate the FFT data so there's one band per pixel.
//        let screenWidth = UIScreen.main.bounds.size.width * UIScreen.main.scale
//        fft.calculateLinearBands(minFrequency: 0, maxFrequency: fft.nyquistFrequency, numberOfBands: Int(screenWidth))
//
//        tempi_dispatch_main { () -> () in
//            self.spectralView.fft = fft
//            self.spectralView.setNeedsDisplay()
//        }
        self.ballBounced = ballSoundBounced
        callback(ballSoundBounced)
    }
    
    
}
