//
//  MapItemDetailViewController.swift
//  ChiSail
//
//  Created by Logan Noel on 3/1/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import UIKit
import MapKit

class MapItemDetailViewController: UIViewController {

    @IBOutlet weak var staticMapView: MKMapView!
    @IBOutlet weak var waypointStack: UIStackView!
    @IBOutlet weak var waveStationStack: UIStackView!
    @IBOutlet weak var windStationStack: UIStackView!
    
    // Waypoint Stack
    @IBOutlet weak var waypointWindSpeed: UILabel!
    @IBOutlet weak var waypointTemperature: UILabel!
    @IBOutlet weak var waypointWindDirection: UILabel!
    @IBOutlet weak var waypointLastUpdated: UILabel!
    
    
    // Wind station stack
    @IBOutlet weak var waterSensorName: UILabel!
    @IBOutlet weak var windStationWindSpeed: UILabel!
    @IBOutlet weak var windStationGustSpeed: UILabel!
    @IBOutlet weak var windStationWindDirection: UILabel!
    @IBOutlet weak var windStationTemperature: UILabel!
    @IBOutlet weak var windStationPrecipitation: UILabel!
    @IBOutlet weak var windStationLastUpdated: UILabel!
    
    // Wave station stack
    @IBOutlet weak var weatherSensorName: UILabel!
    @IBOutlet weak var waveStationWaveHeight: UILabel!
    @IBOutlet weak var waveStationWaterTemp: UILabel!
    @IBOutlet weak var waveStationLastUpdated: UILabel!
    
    var mapObject : MapObject?
    var locationService : LocationService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = mapObject?.name
        configureMapView()
        initializeStacks()
    
    }
    
    private func configureMapView() {
        staticMapView.isUserInteractionEnabled = false
        addMapAnnotations()
        setBoundingBox()
    }
    
    private func addMapAnnotations() {
        staticMapView.addAnnotation(mapObject!)
        guard let waypointObject = mapObject as? Waypoint else {return}
        if (waypointObject.closestWaveStation != nil) {
            staticMapView.addAnnotation((waypointObject.closestWaveStation)!)
        }
        if (waypointObject.closestWindStation != nil) {
            staticMapView.addAnnotation((waypointObject.closestWindStation)!)
        }
    }
    
    private func setBoundingBox() {
        var mapObjects = [mapObject]
        if (mapObject?.type == .waveStation || mapObject?.type == .windStation) {
            locationService?.centerMapOnMapObjects(mapView: staticMapView, mapObjects: mapObjects as! [MapObject])
            return
        }
        
        guard let waypointObject = mapObject as? Waypoint else {return}
        if (waypointObject.closestWaveStation != nil) {
            mapObjects.append(waypointObject.closestWaveStation)
        }
        if (waypointObject.closestWindStation != nil) {
            mapObjects.append(waypointObject.closestWindStation)
        }
        locationService?.centerMapOnMapObjects(mapView: staticMapView, mapObjects: mapObjects as! [MapObject])
    }
    
    private func initializeStacks() {
        guard let mapObjectType = mapObject?.type else {return}
        switch mapObjectType {
        case .waypoint:
            let waypoint = mapObject as! Waypoint
            prepareWaypointStack(for: waypoint)
            if waypoint.closestWaveStation != nil {
                prepareWaveStationStack(for: waypoint.closestWaveStation!)
            } else {
                waveStationStack.isHidden = true
            }
            if waypoint.closestWindStation != nil {
                prepareWindStationStack(for: waypoint.closestWindStation!)
            } else {
                windStationStack.isHidden = true
            }
        case .waveStation:
            waypointStack.isHidden = true
            windStationStack.isHidden = true
            let waveStation = mapObject as! WaveStation
            prepareWaveStationStack(for: waveStation)
        case .windStation:
            waypointStack.isHidden = true
            waveStationStack.isHidden = true
            let windStation = mapObject as! WindStation
            prepareWindStationStack(for: windStation)
        }
    }
    
    private func prepareWaypointStack(for waypoint: Waypoint) {
        waypointWindSpeed.text = waypoint.windSpeedDescription
        waypointTemperature.text = waypoint.temperatureDescription
        waypointWindDirection.text = waypoint.windDirectionDescription
        waypointLastUpdated.text = waypoint.timestampDescription
    }
    
    private func prepareWaveStationStack(for waveStation : WaveStation) {
        waterSensorName.text = waveStation.name! + " Water Sensor"
        waveStationWaterTemp.text = waveStation.longWaterTemperatureStatus
        waveStationWaveHeight.text = waveStation.waveHeightDescription
        waveStationLastUpdated.text = waveStation.timestampDescription
    }
    
    private func prepareWindStationStack(for windStation : WindStation) {
        weatherSensorName.text = windStation.name! + " Air Sensor"
        windStationWindSpeed.text = windStation.windSpeedDescription
        windStationGustSpeed.text = windStation.windGustDescription
        windStationWindDirection.text = windStation.windDirectionDescription
        windStationTemperature.text = windStation.airTemperatureDescription
        windStationLastUpdated.text = windStation.timestampDescription
        windStationPrecipitation.text = windStation.precipitationDescription
    }

}

// MARK: MapViewDelegate

extension MapItemDetailViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let mapObjectAnnotation = annotation as? MapObject else {return nil}
        let annotationView = staticMapView.dequeueReusableAnnotationView(withIdentifier: "waypoint") ?? MKAnnotationView()
        switch mapObjectAnnotation.type {
        case .waveStation:
            annotationView.image = UIImage(named: "waves_icon")
        case .waypoint:
            annotationView.image = UIImage(named: "waypoint_icon")
        case .windStation:
            annotationView.image = UIImage(named: "wind_icon")
        }
        
        annotationView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        return annotationView
        
    }
}
