//
//  MasterViewController.swift
//  ChiSail
//
//  Created by Logan Noel on 2/28/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import UIKit
import MapKit
import StoreKit
import CoreLocation

// https://stackoverflow.com/questions/33583621/show-version-of-app-in-launch-screen-with-swift
class MasterViewController: UIViewController {

    @IBOutlet weak var masterMap: MKMapView!
    @IBOutlet weak var masterTable: UITableView!
    
    var locationService : LocationService?
    var dataManager : DataManager?
    var segueToAddWaypointAfterLoad : Bool?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Home"
        
        // Set observers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateSettings),
            name: UserDefaults.didChangeNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        // Configure refresh control
        masterTable.refreshControl = UIRefreshControl()
        masterTable.refreshControl?.addTarget(self, action: #selector(self.handleWaypointDataRefresh), for: .valueChanged)
        
        // initialize services
        UserPreferences.shared.setRefreshTableDelegate(self)
        locationService = LocationService(locationManagerDelegate: self)
        dataManager = DataManager(locationService: locationService!, refreshTableDelegate: self)
        
        // Present review controller
        if UserDefaults.standard.integer(forKey: UserDefaultsKey.instancesLaunched.rawValue) == 3 {
            presentReviewController()
        }
        
        // Load data
        refreshTable()
        refreshMap()
    
    }
    
    @objc func viewDidBecomeActive() {
        if (ShortcutManager.shared.segueToAddWaypointIsSet) {
            ShortcutManager.shared.segueToAddWaypointIsSet = false
            performSegue(withIdentifier: "waypointAddSegue", sender: self)
        }
        refreshTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshTable()
    }
    
    // https://developer.apple.com/documentation/storekit/skstorereviewcontroller
    private func presentReviewController() {
        SKStoreReviewController.requestReview()
    }
    
    @objc func handleWaypointDataRefresh() {
        dataManager?.updateWaypoints()
        refreshTable()
        masterTable.refreshControl?.endRefreshing()
    }
    
    private func refreshMap() {
        dataManager?.refreshMapObjects()
        locationService?.centerMapOnMapObjects(mapView: masterMap, mapObjects: dataManager!.mapObjects)
    }
    
    @objc func updateSettings() {
        UserPreferences.shared.updateSettings()
    }
    
    
    // MARK: Segue Handlers
    // https://stackoverflow.com/questions/31457300/swift-prepareforsegue-with-two-different-segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "waypointAddSegue" {
            guard let destination = segue.destination as? AddWaypointViewController else {return}
            destination.locationService = locationService
            destination.addMapObjectDelegate = dataManager
        } else if segue.identifier == "waypointDetailSegue" {
            guard let destination = segue.destination as? MapItemDetailViewController else {return}
            guard let waypointCell = sender as? WaypointTableViewCell else {return}
            destination.mapObject = waypointCell.waypoint
            destination.locationService = locationService
        } else if segue.identifier == "windStationDetailSegue" {
            guard let destination = segue.destination as? MapItemDetailViewController else {return}
            guard let windStationCell = sender as? WindStationTableViewCell else {return}
            destination.mapObject = windStationCell.windStation
            destination.locationService = locationService
        } else if segue.identifier == "waveStationDetailSegue" {
            guard let destination = segue.destination as? MapItemDetailViewController else {return}
            guard let waveStationCell = sender as? WaveStationTableViewCell else {return}
            destination.mapObject = waveStationCell.waveStation
            destination.locationService = locationService
        }
    }
}

// MARK: MapViewDelegate

extension MasterViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else {return nil}
        let mapObjectAnnotation = annotation as! MapObject
        let annotationView = masterMap.dequeueReusableAnnotationView(withIdentifier: "waypoint") ?? MKAnnotationView()
        
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

// MARK: TableViewDelegate

extension MasterViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch UserPreferences.shared.rowSortType {
        case .category:
            switch UserPreferences.shared.getSectionTypeBySectionNumber(forSectionNumber: section) {
            case .waypoint: return self.dataManager!.waypoints.count
            case .waveStation: return self.dataManager!.waveStations.count
            case .windStation: return self.dataManager!.windStations.count
            }
        case .proximity:
            return self.dataManager!.mapObjects.count
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        switch UserPreferences.shared.rowSortType {
            case .category:
                return UserPreferences.shared.sectionsInUse
            case .proximity:
                return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch UserPreferences.shared.rowSortType {
        case .category:
            switch(UserPreferences.shared.getSectionTypeBySectionNumber(forSectionNumber: section)) {
            case .waypoint: return "Waypoints"
            case .waveStation: return "Water Sensors"
            case .windStation: return "Weather Sensors"
            }
        case .proximity:
            return nil
        }
        
    }

