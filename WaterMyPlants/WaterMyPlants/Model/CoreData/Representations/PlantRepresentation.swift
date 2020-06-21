//
//  PlantRepresentation.swift
//  WaterMyPlants
//
//  Created by Mark Poggi on 6/20/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation

struct PlantRepresentation: Codable, Equatable {
    var nickname: String
    var species: String
    var h2oFrequency: String
    var identifier: Int
    var userID: String
    var imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case species
        case h2oFrequency = "h2o_frequency"
        case userID = "user_id"
        case nickname
        case imageURL
    }
}

struct PlantRepresentations: Codable {
    var results: [PlantRepresentation]
}


