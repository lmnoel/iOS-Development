//
//  MapObject.swift
//  ChiSail
//
//  Created by Logan Noel on 3/1/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import Foundation
import MapKit

enum MapObjectType {
    case waypoint, waveStation, windStation
}

// https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
class MapObject : NSObject, MKAnnotation {
    let name: String?
    let coordinate: CLLocationCoordinate2D
    let type : MapObjectType
    var currentCell : IndexPath?
    var distanceFromCurrentLocation : CLLocationDistance?
    var lastUpdated : Date?
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        return ""
    }
    
    var timestampDescription : String {
        guard lastUpdated != nil else {return ""}
        let timestampString = Formatter.shared.getFormattedTimestamp(lastUpdated!)
        return "Last updated: \(timestampString)"
    }
    
    init(name: String, coordinate: CLLocationCoordinate2D, type : MapObjectType, lastUpdated : Date?)
    {
        self.name = name
        self.coordinate = coordinate
        self.type = type
        self.lastUpdated = lastUpdated
        super.init()
    }
    
    convenience init(name: String, coordinate: CLLocationCoordinate2D, type : MapObjectType) {
        self.init(name: name, coordinate: coordinate, type: type, lastUpdated: nil)
    }
    
    func timestampIsNewer(timestamp : Date) -> Bool {
        guard lastUpdated != nil else {return true}
        return timestamp > self.lastUpdated!
    }
    
    func setDistanceFromLocation(fromLocation : CLLocationCoordinate2D) {
        distanceFromCurrentLocation = calculateDistanceFromLocation(fromLocation: fromLocation)
    }
    
    func calculateDistanceFromLocation(fromLocation : CLLocationCoordinate2D) -> CLLocationDistance {
        let objectLocationConverted = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let fromLocationConverted = CLLocation(latitude: fromLocation.latitude, longitude: fromLocation.longitude)
        return fromLocationConverted.distance(from: objectLocationConverted)
    }
}

