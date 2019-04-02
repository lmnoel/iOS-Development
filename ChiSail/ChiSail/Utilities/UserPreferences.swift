//
//  UserPreferences.swift
//  ChiSail
//
//  Created by Logan Noel on 3/1/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import Foundation

enum RowSortType {
    case category, proximity
}

enum TemperatureUnits {
    case Farenheit, Celsius
}

enum WindSpeedUnits {
    case knots, milesPerHour, kilometersPerHour
}

enum DistanceUnits {
    case imperial, metric
}

class UserPreferences {
    var rowSortType = RowSortType.category
    var showWaypoints : Bool
    var showWaveStations : Bool
    var showWindStations : Bool
    private var waypointsSectionNumber : Int?
    private var waveStationSectionNumber : Int?
    private var windStationSectionNumber : Int?
    var sectionsInUse = 0
    let maxDistanceForStations = 5000.0 // meters
    var temperatureUnits = TemperatureUnits.Farenheit
    var windSpeedUnits = WindSpeedUnits.knots
    var distanceUnits = DistanceUnits.imperial
    var refreshTableDelegate : RefreshTableDelegate?
    static let shared = UserPreferences()
    
    private init() {
        self.showWaypoints = false
        self.showWindStations = false
        self.showWaveStations = false
        setDisplayWaypoints(true, updateUserDefaults: false)
        setDisplayWindstations(true, updateUserDefaults: false)
        setDisplayWavestations(true, updateUserDefaults: false)
    }

    func setRefreshTableDelegate(_ delegate : RefreshTableDelegate) {
        self.refreshTableDelegate = delegate
    }
    
    func updateSettings() {
        let defaults = UserDefaults.standard
        let distanceUnits = defaults.string(forKey: UserDefaultsKey.distanceUnits.rawValue)
        let temperatureUnits = defaults.string(forKey: UserDefaultsKey.temperatureUnits.rawValue)
        let windSpeedUnits = defaults.string(forKey: UserDefaultsKey.windSpeedUnits.rawValue)
        let rowSortType = defaults.string(forKey: UserDefaultsKey.rowSortType.rawValue)
        let showWaypoints = defaults.bool(forKey: UserDefaultsKey.showWaypoints.rawValue)
        let showWavestations = defaults.bool(forKey: UserDefaultsKey.showWaveStations.rawValue)
        let showWindstations = defaults.bool(forKey: UserDefaultsKey.showWindStations.rawValue)
        
        setDistanceUnits(distanceUnits: distanceUnits!)
        setWindSpeedUnits(windSpeedUnits: windSpeedUnits!)
        setTemperatureUnits(temperatureUnits: temperatureUnits!)
        switch rowSortType {
            case "category": self.rowSortType = .category
            case "proximity": self.rowSortType = .proximity
            default:
                break
        }
        self.setDisplayWaypoints(showWaypoints, updateUserDefaults: false)
        self.setDisplayWavestations(showWavestations, updateUserDefaults: false)
        self.setDisplayWindstations(showWindstations, updateUserDefaults: false)
        
    }
    
    private func setTemperatureUnits(temperatureUnits : String) {
        switch temperatureUnits {
        case "fahrenheit": self.temperatureUnits = .Farenheit
        case "celsius": self.temperatureUnits =  .Celsius
        default:
            break
        }
    }
    
    private func setWindSpeedUnits(windSpeedUnits : String) {
        switch windSpeedUnits {
        case "knots": self.windSpeedUnits = .knots
        case "mph": self.windSpeedUnits = .milesPerHour
        case "kph": self.windSpeedUnits =  .kilometersPerHour
        default:
            break
        }
    }
    
    private func setDistanceUnits(distanceUnits : String) {
        switch distanceUnits {
        case "imperial": self.distanceUnits = .imperial
        case "metric": self.distanceUnits =  .metric
        default:
            break
        }
    }
    
    private func setShowWaypoints(showWaypoints : Bool) {
        if self.showWaypoints == showWaypoints {return}
        self.showWaypoints = showWaypoints
        if self.showWaypoints {
            sectionsInUse += 1
            waypointsSectionNumber = 0
            waveStationSectionNumber? += 1
            windStationSectionNumber? += 1
        }
        else {
            sectionsInUse -= 1
            waypointsSectionNumber = nil
            waveStationSectionNumber? -= 1
            windStationSectionNumber? -= 1
        }
    }
    
    func setShowWaveStations(showWaveStations : Bool) {
        if self.showWaveStations == showWaveStations {return}
        self.showWaveStations = showWaveStations
        if self.showWaveStations {
            sectionsInUse += 1
            if self.showWaypoints {
                waveStationSectionNumber = 1
            }
            else {
                waveStationSectionNumber = 0
            }
            windStationSectionNumber? += 1
        }
        else {
            sectionsInUse -= 1
            waveStationSectionNumber = nil
            windStationSectionNumber? -= 1
        }
    }
    
    func setShowWindStations(showWindStations : Bool) {
        if self.showWindStations == showWindStations {return}
        self.showWindStations = showWindStations
        if self.showWindStations {
            sectionsInUse += 1
            self.windStationSectionNumber = 0
            self.windStationSectionNumber? += self.showWaypoints ? 1 : 0
            self.windStationSectionNumber? += self.showWaveStations ? 1 : 0
        } else {
            sectionsInUse -= 1
            self.windStationSectionNumber = nil
        }
    }
    
    func getSectionTypeBySectionNumber(forSectionNumber sectionNumber : Int) -> MapObjectType {
        if waypointsSectionNumber == sectionNumber {return .waypoint}
        else if waveStationSectionNumber == sectionNumber {return .waveStation}
        else {return .windStation}
    }
    
    func setRowSortType(_ rowSortType: RowSortType) {
        self.rowSortType = rowSortType
        self.refreshTableDelegate?.refreshTable()
        let defaults = UserDefaults.standard
        switch rowSortType {
        case .category:
            defaults.set("category", forKey: UserDefaultsKey.rowSortType.rawValue)
        case .proximity:
            defaults.set("proximity", forKey: UserDefaultsKey.rowSortType.rawValue)
        }
    }
    
    func getDisplayWaypoints() -> Bool {
        return showWaypoints
    }
    
    func getDisplayWindstations() -> Bool {
        return showWindStations
    }
    
    func getDisplayWavestations() -> Bool {
        return showWaveStations
    }
    
    func setDisplayWaypoints(_ displayWaypoints: Bool, updateUserDefaults: Bool) {
        if updateUserDefaults {
            let defaults = UserDefaults.standard
            defaults.set(displayWaypoints, forKey: UserDefaultsKey.showWaypoints.rawValue)
        }
        self.setShowWaypoints(showWaypoints: displayWaypoints)
        self.refreshTableDelegate?.refreshTable()
    }
    
    func setDisplayWindstations(_ displayWindstations: Bool, updateUserDefaults: Bool) {
        if updateUserDefaults {
            let defaults = UserDefaults.standard
            defaults.set(displayWindstations, forKey: UserDefaultsKey.showWindStations.rawValue)
        }
        self.setShowWindStations(showWindStations: displayWindstations)
        self.refreshTableDelegate?.refreshTable()
    }
    
    func setDisplayWavestations(_ displayWavestations: Bool, updateUserDefaults: Bool) {
        if updateUserDefaults {
            let defaults = UserDefaults.standard
            defaults.set(displayWavestations, forKey: UserDefaultsKey.showWaveStations.rawValue)
        }
        self.setShowWaveStations(showWaveStations: displayWavestations)
        self.refreshTableDelegate?.refreshTable()
    }
    
}


