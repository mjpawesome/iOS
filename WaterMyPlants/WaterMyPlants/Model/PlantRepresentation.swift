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
    var plantID: Int
}

struct PlantRepresentations: Codable {
    var plants: [PlantRepresentation]
}


