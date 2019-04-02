//
//  FindClosestStationsDelegate.swift
//  ChiSail
//
//  Created by Logan Noel on 3/17/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import Foundation
import CoreLocation

protocol FindClosestStationsDelegate : class {
    func getClosestStationOfType(stationCoordinate: CLLocationCoordinate2D, stationType : MapObjectType) -> MapObject?
}
