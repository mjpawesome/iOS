//
//  PlantController.swift
//  WaterMyPlants
//
//  Created by Joe Veverka on 6/21/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation
import CoreData

enum NetworkError2: Error {
    case noIdentifier
    case otherError
    case noData
    case noDecode
    case noEncode
    case noRep
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}
enum NetworkError: Error {
    case failedSignUp, failedLogIn, noData, badData, noID
    case notSignedIn, failedFetch, failedPost
}

typealias CompletionHandler = (Result<Bool, NetworkError>) -> Void

class PlantController {
    
    // MARK: - Properties
    private let networkService = NetworkService()
    var plants: [Plant] = []
    
    /// persists the bearer after writing to it
    static var bearer: Bearer? {
        didSet {
            if let bearer = bearer {
                UserDefaults.standard.setValue(bearer.token, forKey: "token")
                UserDefaults.standard.setValue(bearer.userID, forKey: "userId")
            } else {
                print("bearer was set to nil")
            }
        }
    }
    
    /// reads the persisted bearer
    static var getBearer: Bearer? {
        get {
            let token = UserDefaults.standard.value(forKey: "token") as? String
            let userId = UserDefaults.standard.value(forKey: "userId") as? Int
            guard let tempToken = token, let tempUserId = userId else {
                return nil
            }
            return Bearer(welcome: "username goes here if using", userID: tempUserId, token: tempToken)
        }
    }
    