    func getMapObjectCellByIndexPath(cellForRowAt indexPath : IndexPath) -> MapObject {
        switch UserPreferences.shared.rowSortType {
        case .category:
            let mapObjectType = UserPreferences.shared.getSectionTypeBySectionNumber(forSectionNumber: indexPath.section)
            switch mapObjectType {
            case .waypoint:
                return dataManager!.waypoints[indexPath.row]
            case .waveStation:
                return dataManager!.waveStations[indexPath.row]
            case .windStation:
                return dataManager!.windStations[indexPath.row]
                
            }
        case .proximity:
            return dataManager!.mapObjects[indexPath.row]
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mapObject = getMapObjectCellByIndexPath(cellForRowAt: indexPath)
        mapObject.currentCell = indexPath
        switch mapObject.type {
        case .waypoint:
            return buildWaypointCell(waypoint: mapObject as! Waypoint)
        case .waveStation:
            return buildWaveStationCell(waveStation: mapObject as! WaveStation)
        case .windStation:
            return buildWindStationCell(windStation: mapObject as! WindStation)
        }
    }
    
    func buildWaypointCell(waypoint : Waypoint) -> WaypointTableViewCell {
        let cell = masterTable.dequeueReusableCell(withIdentifier: "WaypointTableViewCell") as! WaypointTableViewCell
        cell.waypoint = waypoint
        cell.waypointName.text = waypoint.name
        cell.waypointStatus.text = waypoint.longDescription
        
        cell.waveStationIcon.isHidden = waypoint.closestWaveStation == nil
        cell.windStationIcon.isHidden = waypoint.closestWindStation == nil

        return cell
    }
    
    func buildWaveStationCell(waveStation : WaveStation) ->WaveStationTableViewCell {
        let cell = masterTable.dequeueReusableCell(withIdentifier: "WaveStationTableViewCell") as! WaveStationTableViewCell
        cell.waveStation = waveStation
        cell.stationName.text = waveStation.name
        cell.stationStatus.text = waveStation.waveHeightDescription
        cell.stationTemperature.text = waveStation.shortWaterTemperatureStatus
        
        cell.layer.borderWidth = 2
        cell.layer.borderColor = waveStation.getColorForWaterConditions()
        
        return cell
    }
    
    func buildWindStationCell(windStation : WindStation) -> WindStationTableViewCell {
        let cell = masterTable.dequeueReusableCell(withIdentifier: "WindStationTableViewCell") as! WindStationTableViewCell
        cell.windStation = windStation
        cell.stationName.text = windStation.name
        cell.stationStatus.text = windStation.longDescription

        cell.layer.borderWidth = 2
        cell.layer.borderColor = windStation.getColorValueForWindIntensity()
        cell.reanimateCompass()
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(75)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let mapObject = getMapObjectCellByIndexPath(cellForRowAt: indexPath)
        return mapObject is Waypoint
    }
    
    // https://www.hackingwithswift.com/example-code/uikit/how-to-swipe-to-delete-uitableviewcells
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let mapObject = getMapObjectCellByIndexPath(cellForRowAt: indexPath)
        guard editingStyle == .delete else {return}
        guard let waypointObject = mapObject as? Waypoint else {return}
        dataManager?.deleteWaypoint(waypointObject)
        masterTable.deleteRows(at: [indexPath], with: .fade)
    }
}

// MARK: RefreshTableDelegate

extension MasterViewController : RefreshTableDelegate {
    func refreshTable() {
        self.masterMap.removeAnnotations(self.masterMap.annotations)
        
        if UserPreferences.shared.rowSortType == .proximity {
            self.dataManager!.refreshMapObjects()
            self.masterMap.addAnnotations(self.dataManager!.mapObjects)
        } else {
            if UserPreferences.shared.showWaypoints {
                self.masterMap.addAnnotations(self.dataManager!.waypoints)
            }
            if UserPreferences.shared.showWaveStations {
                self.masterMap.addAnnotations(self.dataManager!.waveStations)
            }
            if UserPreferences.shared.showWindStations {
                self.masterMap.addAnnotations(self.dataManager!.windStations)
            }
        }
        self.masterTable.reloadData()
    }
    
    func updateCell(at indexPath : IndexPath) {
        self.masterTable.reloadRows(at: [indexPath], with: .fade)
    }
}

// MARK: LocationManagerDelegate

extension MasterViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentMeasurement: CLLocationCoordinate2D = self.locationService!.locationManager.location?.coordinate ?? self.locationService!.defaultLocation
        self.locationService!.currentLocation = currentMeasurement
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error){
        print("Location manager failed with error = \(error)")
    }
}
