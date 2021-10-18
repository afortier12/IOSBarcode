//
//  LocationData.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-11.
//

import Foundation

class ShelfCodable : Decodable {
    let name : String
    let bins: [Int32]?

    private enum CodingKeys: String, CodingKey {
        case name
        case bins
    }
    
    
    required init(from decoder:Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        bins = try container.decode([Int32].self, forKey: .bins)
        
    }
} // ShelfCodable

class LocationCodable: Decodable {
    let plant: String
    let storageUnit: String
    let shelves: [ShelfCodable]
    
    private enum CodingKeys: String, CodingKey {
        case plant
        case shelves
        case unit
    }
    
    required init(from decoder:Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        plant = try container.decode(String.self, forKey: .plant)
        storageUnit = try container.decode(String.self, forKey: .unit)
        shelves = try container.decode([ShelfCodable].self, forKey: .shelves)
    }
    
    
    
    
} //LocationCodable