    private lazy var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        //        decoder.dateDecodingStrategy = .iso8601 <-- not needed?
        return decoder
    }()
    
    // MARK: - URLs
    
    private let baseURL: URL = URL(string: "https://water-my-plants-buildweek.herokuapp.com/api")!
    private lazy var signUpURL: URL = baseURL.appendingPathComponent("/auth/register")
    private lazy var logInURL: URL = baseURL.appendingPathComponent("/auth/login")
    private lazy var allPlantsURL: URL = baseURL.appendingPathComponent("/auth/plants")
    
    //MARK: - Authentication Method: Sign Up
    
    func signUp(for user: UserRepresentation, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        
        var request = postRequest(with: signUpURL)
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { _, response, error in
                
                if let error = error {
                    print("Sign up failed with error: \(error.localizedDescription)")
                    return completion(.failure(.failedSignUp))
                }
                
                guard let response = response as? HTTPURLResponse, response.statusCode == 201
                    else {
                        print("Sign up was unsuccessful.")
                        return completion(.failure(.failedSignUp))
                }
                
                completion(.success(true))
            }
                
            .resume()
            
        } catch {
            
            print("Error encoding user: \(error.localizedDescription)")
            completion(.failure(.failedSignUp))
        }
    }
    
    //MARK: - Authentication Method: Sign In
    
    func logIn(for user: UserRepresentation, completion: @escaping (Result<Bool, NetworkError>) -> Void) {
        var request = postRequest(with: logInURL)
        
        do {
            let jsonData = try jsonEncoder.encode(user)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Log in failed with error: \(error.localizedDescription)")
                    return
                }
                if let response = response as? HTTPURLResponse { print(response.statusCode) }
                guard let response = response as? HTTPURLResponse, response.statusCode == 200
                    
                    else {
                        print("Log in was unsuccessful.")
                        return completion(.failure(.failedLogIn))
                }
                guard let data = data else {
                    print("No data was returned.")
                    return completion(.failure(.noData))
                }
                
                do {
                    print(data)
                    Self.bearer = try self.jsonDecoder.decode(Bearer.self, from: data)
                    completion(.success(true))
                    
                } catch {
                    
                    print("Error decoding bearer: \(error.localizedDescription)")
                    completion(.failure(.failedLogIn))
                }
            }  .resume()
            
        } catch {
            
            print("Error encoding user: \(error.localizedDescription)")
            completion(.failure(.failedLogIn))
        }
    }
    
    // MARK: - Create Method: Add Plant to Server
    
    func sendPlantToServer(plant: Plant, completion: @escaping CompletionHandler = { _ in }) {
        guard let bearer = PlantController.getBearer?.token else { return }
        guard let identity = PlantController.getBearer?.userID else { return }

        let requestURL = baseURL.appendingPathComponent("users/\(identity)/plants")

        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(bearer, forHTTPHeaderField: "Authorization")
                
        do {
            guard let plantRep = plant.plantRepresentation else {
                completion(.failure(.noData))
                return
            }
            request.httpBody = try JSONEncoder().encode(plantRep)
        } catch {
            NSLog("Error encoding plant \(plant): \(error.localizedDescription)")
            completion(.failure(.noData))
            return
        }
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                NSLog("Error sending plant to server \(plant): \(error.localizedDescription)")
                completion(.failure(.failedPost))
                return
            }
            if let data = data {
                print(PlantController.getBearer?.token)
                print(data.prettyPrintedJSONString)
                do {
                    let plantRepresentations = try JSONDecoder().decode(PlantRepresentation.self, from: data)
                    let plantID = plantRepresentations.plantID
                    plant.id = Int16(plantID)
                } catch {
                    print("Error decoding plant representation: \(error)")
                    completion(.failure(.noData))
                    return
                }
            }
            try! CoreDataManager.shared.mainContext.save()
            completion(.success(true))
            print("Saved a plant")
            
        }.resume()
    }
    
    // MARK: - Read Method: Fetch Plants From Server
    
    func fetchPlantsFromServer(completion: @escaping CompletionHandler = { _ in }) {
        guard let bearer = PlantController.getBearer?.token else { return }
        guard let userID = PlantController.getBearer?.userID else { return }
        
        let requestURL = baseURL.appendingPathComponent("users/\(userID)/plants")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.get.rawValue
        request.addValue(bearer, forHTTPHeaderField: "Authorization")

        print(request)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("Error fetching plants: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from server (fetching entries).")
                completion(.failure(.noData))
                return
            }
            
            do {
                let plantRepresentations = try JSONDecoder().decode([PlantRepresentation].self, from: data)
//                let plantRepresentations = Array(arrayLiteral: try self.jsonDecoder.decode(PlantRepresentation.self, from: data))
                try self.updatePlantsWithServer(with: plantRepresentations)
            } catch {
                print("Error decoding plant representation: \(error)")
                completion(.failure(.noData))
                return
            }
        }.resume()
    }
    
    //MARK: - Delete Method
    
    private func deletePlantFromServer(plant: Plant, completion: @escaping CompletionHandler = { _ in }) {
        //FIXME: Need to make .id optional in order to guard here or other safety check.
        let identifier = plant.id
        let requestURL = baseURL.appendingPathComponent("plants/\(identifier)").appendingPathExtension("json")
        var request = URLRequest(url: requestURL)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                NSLog("Error deleting plant from server: \(error)")
                completion(.failure(.noData))
                return
            }
            completion(.success(true))
        }.resume()
    }
    
    func delete(plant: Plant) {
        deletePlantFromServer(plant: plant)
        CoreDataManager.shared.mainContext.delete(plant)
        print("tried to delete plant.  need error checking for coredata.")
    }
    
    // MARK: - Update Method
    
    func updatePlantsWithServer(with representations: [PlantRepresentation]) throws {
        let identifiersToFetch = representations.compactMap { $0.plantID }
        let representationsByID = Dictionary(uniqueKeysWithValues: zip(identifiersToFetch, representations))
        var plantsToCreate = representationsByID
        // create fetch request
        let fetchRequest: NSFetchRequest<Plant> = Plant.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", identifiersToFetch)
        let context = CoreDataManager.shared.mainContext
        do {
            let existingPlants = try context.fetch(fetchRequest) // fetch
            for plant in existingPlants {
                let id = Int(plant.id)
                guard let representation = representationsByID[id] else { continue }
                self.updatePlantRep(plant: plant, with: representation)
                plantsToCreate.removeValue(forKey: id)
            }
            for representation in plantsToCreate.values {
                Plant(plantRepresentation: representation, context: context)
            }
        } catch {
            NSLog("Error fetching plants with plant ID's: \(identifiersToFetch), with error: \(error)")
        }
        try CoreDataManager.shared.mainContext.save()
    }
    
    private func postRequest(with url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    private func updatePlantRep(plant: Plant, with representation: PlantRepresentation) {
        plant.id = Int16(representation.plantID)
        plant.nickname = representation.nickname
        plant.species = representation.species
        plant.userID = representation.user
        plant.h2oFrequency = representation.h2oFrequency
        plant.img_url = representation.img_url
    }
    
    private func plantHandler(with url: URL, with bearer: Bearer, requestType: HTTPMethod) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = requestType.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(bearer.token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}
