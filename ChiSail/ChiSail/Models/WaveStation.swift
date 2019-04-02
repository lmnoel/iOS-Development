//
//  WaveStation.swift
//  ChiSail
//
//  Created by Logan Noel on 3/1/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import Foundation
import MapKit

// https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
class WaveStation : MapObject {
    private var waveHeight = Float(0.0)
    private var waterTemperature = Float(0.0)
    
    var waveHeightDescription : String {
        return String(format: "Wave height: \(Formatter.shared.getFormattedWaveHeight(waveHeight))")
    }
    
    var longWaterTemperatureStatus : String {
        let waterTemperatureString =  Formatter.shared.getFormattedTemperature(waterTemperature)
        return "Water temperature: \(waterTemperatureString)"
    }
    
    var shortWaterTemperatureStatus : String {
        return Formatter.shared.getFormattedTemperature(waterTemperature)
    }
    
    init(name: String, coordinate: CLLocationCoordinate2D)
    {
        super.init(name: name, coordinate: coordinate, type: .waveStation, lastUpdated: nil)
    }
    
    func getColorForWaterConditions() -> CGColor {
        if (waterTemperature < 10) {
            return UIColor(red: 153/255, green: 255/255, blue: 255/255, alpha: 0.9).cgColor
        } else if (waveHeight > 1.5) {
            return UIColor.red.cgColor
        } else if (waveHeight > 0.7) {
            return UIColor(red: 51/255, green: 51/255, blue: 153/255, alpha: 0.9).cgColor
        } else {
            return UIColor(red: 0/255, green: 0/255, blue: 205/255, alpha: 0.9).cgColor
        }
    }
    
    func updateWithPrimitives(_ primitives : [WavesStationObserevationPrimitive]) {
        for primitive in primitives {
            guard let timestamp = Formatter.shared.getDateTimeFromString(timestamp: primitive.measurement_timestamp) else {continue}
            if (self.timestampIsNewer(timestamp: timestamp) && (primitive.beach_name == self.name)) {
                self.waveHeight = Float(primitive.wave_height) ?? 0
                self.waterTemperature = Float(primitive.water_temperature) ?? 0
                self.lastUpdated = timestamp
            }
        
    }
}
}
