//
//  Bin.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-13.
//

import UIKit
import CoreData

class Bin: NSManagedObject, Codable {

    private enum CodingKeys: String, CodingKey {
        case bin

    }
    
    required convenience init(from decoder:Decoder) throws {
        guard let codingKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
              let managedObjectContext = decoder.userInfo[codingKeyManagedObjectContext] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "Bin", in: managedObjectContext)
        else {
            fatalError("Failed to decode Location")
        }

        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        bin = try container.decode(Int32.self, forKey: .bin)
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
       var container = encoder.container(keyedBy: CodingKeys.self)
       try container.encode(bin, forKey: .bin)
    }

    // Get the bin for a specific part
    func getBin(bin: Int32) -> Bin?{
        let request : NSFetchRequest<Bin> = Bin.fetchRequest()
        let predicate = NSPredicate(format: "bin == %@", bin)
        request.predicate = predicate
        let context = AppDelegate.viewContext
        let bins = try? context.fetch(request)
        for bin in bins!{
            return bin
        }
        return nil
    }// getShelf
}
