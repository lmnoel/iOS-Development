//
//  RefreshTableProtocol.swift
//  ChiSail
//
//  Created by Logan Noel on 3/17/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import Foundation

protocol RefreshTableDelegate : class {
    func refreshTable()
    func updateCell(at indexPath : IndexPath)
}
