//
//  UserRepresentation.swift
//  WaterMyPlants
//
//  Created by Joe Veverka on 6/21/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation

struct UserRepresentation: Codable {
    let username: String
    let password: String
    let phoneNumber: String
    let identifier = Int()
    
    var plants: [PlantRepresentation]?
    
    enum CodingKeys: String, CodingKey {
         case identifier = "id"
         case username
         case password
         case phoneNumber = "phone_number"
     }
}
