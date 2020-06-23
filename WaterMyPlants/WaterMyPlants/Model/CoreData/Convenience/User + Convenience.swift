//
//  User + Convenience.swift
//  WaterMyPlants
//
//  Created by Joe Veverka on 6/21/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import CoreData

extension User {

    @discardableResult convenience init?(
        username: String,
        password: String,
        phoneNumber: String,
        id: Int16,
        context: NSManagedObjectContext = CoreDataManager.shared.mainContext
    ) {
        self.init(context: context)
        self.id = id

        if !username.isEmpty && !password.isEmpty && !phoneNumber.isEmpty {
            self.username = username
            self.password = password
            self.phoneNumber = phoneNumber
        } else {
            print("required fields were empty")
            return nil
        }
    }
    
    var userRepresentation: UserRepresentation? {
        guard let username = username else { return nil }
        return UserRepresentation(
            username: username,
            password: nil,
            phoneNumber: self.phoneNumber,
            identifier: Int(self.id),
            token: nil
        )
    }
}
