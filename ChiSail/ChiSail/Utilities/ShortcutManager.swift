//
//  ShortcutManager.swift
//  ChiSail
//
//  Created by Logan Noel on 3/17/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import Foundation

class ShortcutManager {
    static let shared = ShortcutManager()
    
    var segueToAddWaypointIsSet : Bool
    
    private init() {
        segueToAddWaypointIsSet = false
    }
}
