//
//  RunAnalyzer.swift
//  TrueForm
//
//  Created by Larry Tseng on 5/10/22.
//

import Foundation

class RunAnalyzer {
    
    func analyzeRun(files: [URL]) -> RunAnalysis {
        
        // TODO: change
        return RunAnalysis(swings: [])
    }
    
    private func parseAndSortCSV(file: URL) -> Dictionary<TimeInterval, Double> {
        // parse CSV
        // sort sensorData
        
        // TODO: change
        return [:]
    }
    
    // time synchronization
    private func findSwingIntervals(gyroZ: Dictionary<TimeInterval, Double>) {
        
    }
    
    // swing divider
    // swing analysis
    
}

struct RunAnalysis {
    var swings: [SwingAnalysis]
}

struct SwingAnalysis {
    var performance: SwingRating
    var duration: TimeInterval
}

enum SwingRating {
    case GOOD, OK, BAD
}
