//
//  LocationService.swift
//  ChiSail
//
//  Created by Logan Noel on 3/9/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import Foundation

import CoreLocation
import MapKit

class LocationService {
    private let locationManagerDelegate : CLLocationManagerDelegate
    let defaultLocation = CLLocationCoordinate2D(latitude: 41.886793, longitude: -87.611025)
    private let minimumRadius = Float(1000)
    private let borderMultiple = Float(2.6)
    let locationManager : CLLocationManager
    var currentLocation : CLLocationCoordinate2D
    
    init(locationManagerDelegate : CLLocationManagerDelegate) {
        self.locationManagerDelegate = locationManagerDelegate
        locationManager = CLLocationManager()
        locationManager.delegate = locationManagerDelegate
        currentLocation = defaultLocation
        requestLocationAccess()
    }
    
    // https://www.appcoda.com/mapkit-beginner-guide/
    private func requestLocationAccess() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .denied, .restricted:
            break
        default:
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            break
        }
    }
    
    // https://www.raywenderlich.com/548-mapkit-tutorial-getting-started
    func centerMapOnLocationWithRadius(location: CLLocationCoordinate2D, mapView : MKMapView, radius: Float) {
        let regionRadius = CLLocationDistance(radius)
        let coordinateRegion = MKCoordinateRegion(center: location,
                                                  latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func centerMapOnCurrentLocation(mapView : MKMapView, radius: Float) {
        centerMapOnLocationWithRadius(location: currentLocation, mapView: mapView, radius: radius)
    }
    
    func centerMapOnMapObjects(mapView : MKMapView, mapObjects : [MapObject]) {
        var maxLatitude = -90.0
        var maxLongitude = -90.0
        var minLatitude = 90.0
        var minLongitude = 90.0
        for mapObject in mapObjects {
            maxLatitude = max(maxLatitude, mapObject.coordinate.latitude)
            minLatitude = min(minLatitude, mapObject.coordinate.latitude)
            maxLongitude = max(maxLongitude, mapObject.coordinate.longitude)
            minLongitude = min(minLongitude, mapObject.coordinate.longitude)
        }
        let centerLatitude = (maxLatitude + minLatitude) / 2.0
        let centerLongitude = (maxLongitude + minLongitude) / 2.0
        let centerCoordinate = CLLocation(latitude: centerLatitude, longitude: centerLongitude)
        let latitudeRadiusCoordinate = CLLocation(latitude: maxLatitude, longitude: centerCoordinate.coordinate.longitude)
        let longitudeRadiusCoordinate = CLLocation(latitude: centerCoordinate.coordinate.latitude, longitude: maxLongitude)
        let latitudeRadius = max(self.minimumRadius, Float(centerCoordinate.distance(from: latitudeRadiusCoordinate)))
        let longitudeRadius = max(self.minimumRadius,Float(centerCoordinate.distance(from: longitudeRadiusCoordinate)))
        var actualRadius =  max(self.minimumRadius, longitudeRadius)
        actualRadius = max(actualRadius, latitudeRadius) * self.borderMultiple
        centerMapOnLocationWithRadius(location: centerCoordinate.coordinate, mapView: mapView, radius: actualRadius)
    }
    
}
