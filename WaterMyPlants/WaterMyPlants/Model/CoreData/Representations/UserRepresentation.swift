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
    //optional to avoid storing in CoreData/on server
    //password will sometimes be transmitted to the server, and sometimes not.
    let password: String?
    let phoneNumber: String?
    let identifier: Int?
    //token will always be assigned by the login method and only
    //sent to the server for methods requiring an authenticated user
    var token: String?
    
    var plants: [PlantRepresentation]?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case username
        case password
        case token
        case phoneNumber = "phone_number"
    }
}
