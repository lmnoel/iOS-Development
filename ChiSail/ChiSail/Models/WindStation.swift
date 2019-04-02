//
//  WindStation.swift
//  ChiSail
//
//  Created by Logan Noel on 3/1/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import Foundation
import MapKit

// https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
class WindStation : MapObject {
    var windSpeed = Float(0.0)
    var windDirection = 0
    private var airTemperature = Float(0.0)
    private var windGust = Float(0.0)
    private var intervalRain = Float(0)
    
    var longDescription : String {
        let windDirectionString = Formatter.shared.getFormattedWindDirection(windDirection)
        let windSpeedString = Formatter.shared.getFormattedWindSpeed(windSpeed)
        let temperatureString = Formatter.shared.getFormattedTemperature(airTemperature)
        return "\(windSpeedString) | \(windDirectionString) | \(temperatureString)"
    }
    
    var fullWindDescription : String {
        let windDirectionString = Formatter.shared.getFormattedWindDirection(windDirection)
        let windSpeedString = Formatter.shared.getFormattedWindSpeed(windSpeed)
        return "Wind: \(windSpeedString) | \(windDirectionString)"
    }
    
    var windSpeedDescription : String {
        let windSpeedString = Formatter.shared.getFormattedWindSpeed(windSpeed)
        return "Sustained: \(windSpeedString)"
    }
    
    var windGustDescription : String {
        let windGustString = Formatter.shared.getFormattedWindSpeed(windGust)
        return "Gusting: \(windGustString)"
    }
    
    var windDirectionDescription : String {
        let windDirectionString = Formatter.shared.getFormattedWindDirection(windDirection)
        return "Heading: \(windDirectionString) (\(windDirection)°)"
    }
    
    var airTemperatureDescription : String {
        let temperatureString = Formatter.shared.getFormattedTemperature(airTemperature)
        return "Air Temperature: \(temperatureString)"
    }
    
    var precipitationDescription : String {
        let precipitationString = Formatter.shared.getFormattedPrecipitation(intervalRain)
        return "Precipitation: \(precipitationString)"
    }
    
    init(name: String, coordinate: CLLocationCoordinate2D)
    {
        super.init(name: name, coordinate: coordinate, type: .windStation, lastUpdated: nil)
    }
    
    func getColorValueForWindIntensity() -> CGColor {
        if (windSpeed < 5.0 / 1.94384) {
            return UIColor(red: 124/255, green: 252/255, blue: 0/255, alpha: 0.9).cgColor
        } else if (windSpeed < 12.0 / 1.94384) {
            return UIColor(red: 50/255, green: 205/255, blue: 50/255, alpha: 0.9).cgColor
        } else if (windSpeed < 18.0 / 1.94384) {
            return UIColor(red: 34/255, green: 139/255, blue: 34/255, alpha: 0.9).cgColor
        } else {
            return UIColor.red.cgColor
        }
    }
    
    func updateWithPrimitives(_ primitives : [WindStationObservationPrimitive]) {
        for primitive in primitives {
            guard let timestamp = Formatter.shared.getDateTimeFromString(timestamp: primitive.measurement_timestamp) else {continue}
            if (self.timestampIsNewer(timestamp: timestamp) && (primitive.station_name == self.name)) {
                self.lastUpdated = timestamp
                self.airTemperature = Float(primitive.air_temperature) ?? 0
                self.windSpeed = Float(primitive.wind_speed) ?? 0
                self.windGust = Float(primitive.maximum_wind_speed) ?? 0
                self.windDirection = Int(primitive.wind_direction) ?? 0
                self.intervalRain = Float(primitive.interval_rain) ?? 0
            }
        }
    }
}
