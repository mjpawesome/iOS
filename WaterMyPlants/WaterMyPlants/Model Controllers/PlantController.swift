//
//  PlantController.swift
//  WaterMyPlants
//
//  Created by Joe Veverka on 6/21/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation

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
                try self.updateTodos(with: unwrappedReps ?? [])
                completion(.success(true))
            } catch {
                completion(.failure(.otherError))
                NSLog("Error updating todos: \(error)")
            }
            
        }
        
    }
}
