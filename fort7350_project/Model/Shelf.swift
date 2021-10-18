//
//  Shelf.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-11.
//

import UIKit
import CoreData

class Shelf: NSManagedObject, Codable{

    private enum CodingKeys: String, CodingKey {
        case name
        case bins
    }
    
    required convenience init(from decoder:Decoder) throws {
        guard let codingKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
              let managedObjectContext = decoder.userInfo[codingKeyManagedObjectContext] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "Shelf", in: managedObjectContext)
        else {
            fatalError("Failed to decode Location")
        }

        self.init(entity: entity, insertInto: managedObjectContext)

        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        do {
            bins = NSSet(array: try container.decode([Bin].self, forKey: .bins))
        } catch {
            print(error)
        }
        

    }
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        let binsArray = bins!.allObjects as? [Bin]
        try container.encode(binsArray, forKey: .bins)
    }
    
}
