//
//  NetworkError.swift
//  WaterMyPlants
//
//  Created by Mark Poggi on 6/20/20.
//  Copyright © 2020 Shawn James. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case badAuth
    case noAuth
    case otherError
    case badData
    case noDecode
}
