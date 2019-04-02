//
//  WeatherFormatter.swift
//  ChiSail
//
//  Created by Logan Noel on 3/1/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import Foundation
import CoreLocation

class Formatter {
    private let chicagoAPIDateFormat =  "yyyy-MM-dd'T'HH:mm:ss.SSS"
    private let lastUpdatedTimestampFormat = "MM/dd/yy HH:mm"
    private let dateFormatter = DateFormatter()
    
    static let shared = Formatter()
    
    func getDateTimeFromString(timestamp : String) -> Date? {
        dateFormatter.dateFormat = chicagoAPIDateFormat
        return dateFormatter.date(from: timestamp)
    }
    
    func getFormattedWindDirection(_ windDirection : Int) -> String {
        let doubleWindDirection = Double(windDirection)
        if (doubleWindDirection < 22.5) {
            return "N";
        } else if (doubleWindDirection < 67.5) {
            return "NE"
        } else if (doubleWindDirection < 112.5) {
            return "E"
        } else if (doubleWindDirection < 157.5) {
            return "SE"
        } else if (doubleWindDirection < 202.5) {
            return "S"
        } else if (doubleWindDirection < 247.5) {
            return "SW"
        } else if (doubleWindDirection < 292.5) {
            return "W"
        } else if (doubleWindDirection < 337.5) {
            return "NW"
        } else {
            return "N"
        }
    }
    
    func getFormattedWindSpeed(_ windSpeed : Float) -> String {
        switch UserPreferences.shared.windSpeedUnits {
        case .knots:
            return String(format: "%.1f kts", windSpeed * 1.94384) // m/s to kts
        case .milesPerHour:
            return String(format: "%.1f mph", windSpeed * 2.23694) // m/s to mph
        case .kilometersPerHour:
            return String(format: "%.1f kph", windSpeed * 3.6) // m/s to kph
            
        }
    }
    
    func getFormattedTemperature(_ temperature : Float) -> String {
        switch UserPreferences.shared.temperatureUnits {
        case .Celsius:
            return String(format: "%.1f°C", temperature)
        case .Farenheit:
            return String(format: "%.1f°F", temperature * (9/5) + 32)
        }
    }
    
    func getFormattedWaveHeight(_ waveHeight : Float) -> String {
        switch UserPreferences.shared.distanceUnits {
        case .metric:
            return String(format: "%.1fM", waveHeight)
        case .imperial:
            return String(format: "%.1f'", waveHeight * 3.28084)
        }
    }
    
    func getFormattedCoordinate(_ coordinate : CLLocationCoordinate2D) -> String {
        return String(format: "(%.5f, %.5f)",coordinate.latitude, coordinate.longitude)
    }
    
    func getFormattedTimestamp(_ timeStamp : Date) -> String {
        dateFormatter.dateFormat = lastUpdatedTimestampFormat
        return dateFormatter.string(from: timeStamp)
    }
    
    func getFormattedPrecipitation(_ precipitation : Float) -> String {
        switch UserPreferences.shared.distanceUnits {
        case .metric:
            return String(format: "%.f cm", precipitation / 10.0)
        case .imperial:
            return String(format: "%.f\"", precipitation / 25.4)
        }
    }
}
