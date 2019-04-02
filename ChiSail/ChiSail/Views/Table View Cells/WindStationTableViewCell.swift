//
//  WindStationTableViewCell.swift
//  ChiSail
//
//  Created by Logan Noel on 2/28/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import UIKit

class WindStationTableViewCell: UITableViewCell {

    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var stationStatus: UILabel!
    @IBOutlet weak var compassView: CompassView!
    var windStation : WindStation?
    
    func reanimateCompass() {
        guard let windDirection = windStation?.windDirection else {return}
        guard let windSpeed = windStation?.windSpeed else  {return}
        compassView.animateCompass(actualWindHeading: windDirection, windIntensity: windSpeed)
    }

}
