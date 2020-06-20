//
//  TextFieldBottomBorder.swift
//  WaterMyPlants
//
//  Created by Joe Veverka on 6/19/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func addBottomBorder() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
        bottomLine.backgroundColor = #colorLiteral(red: 0.03053783625, green: 0.003107197117, blue: 0.01022781059, alpha: 1)
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
}

