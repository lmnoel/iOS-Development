//
//  DataManager.swift
//  ChiSail
//
//  Created by Logan Noel on 3/16/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import Foundation
import MapKit

class DataManager {
    var waypoints = [Waypoint]()
    var waveStations = [WaveStation]()
    var windStations = [WindStation]()
    var mapObjects = [MapObject]()
    let chicagoWeatherService = ChicagoWeatherService()
    let locationService : LocationService
    let refreshTableDelegate : RefreshTableDelegate
    
    init(locationService : LocationService, refreshTableDelegate : RefreshTableDelegate) {
        self.locationService = locationService
        self.refreshTableDelegate = refreshTableDelegate
        initializeChicagoWeatherStations()
        loadWaypointsFromFile()
        updateWaypoints()
        assignClosestStationsToWaypoints()
    }
    
    private func loadWaypointsFromFile() {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let url = documentDirectory.appendingPathComponent("waypoints")
        var waypointsFromFile = [Waypoint]()
        do {
            let data = try Data(contentsOf: url)
            waypointsFromFile = try (NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Waypoint])!
        } catch (let error) {
            print("Error fetching waypoints from file: \(error)")
        }
        self.waypoints = self.sortMapObjectsByProximity(mapObjects: waypointsFromFile) as! [Waypoint]
    }
    
    private func saveWaypointsToFile() {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let url = documentDirectory.appendingPathComponent("waypoints")
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: waypoints, requiringSecureCoding: true)
            try data.write(to: url)
        } catch (let error) {
            print(error)
        }
    }
    
    private func initializeChicagoWeatherStations() {
        chicagoWeatherService.downloadWeatherSensorPrimitives(completion: { sensorPrimitives, error in
            guard let sensorPrimitives = sensorPrimitives, error == nil else {
                print(error ?? "unknown error")
                return
            }
            for sensorPrimitive in sensorPrimitives {
                let coordinate = CLLocationCoordinate2D(latitude: Double(sensorPrimitive.latitude)!, longitude: Double(sensorPrimitive.longitude)!)
                if sensorPrimitive.sensor_type == "Weather" {
                    let windStation = WindStation(name: sensorPrimitive.sensor_name, coordinate: coordinate)
                    self.windStations.append(windStation)
                } else if sensorPrimitive.sensor_type == "Water" {
                    let waveStation = WaveStation(name: sensorPrimitive.sensor_name, coordinate: coordinate)
                    self.waveStations.append(waveStation)
                } else {
                    print("unrecognized sensor type")
                }
            }
            self.waveStations = self.sortMapObjectsByProximity(mapObjects: self.waveStations) as! [WaveStation]
            self.windStations = self.sortMapObjectsByProximity(mapObjects: self.windStations) as! [WindStation]
            self.updateWaveStations()
            self.updateWindStations()
        })
    }
    
    private func updateWaveStations() {
        chicagoWeatherService.downloadWaveStationObservationPrimitives(completion: { waveStationPrimitives, error in
            guard let waveStationPrimitives = waveStationPrimitives, error == nil else {
                print(error ?? "unknown error")
                return
            }
            for waveStation in self.waveStations {
                waveStation.updateWithPrimitives(waveStationPrimitives)
            }
        })
    }
    
    private func updateWindStations() {
        chicagoWeatherService.downloadWindStationObservationPrimitives(completion: { windStationPrimitives, error in
            guard let windStationPrimitives = windStationPrimitives, error == nil else {
                print(error ?? "unknown error")
                return
            }
            for windStation in self.windStations {
                windStation.updateWithPrimitives(windStationPrimitives)
            }
        })
    }
    
    func updateWaypoints() {
        for waypoint in self.waypoints {
            updateWaypoint(waypoint)
        }
    }
    
    private func updateWaypoint(_ waypoint : Waypoint) {
        chicagoWeatherService.downloadOpenWeatherMapObservation(for: waypoint.coordinate, completion: {openWeatherMapObservation, error in
            guard let openWeatherMapObservation = openWeatherMapObservation, error == nil else {
                print(error ?? "unknown error")
                return
            }
            waypoint.updateWithNewObservation(newObservation: openWeatherMapObservation)
            guard let currentCell = waypoint.currentCell else {return}
            self.refreshTableDelegate.updateCell(at : currentCell)
        })
    }
    
    // MARK: Utility Functions
    private func sortMapObjectsByProximity(mapObjects : [MapObject]) -> [MapObject] {
        let currentLocation = locationService.currentLocation
        for mapObject in mapObjects {
            mapObject.setDistanceFromLocation(fromLocation: currentLocation)
        }
        return mapObjects.sorted(by: {$0.distanceFromCurrentLocation! < $1.distanceFromCurrentLocation!})
    }
    
    private func assignClosestStationsToWaypoints() {
        for waypoint in self.waypoints {
            assignClosestStationsToWaypoint(waypoint)
        }
    }
    
    func refreshMapObjects() {
        mapObjects.removeAll()
        if UserPreferences.shared.showWaypoints {
            mapObjects += waypoints as [MapObject]
        }
        if UserPreferences.shared.showWindStations {
            mapObjects += windStations as [MapObject]
        }
        if UserPreferences.shared.showWaveStations {
            mapObjects += waveStations as [MapObject]
        }
        mapObjects = sortMapObjectsByProximity(mapObjects: mapObjects)
    }
    
    func deleteWaypoint(_ waypoint : Waypoint) {
        self.mapObjects = self.mapObjects.filter{$0.name != waypoint.name}
        self.waypoints = self.waypoints.filter{$0.name != waypoint.name}
        saveWaypointsToFile()
    }
    
    private func assignClosestStationsToWaypoint(_ waypoint : Waypoint) {
        // Assign wind station
        var closestWindStation : WindStation?
        var closestWindStationDistance = UserPreferences.shared.maxDistanceForStations
        for windStation in self.windStations {
            let distanceFromWaypoint = waypoint.calculateDistanceFromLocation(fromLocation: windStation.coordinate)
            if (distanceFromWaypoint < closestWindStationDistance) {
                closestWindStation = windStation
                closestWindStationDistance = distanceFromWaypoint
            }
        }
        waypoint.closestWindStation = closestWindStation
        
        // Assign wave station
        var closestWaveStation : WaveStation?
        var closestWaveStationDistance = UserPreferences.shared.maxDistanceForStations
        for waveStation in self.waveStations {
            let distanceFromWaypoint = waypoint.calculateDistanceFromLocation(fromLocation: waveStation.coordinate)
            if (distanceFromWaypoint < closestWaveStationDistance) {
                closestWaveStation = waveStation
                closestWaveStationDistance = distanceFromWaypoint
            }
        }
        waypoint.closestWaveStation = closestWaveStation
    }
}

// MARK: AddMapObjectDelegate

extension DataManager : AddMapObjectDelegate {
    
    func addWaypoint(_ waypoint : Waypoint) {
        assignClosestStationsToWaypoint(waypoint)
        self.waypoints.append(waypoint)
        updateWaypoint(waypoint)
        self.waypoints = sortMapObjectsByProximity(mapObjects: self.waypoints) as! [Waypoint]
            self.refreshTableDelegate.refreshTable()
            saveWaypointsToFile()
    }
    
    func addWaveStation(_ waveStation : WaveStation) {
        self.waveStations.append(waveStation)
        self.waveStations = sortMapObjectsByProximity(mapObjects: self.waveStations) as! [WaveStation]
        self.refreshTableDelegate.refreshTable()
    }
    
    func addWindStation(_ windStation : WindStation) {
        self.windStations.append(windStation)
        self.windStations = sortMapObjectsByProximity(mapObjects: self.windStations) as! [WindStation]
        self.refreshTableDelegate.refreshTable()
    }
}
