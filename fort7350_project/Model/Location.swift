//
//  Location.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-02.
//

import UIKit
import CoreData


class Location: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case plant
        case shelves
        case unit
    }
    
    
    required convenience init(from decoder:Decoder) throws {
        guard let codingKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
              let managedObjectContext = decoder.userInfo[codingKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Location", in: managedObjectContext) else {
            fatalError("Failed to decode Location")
        }

        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        plant = try container.decode(String.self, forKey: .plant)
        storageUnit = try container.decode(String.self, forKey: .unit)
        do {
            shelves = NSSet(array: try container.decode([Shelf].self, forKey: .shelves))
        } catch {
            print("decoding error")
        }
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(plant, forKey: .plant)
        try container.encode(storageUnit, forKey: .unit)
        let shelvesArray = shelves!.allObjects as? [Shelf]
        try container.encode(shelvesArray, forKey: .shelves)
    }
    
    
    class func parse(_ jsonData: Data) -> Bool {
        do {
            guard let codingUserInfoKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext else {
                fatalError("Failed to retrieve context")
            }

            // Parse JSON data
            let managedObjectContext = AppDelegate.viewContext
            let decoder = JSONDecoder()
            decoder.userInfo[codingUserInfoKeyManagedObjectContext] = managedObjectContext
            _ = try decoder.decode([Location].self, from: jsonData)
            try managedObjectContext.save()

            return true
        } catch let error {
            print(error)
            return false
        }
    }
    

}

