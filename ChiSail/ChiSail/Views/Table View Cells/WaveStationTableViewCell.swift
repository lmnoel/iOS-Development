//
//  WaveStationTableViewCell.swift
//  ChiSail
//
//  Created by Logan Noel on 2/28/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import UIKit

class WaveStationTableViewCell: UITableViewCell {
    @IBOutlet weak var stationName: UILabel!
    @IBOutlet weak var stationStatus: UILabel!
    @IBOutlet weak var stationTemperature: UILabel!
    var waveStation : WaveStation?
}
