//
//  TimeIntervalPicker.swift
//  WaterMyPlants
//
//  Created by Shawn James on 6/21/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import UIKit

class TimeIntervalPicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) {
        if component == 0 {
            return 7
        } else {
            return 2
        }
    }
    
}
