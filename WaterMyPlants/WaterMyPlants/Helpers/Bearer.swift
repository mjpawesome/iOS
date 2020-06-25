//
//  Bearer.swift
//  WaterMyPlants
//
//  Created by Mark Poggi on 6/20/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation

// MARK: - Bearer <-- from sign in
struct Bearer: Codable {
    let welcome: String // this contains username (idea is to present a welcome to user"
    let userID: Int
    let token: String
    
    enum CodingKeys: String, CodingKey {
        case welcome
        case userID = "user_id"
        case token
    }
}

// MARK: - use this if decoding from signup

//// MARK: - Bearer
//struct Bearer: Codable {
//    let newUser: NewUser
//    let token: String?
//
//    enum CodingKeys: String, CodingKey {
//        case newUser = "new_user"
//        case token
//    }
//}
//
//// MARK: - NewUser
//struct NewUser: Codable {
//    let id: Int? // userId
//
//    enum CodingKeys: String, CodingKey { // just to be sure <- can delete later because it's not
//        case id
//    }
//}
