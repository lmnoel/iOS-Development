//
//  Primitives.swift
//  ChiSail
//
//  Created by Logan Noel on 3/1/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import Foundation

struct WeatherSensorPrimitive : Codable {
    let latitude : String
    let longitude : String
    let sensor_name : String
    let sensor_type : String
}

struct WindStationObservationPrimitive : Codable {
    let air_temperature : String
    let barometric_pressure : String
    let humidity : String
    let interval_rain : String
    let measurement_timestamp : String
    let station_name : String
    let wind_direction : String
    let wind_speed : String
    let maximum_wind_speed : String
}

struct WavesStationObserevationPrimitive : Codable {
    let beach_name : String
    let measurement_timestamp : String
    let water_temperature : String
    let wave_height : String
}

struct OWMMainPrimitive : Codable {
    let temp : Float
    let humidity : Int
    let pressure : Int
}

struct OWMWindPrimitive : Codable {
    let speed : Float
    let deg : Int

}

struct OpenWeatherMapObservation : Codable {
    let main : OWMMainPrimitive
    let wind : OWMWindPrimitive
}
