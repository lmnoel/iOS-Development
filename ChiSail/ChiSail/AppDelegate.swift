//
//  AppDelegate.swift
//  ChiSail
//
//  Created by Logan Noel on 2/28/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard UserDefaults.standard.string(forKey: UserDefaultsKey.firstLaunched.rawValue) == nil else {
            let instancesLaunched = UserDefaults.standard.integer(forKey: UserDefaultsKey.instancesLaunched.rawValue)
            UserDefaults.standard.set(instancesLaunched + 1, forKey: UserDefaultsKey.instancesLaunched.rawValue)
            return true }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/YY"
        let launchedString = dateFormatter.string(from: Date())
        UserDefaults.standard.set(launchedString, forKey: UserDefaultsKey.firstLaunched.rawValue)
        UserDefaults.standard.set("metric", forKey: UserDefaultsKey.distanceUnits.rawValue)
        UserDefaults.standard.set("fahrenheit", forKey: UserDefaultsKey.temperatureUnits.rawValue)
        UserDefaults.standard.set("knots", forKey: UserDefaultsKey.windSpeedUnits.rawValue)
        UserDefaults.standard.set(1, forKey: UserDefaultsKey.instancesLaunched.rawValue)
        UserDefaults.standard.set("category", forKey: UserDefaultsKey.rowSortType.rawValue)
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.showWaypoints.rawValue)
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.showWindStations.rawValue)
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.showWaveStations.rawValue)

        return true
    }


    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {

        if shortcutItem.type == "AddWaypointAction"{
            ShortcutManager.shared.segueToAddWaypointIsSet = true            
        }
    }
    
}

