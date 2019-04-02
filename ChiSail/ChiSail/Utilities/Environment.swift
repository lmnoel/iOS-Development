//
//  Environment.swift
//  ChiSail
//
//  Created by Logan Noel on 3/17/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import Foundation

// https://medium.com/@lucianoalmeida1/continuous-integration-environment-variables-in-ios-projects-using-swift-f72e50176a91
struct Environment {
    static var OWMAppId : String = Environment.variable(named: "OWM_APP_ID") ?? ""
    
    static func variable(named name : String) -> String? {
        let processInfo = ProcessInfo.processInfo
        guard let value = processInfo.environment[name] else {
            return nil
        }
        return value
    }
}
