//
//  Waypoint.swift
//  ChiSail
//
//  Created by Logan Noel on 2/28/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import Foundation
import MapKit

// https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
class Waypoint : MapObject, NSSecureCoding {
    private var windDirection = 0
    private var windSpeed = Float(0.0)
    private var temperature = Float(0.0)
    private var humidity = 0
    private var pressure = 0
    private var hasBeenUpdated = false
    
    var closestWaveStation : WaveStation?
    var closestWindStation : WindStation?
    
    static var supportsSecureCoding = true
    
    var longDescription : String {
        if (!hasBeenUpdated) {
            return "Waiting to download latest data..."
        }
        let windDirectionString = Formatter.shared.getFormattedWindDirection(windDirection)
        let windSpeedString = Formatter.shared.getFormattedWindSpeed(windSpeed)
        let temperatureString = Formatter.shared.getFormattedTemperature(temperature)
        return "\(windSpeedString) | \(windDirectionString) | \(temperatureString)"
    }
    
    var windDirectionDescription : String {
        let windDirectionString = hasBeenUpdated ? Formatter.shared.getFormattedWindDirection(windDirection) : "Updating..."
        return "Heading: \(windDirectionString)"
    }
    
    var windSpeedDescription : String {
        let windSpeedString = hasBeenUpdated ? Formatter.shared.getFormattedWindSpeed(windSpeed) : "Updating..."
        return "Heading: \(windSpeedString)"
    }
    
    var temperatureDescription : String {
        let temperatureString = hasBeenUpdated ? Formatter.shared.getFormattedTemperature(temperature) : "Updating..."
        return "Temperature: \(temperatureString)"
    }
    
    enum Keys : String {
        case name
        case longitude
        case latitude
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: Keys.name.rawValue)
        aCoder.encode(coordinate.latitude, forKey: Keys.latitude.rawValue)
        aCoder.encode(coordinate.longitude, forKey: Keys.longitude.rawValue)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(of: NSString.self, forKey: Keys.name.rawValue)
        let longitude = aDecoder.decodeDouble(forKey: Keys.longitude.rawValue)
        let latitude = aDecoder.decodeDouble(forKey: Keys.latitude.rawValue)
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.init(name: name! as String, coordinate: coordinate)
    }
    
    init(name: String, coordinate: CLLocationCoordinate2D)
    {
        super.init(name: name, coordinate: coordinate, type: .waypoint, lastUpdated: nil)
    }
    
    func updateWithNewObservation(newObservation : OpenWeatherMapObservation)
    {
        hasBeenUpdated = true
        lastUpdated = Date()
        windDirection = newObservation.wind.deg
        windSpeed = newObservation.wind.speed
        temperature = newObservation.main.temp - 273.15 // convert from kelvin to celsius
        humidity = newObservation.main.humidity
        pressure = newObservation.main.pressure
        
    }
}
