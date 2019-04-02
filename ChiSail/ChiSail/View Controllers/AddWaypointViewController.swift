//
//  AddWaypointViewController.swift
//  ChiSail
//
//  Created by Logan Noel on 2/28/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import UIKit
import MapKit

class AddWaypointViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var waypointLabel: UILabel!
    
    var locationService : LocationService?
    private var centerMarker: CAShapeLayer?
    private var hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    var addMapObjectDelegate : AddMapObjectDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        createCenterMarker()
        locationService!.centerMapOnCurrentLocation(mapView: mapView, radius: 5000)
        hapticFeedbackGenerator.prepare()
        ShortcutManager.shared.segueToAddWaypointIsSet = false
    }
    
    private func createCenterMarker() {
        let center = self.view.center
        let circlePath = UIBezierPath(arcCenter: center, radius: 5.0, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
        centerMarker = CAShapeLayer()
        centerMarker?.path = circlePath.cgPath
        centerMarker?.opacity = 0.8
        centerMarker?.fillColor = UIColor.purple.cgColor
        view.layer.addSublayer(centerMarker!)
    }
    
    private func updateCoordinateLabel() {
        let formattedCoordinates = Formatter.shared.getFormattedCoordinate(mapView.centerCoordinate)
        waypointLabel.text = formattedCoordinates
    }

    private func isInRange(mapCenter : CLLocationCoordinate2D) -> Bool
    {
        let mapCenterLocation = CLLocation(latitude: mapCenter.latitude, longitude: mapCenter.longitude)
        let cityCenter = locationService?.defaultLocation
        let cityCenterLocation = CLLocation(latitude: (cityCenter?.latitude)!, longitude: (cityCenter?.longitude)!)
        return mapCenterLocation.distance(from: cityCenterLocation) < 20000 // 20 km
    }
    
    // https://stackoverflow.com/questions/26567413/get-input-value-from-textfield-in-ios-alert-in-swift
    @IBAction func userDidTapSave(_ sender: Any) {
        if isInRange(mapCenter: mapView.centerCoordinate) {
            let alert = UIAlertController(title: "Waypoint Name", message : "Enter ", preferredStyle: .alert)
            alert.addTextField()
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { [weak alert] (_) in
                let textField = alert!.textFields![0]
                let waypoint = Waypoint(name: textField.text!, coordinate: self.mapView.centerCoordinate)
                self.addMapObjectDelegate?.addWaypoint(waypoint)
                self.navigationController?.popViewController(animated: true)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler : nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
             let alert = UIAlertController(title: "Warning", message : "ChiSail is designed to work with sensors on the Chicago Lakeshore. Please select a closer waypoint.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"Go back", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        }
}

// MARK: MapViewDelegate

extension AddWaypointViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView,
                 regionDidChangeAnimated animated: Bool) {
        hapticFeedbackGenerator.impactOccurred()
        updateCoordinateLabel()
        centerMarker?.opacity = 0.8
    }
    
    // https://developer.apple.com/documentation/mapkit/mkmapviewdelegate/1452345-mapview
    func mapView(_ mapView : MKMapView, regionWillChangeAnimated: Bool) {
        centerMarker?.opacity = 0.4
    }
    
    // https://stackoverflow.com/questions/34772163/how-to-detect-the-mapview-was-moved-in-swift-and-update-zoom
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizer.State.began || recognizer.state == UIGestureRecognizer.State.ended ) {
                    return true
                }
            }
        }
        return false
    }
}
