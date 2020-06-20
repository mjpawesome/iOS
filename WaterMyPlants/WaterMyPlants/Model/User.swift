//
//  User.swift
//  WaterMyPlants
//
//  Created by Mark Poggi on 6/20/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation

struct User: Codable, Hashable {
    var username: String
    var password: String
    var phoneNumber: String?
}

struct UserID: Codable {
    var id: Int?
}
