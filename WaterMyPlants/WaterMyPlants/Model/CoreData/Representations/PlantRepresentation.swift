//
//  PlantRepresentation.swift
//  WaterMyPlants
//
//  Created by Mark Poggi on 6/20/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation

//struct PlantRepresentation: Codable, Equatable {
//    var nickname: String
//    var species: String
//    var h2oFrequency: String
//    var identifier: Int
//    var userID: String
//    var imageURL: String
//
//    enum CodingKeys: String, CodingKey {
//        case identifier = "id"
//        case species
//        case h2oFrequency = "h2o_frequency"
//        case userID = "user_id"
//        case nickname
//        case imageURL
//    }
//}
//
struct PlantRepresentations: Codable {
    var results: [PlantRepresentation]
}

// MARK: - WelcomeElement
struct PlantRepresentation: Codable {
    var plantID: Int
    var nickname, species, h2oFrequency: String
    var img_url: String?
    var user: String
    
    enum CodingKeys: String, CodingKey {
        case plantID = "plant_id"
        case nickname, species
        case h2oFrequency = "h2o_frequency"
        case img_url = "img_url"
        case user
    }
}


//// MARK: - Encode/decode helpers
//
//class JSONNull: Codable, Hashable {
//
//    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
//        return true
//    }
//
//    public var hashValue: Int {
//        return 0
//    }
//
//    public func hash(into hasher: inout Hasher) {
//        // No-op
//    }
//
//    public init() {}
//
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if !container.decodeNil() {
//            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encodeNil()
//    }
//}
