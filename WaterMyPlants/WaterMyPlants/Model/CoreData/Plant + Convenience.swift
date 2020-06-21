//
//  Plant + Convenience.swift
//  WaterMyPlants
//
//  Created by Joe Veverka on 6/21/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation
import CoreData

extension Plant {
    //MARK: -Properties
    var plantRepresentation: PlantRepresentation? {
        
        guard let species = species,
            let nickname = nickname,
            let h2oFrequency = h2oFrequency,
            let userID = user_id else { return nil }
        return PlantRepresentation(nickname: nickname, species: species, h2oFrequency: h2oFrequency, id: Int(id), userID: userID)
        
        
    }
}
