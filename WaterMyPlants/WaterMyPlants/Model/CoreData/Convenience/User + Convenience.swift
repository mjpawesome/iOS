//
//  User + Convenience.swift
//  WaterMyPlants
//
//  Created by Joe Veverka on 6/21/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation
import CoreData
extension User {
    
    
    
    @discardableResult convenience init(
        username: String,
        password: String,
        phoneNumber: String,
        id: Int16,
        context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        
        self.init(context: context)
        self.username = username
        self.password = password
        self.phoneNumber = phoneNumber
        self.id = id
        
    }
 }
