//
//  ChicagoWeatherService.swift
//  ChiSail
//
//  Created by Logan Noel on 3/1/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import Foundation
import CoreLocation

class ChicagoWeatherService {
 func downloadWeatherSensorPrimitives(completion: @escaping ([WeatherSensorPrimitive]?, Error?) -> ()) {
    guard let path = Bundle.main.path(forResource: "SensorLocations", ofType: "json") else {return}
    let data = try? Data(contentsOf: URL(fileURLWithPath: path))
    guard data != nil else {return}
    do {
        let decoder = JSONDecoder()
        let result = try decoder.decode([WeatherSensorPrimitive].self, from: data!)
        completion(result, nil)
    } catch (let error) {
        completion(nil, error)
    }
    }
    
    // https://stackoverflow.com/questions/24410881/reading-in-a-json-file-using-swift
    func downloadWaveStationObservationPrimitives(completion: @escaping ([WavesStationObserevationPrimitive]?, Error?) -> ()) {
        guard let path = Bundle.main.path(forResource: "WaveStationData", ofType: "json") else {return}
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        guard data != nil else {return}
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode([WavesStationObserevationPrimitive].self, from: data!)
                completion(result, nil)
        } catch (let error) {
                completion(nil, error)
        }
    }
    
    // https://stackoverflow.com/questions/24410881/reading-in-a-json-file-using-swift
    func downloadWindStationObservationPrimitives(completion: @escaping ([WindStationObservationPrimitive]?, Error?) -> ()) {
        guard let path = Bundle.main.path(forResource: "WindStationData", ofType: "json") else {return}
        let data = try? Data(contentsOf: URL(fileURLWithPath: path))
        guard data != nil else {return}
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode([WindStationObservationPrimitive].self, from: data!)
            completion(result, nil)
        } catch (let error) {
            completion(nil, error)
        }
    }
    
    // https://medium.com/@lucianoalmeida1/continuous-integration-environment-variables-in-ios-projects-using-swift-f72e50176a91
    func downloadOpenWeatherMapObservation(for location : CLLocationCoordinate2D, completion: @escaping (OpenWeatherMapObservation?, Error?) -> ()) {
        let appId = Environment.OWMAppId


        let url = URL(string :"https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(appId)")

        let task = URLSession.shared.dataTask(with: URLRequest(url: url!)) { data, response, error in
            
            guard let data = data, let _ = response as? HTTPURLResponse, error == nil else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let queryResult = try decoder.decode(OpenWeatherMapObservation.self, from: data)
                DispatchQueue.main.async { completion(queryResult, nil) }
            } catch (let error) {
                DispatchQueue.main.async { completion(nil, error) }
            }
        }
        task.resume()
    }
    
}
