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
            let imageURL = imageURL,
            let nickname = nickname,
            let h2oFrequency = h2oFrequency,
            let userID = userID else { return nil }
        return PlantRepresentation(nickname: nickname, species: species, h2oFrequency: h2oFrequency, identifier: Int(Int16(id)), userID: userID, imageURL: imageURL)
    }
    
    @discardableResult convenience init(id: Int = Int.random(in: 1...100),
                                        species: String,
                                        nickname: String,
                                        h2oFreqency: String,
                                        userID: String,
                                        imageURL: String,
                                        context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.init(context: context)
        self.species = species
        self.nickname = nickname
        self.h2oFrequency = h2oFreqency
        self.userID = userID
        self.id = Int16(id)
    }
    
    @discardableResult convenience init?(
        plantRepresentation: PlantRepresentation,
        context: NSManagedObjectContext = CoreDataManager.shared.mainContext,
        userRepresentation: UserRepresentation) {
        
        guard let user = User(userRep: userRepresentation, context: context) else { return nil }
        
        self.init(context: context)
        id = Int16(plantRepresentation.identifier)
        species = plantRepresentation.species
        nickname = plantRepresentation.nickname
        h2oFrequency = plantRepresentation.h2oFrequency
        userID = plantRepresentation.userID
        imageURL = plantRepresentation.imageURL
        self.user = user
    }
}

