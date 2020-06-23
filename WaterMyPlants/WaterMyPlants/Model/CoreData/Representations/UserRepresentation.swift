//
//  UserRepresentation.swift
//  WaterMyPlants
//
//  Created by Joe Veverka on 6/21/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation

struct UserDetails: Codable {
    let user: UserRepresentation
}

struct UserRepresentation: Codable {
    let username: String
    let password: String?
    let phoneNumber: String?
    let identifier: Int?
    var token: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case username
        case password
        case token
        case phoneNumber = "phone_number"
    }
}
