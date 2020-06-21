//
//  PlantController.swift
//  WaterMyPlants
//
//  Created by Joe Veverka on 6/21/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation
import CoreData

enum NetworkError: Error {
    case noIdentifier
    case otherError
    case noData
    case noDecode
    case noEncode
    case noRep
}

typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void
private let baseURL = URL(string: "https://www.google.com")!

class PlantController {
    
    private let networkService = NetworkService()
    
    func fetchPlantsFromServer(completion: @escaping CompletionHandler = { _ in }) {
        let requestURL = baseURL.appendingPathComponent("json")
        guard let request = networkService.createRequest(url: requestURL, method: .get) else {
            print("bad request")
            completion(.failure(.otherError))
            return
        }
        networkService.dataLoader.loadData(using: request) { data, _, error in
            if let error = error {
                NSLog("Error fetching tasks: \(error)")
                completion(.failure(.otherError))
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from request")
                completion(.failure(.noData))
                return
            }
            
            //decode representations
            let reps = self.networkService.decode(
                to: [String: PlantRepresentation].self,
                data: data
            )
            let unwrappedReps = reps?.compactMap { $1 }
            //update Todos
            do {
                try self.updatePlants(with: unwrappedReps ?? [])
                completion(.success(true))
            } catch {
                completion(.failure(.otherError))
                NSLog("Error updating todos: \(error)")
            }
            
        }
        
    }
    
//    func updatePlants(with representations: [PlantRepresentation]) throws {
//        let identifierToFetch = representations.compactMap { $0.identifier }
//        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifierToFetch, representations))
//        var plantsToCreate = representationsByID
//        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
//        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identifierToFetch)
//
//        let context = CoreDataManager.shared.container.newBackgroundContext()
//        var error: Error?
//        if AuthService.activeUser != nil {
//            context.performAndWait {
//                let existingPlants = try context.fetch(fetchRequest)
//                for plant in existingPlants {
//                    guard let identifier = plant.identifier,
//                        let representation = representationsByID[identifier] else { continue }
//                    self.updatePlantRep(plant: plants, with: representation)
//                    plantsToCreate.removeValue(forKey: identifier)
//                }
//            }; catch {
//                if let error = error {
//                    print("Error updating Plants: \(error)")
//                }
//            }
//            for representation in plantsToCreate.values {
//                guard let userRep = AuthService.activeUser else { continue }
//                Plant(plantRepresentation: representation, context: context, userRepresentation: userRep)
//            }
//            if let error = error { throw error }
//            try CoreDataManager.shared.save(context: context)
//        }
//
//    }
////
//    func syncPlantsWithFirebase(identifiersOnServer: Int, context: NSManagedObjectContext) {
//           guard let identifier = AuthService.activeUser?.identifier else { return }
//           let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
//           fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier as CVarArg)
//
//           do {
//               let existingPlants = try context.fetch(fetchRequest)
//               for plant in existingPlants {
//               let plantID = plant.id
//                   if !identifiersOnServer.contains(plantID) {
//                       context.delete(plant)
//                   }
//               }
//           } catch {
//               print("Error fetching all Todos in \(#function)")
//           }
//
//       }
    
    private func updatePlantRep(plant: Plant, with representation: PlantRepresentation) {
        plant.id = Int16(representation.identifier)
        plant.nickname = representation.nickname
        plant.species = representation.species
        plant.userID = representation.userID
        plant.h2oFrequency = representation.h2oFrequency
        plant.imageURL = representation.imageURL
    }
}
