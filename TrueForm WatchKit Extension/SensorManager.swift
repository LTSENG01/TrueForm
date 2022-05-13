//
//  SensorManager.swift
//  TrueForm WatchKit Extension
//
//  Created by Larry Tseng on 4/22/22.
//

import Foundation
import CoreMotion

@MainActor
class SensorManager: ObservableObject {
    @Published var isRecording: Bool = false {
        willSet(newValue) {
            print(newValue)
            if newValue {
                start()
            } else {
                stop()
            }
        }
    }
    
    var accelData: Dictionary<TimeInterval, CMAcceleration> = [TimeInterval: CMAcceleration]()
    var gyroData: Dictionary<TimeInterval, CMRotationRate> = [TimeInterval: CMRotationRate]()
    var attitudeData: Dictionary<TimeInterval, CMAttitude> = [TimeInterval: CMAttitude]()
    
    let sensorManager = CMMotionManager()
    let accelQueue = OperationQueue()
    let gyroQueue = OperationQueue()
    let fileSender = FileSender()
    
    private func start() {
        accelData.removeAll()
        gyroData.removeAll()
        attitudeData.removeAll()
        
        if sensorManager.isAccelerometerAvailable {
            print("Accelerometer is available")
            sensorManager.accelerometerUpdateInterval = 1.0 / 30.0  // 30 Hz
            
            sensorManager.startAccelerometerUpdates(to: accelQueue) { data, error in
                if let data = data {
                    self.accelData[data.timestamp] = data.acceleration
                }
            }
        }
        
        if sensorManager.isDeviceMotionAvailable {
            print("Device Motion is available")
            sensorManager.deviceMotionUpdateInterval = 1.0 / 30.0  // 30 Hz
        
            sensorManager.startDeviceMotionUpdates(to: gyroQueue) { data, error in
                if let data = data {
                    self.gyroData[data.timestamp] = data.rotationRate
                    self.attitudeData[data.timestamp] = data.attitude
                }
            }

        }
    }
    
    private func stop() {
        sensorManager.stopAccelerometerUpdates()
        sensorManager.stopDeviceMotionUpdates()
        accelQueue.cancelAllOperations()
        gyroQueue.cancelAllOperations()
        
        // Process Attitude data using the first frame as reference
        let attitudeReference: CMAttitude? = attitudeData.values.first
        for (timestamp, attitude) in attitudeData {
            if let attitudeReference = attitudeReference {
                let correctedAttitude = attitude
                correctedAttitude.multiply(byInverseOf: attitudeReference)
                attitudeData[timestamp] = correctedAttitude
            }
        }
        
    
        var files: [URL] = []
        
        // Create folder URL
        var folderURL: URL?
        
        do {
            folderURL = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true)
        } catch {
            
        }
        
        for (i, sensorDataset) in [accelData, attitudeData, gyroData].enumerated() {
            var fileURL: URL?
            
            // Create timestamp
            let date = Date()
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd_HH-mm-ss"
            let timestamp = format.string(from: date)
            
            // What kind of data?
            var sensorType: String
            switch i {
            case 0:
                sensorType = "Accel"
            case 1:
                sensorType = "Attitude"
            case 2:
                sensorType = "Gyro"
            default:
                sensorType = "Unknown"
            }
            
            fileURL = folderURL?.appendingPathComponent("\(sensorType)-\(timestamp).csv")
            FileManager.default.createFile(atPath: fileURL!.path, contents: nil)
            
            // Construct data
            var csvString = ""
            
            if sensorDataset is Dictionary<TimeInterval, CMAcceleration> {
                csvString += "\("Timestamp"),\("X"),\("Y"),\("Z")\n"
                for entry in (sensorDataset as! Dictionary<TimeInterval, CMAcceleration>) {
                    csvString += "\(entry.key.description),\(entry.value.x.description),\(entry.value.y.description),\(entry.value.z.description)\n"
                }
            } else if sensorDataset is Dictionary<TimeInterval, CMAttitude> {
                csvString += "\("Timestamp"),\("Pitch"),\("Roll"),\("Yaw")\n"
                for entry in (sensorDataset as! Dictionary<TimeInterval, CMAttitude>) {
                    csvString += "\(entry.key.description),\(entry.value.pitch.description),\(entry.value.roll.description),\(entry.value.yaw.description)\n"
                }
            } else if sensorDataset is Dictionary<TimeInterval, CMRotationRate> {
                csvString += "\("Timestamp"),\("X"),\("Y"),\("Z")\n"
                for entry in (sensorDataset as! Dictionary<TimeInterval, CMRotationRate>) {
                    csvString += "\(entry.key.description),\(entry.value.x.description),\(entry.value.y.description),\(entry.value.z.description)\n"
                }
            }
            
            // Save data to file
            do {
                if let fileURL = fileURL {
                    try csvString.write(toFile: fileURL.path, atomically: true, encoding: .utf8)
                    files.append(fileURL)
                } else {
                    throw URLError(.badURL)
                }
                
                print("Sensor data saved successfully.")
            } catch {
                print("ERROR occured while saving the sensor data! \(error)")
            }
        
        }
        
        for fileURL in files {
            // send to iPhone
            do {
                try fileSender.sendFile(file: fileURL)
            } catch {
                print("ERROR occured while sending the file! \(error)")
            }

        }
    }
}
