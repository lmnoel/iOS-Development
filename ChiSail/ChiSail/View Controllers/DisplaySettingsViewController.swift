//
//  DisplaySettingsViewController.swift
//  ChiSail
//
//  Created by Logan Noel on 3/6/19.
//  Copyright © 2019 Logan Noel. All rights reserved.
//

import UIKit

class DisplaySettingsViewController: UIViewController {
    
    @IBOutlet weak var displayWaypoints: UISwitch!
    @IBOutlet weak var displayWindstations: UISwitch!
    @IBOutlet weak var displayWavestations: UISwitch!
    @IBOutlet weak var sortTypePicker: UIPickerView!
    
    let pickerOptions = ["Category", "Proximity"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayWaypoints.isOn = UserPreferences.shared.getDisplayWaypoints()
        displayWindstations.isOn = UserPreferences.shared.getDisplayWindstations()
        displayWavestations.isOn = UserPreferences.shared.getDisplayWavestations()
        switch UserPreferences.shared.rowSortType {
            case .category: sortTypePicker.selectRow(0, inComponent: 0, animated: false)
            case .proximity: sortTypePicker.selectRow(1, inComponent: 0, animated: false)
        }
        self.navigationItem.title = "Display Options"
    }
    
    // MARK: Actions
    
    @IBAction func userDidTapDisplayWaypoints(_ sender: Any) {
        guard let button = sender as? UISwitch else {return}
        UserPreferences.shared.setDisplayWaypoints(button.isOn, updateUserDefaults: true)
    }
    
    @IBAction func userDidTapDisplayWaveStations(_ sender: Any) {
        guard let button = sender as? UISwitch else {return}
        UserPreferences.shared.setDisplayWavestations(button.isOn, updateUserDefaults: true)
    }
    
    @IBAction func userDidTapDisplayWindStations(_ sender: Any) {
        guard let button = sender as? UISwitch else {return}
        UserPreferences.shared.setDisplayWindstations(button.isOn, updateUserDefaults: true)
    }

}

// MARK: PickerViewDelegate
// https://codewithchris.com/uipickerview-example/
extension DisplaySettingsViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch row {
        case 0:
            print("cat")
            UserPreferences.shared.setRowSortType(.category)
        case 1:
            print("prox")
            UserPreferences.shared.setRowSortType(.proximity)
        default: break
        }
    }
}
