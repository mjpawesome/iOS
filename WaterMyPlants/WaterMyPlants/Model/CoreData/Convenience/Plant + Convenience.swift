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
            let img_url = img_url,
            let nickname = nickname,
            let h2oFrequency = h2oFrequency,
            let userID = userID else { return nil }
        return PlantRepresentation(
            plantID: Int(Int16(id)),
            nickname: nickname,
            species: species,
            h2oFrequency: h2oFrequency,
            img_url: img_url,
            user: userID
        )
    }
    
    @discardableResult convenience init(id: Int = Int.random(in: 1...32766),
                                        species: String,
                                        nickname: String,
                                        h2oFreqency: String,
                                        userID: String,
                                        img_url: String,
                                        context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.init(context: context)
        self.species = species
        self.nickname = nickname
        self.h2oFrequency = h2oFreqency
        self.userID = userID
        self.img_url = img_url
        self.id = Int16(id)
    }
    
    @discardableResult convenience init?(
        plantRepresentation: PlantRepresentation,
        context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        
        self.init(context: context)
        id = Int16(plantRepresentation.plantID)
        species = plantRepresentation.species
        nickname = plantRepresentation.nickname
        h2oFrequency = plantRepresentation.h2oFrequency
        userID = plantRepresentation.user
        img_url = plantRepresentation.img_url
        self.user = user
    }
}

