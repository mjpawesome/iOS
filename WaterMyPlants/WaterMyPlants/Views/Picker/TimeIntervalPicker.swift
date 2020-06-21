//
//  TimeIntervalPicker.swift
//  WaterMyPlants
//
//  Created by Shawn James on 6/21/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import UIKit

class TimeIntervalPicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {

    var days: [String] = ["1", "2", "3", "4", "5", "6", "7"]
    var calendarComponent: [String] = ["Days", "Weeks"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
       return 10
    }
    
    
    
}
