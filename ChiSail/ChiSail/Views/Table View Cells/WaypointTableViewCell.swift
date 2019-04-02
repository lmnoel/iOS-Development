//
//  WaypointTableViewCell.swift
//  ChiSail
//
//  Created by Logan Noel on 2/28/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import UIKit

class WaypointTableViewCell: UITableViewCell {
    @IBOutlet weak var waypointName: UILabel!
    @IBOutlet weak var waypointStatus: UILabel!
    @IBOutlet weak var waveStationIcon: UIImageView!
    @IBOutlet weak var windStationIcon: UIImageView!
    var waypoint : Waypoint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        waveStationIcon.layer.borderColor = UIColor.darkGray.cgColor
        waveStationIcon.layer.borderWidth = 1
        windStationIcon.layer.borderColor = UIColor.darkGray.cgColor
        windStationIcon.layer.borderWidth = 1
    }
}
