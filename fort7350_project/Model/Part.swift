//
//  Part.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-02.
//

import UIKit
import CoreData

class Part: NSManagedObject, Codable {
    
    private enum CodingKeys: String, CodingKey {
        case partNumber
        case name
        case manufacturer
        case barcode
        case image
        case quantity
        case bin
        case category
        case location
        case shelf
    }
    
    
    required convenience init(from decoder:Decoder) throws {
        guard let codingKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
              let managedObjectContext = decoder.userInfo[codingKeyManagedObjectContext] as? NSManagedObjectContext,
            let entity = NSEntityDescription.entity(forEntityName: "Part", in: managedObjectContext) else {
            fatalError("Failed to decode Part")
        }

        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        partNumber = try container.decode(String.self, forKey: .partNumber)
        name = try container.decode(String.self, forKey: .name)
        manufacturer = try container.decode(String.self, forKey: .manufacturer)
        barcode = try container.decode(String.self, forKey: .barcode)
        image = try container.decode(Data.self, forKey: .image)
        quantity = try container.decode(Int16.self, forKey: .quantity)
        bin = try container.decode(Bin.self, forKey: .bin)
        category = try container.decode(Category.self, forKey: .category)
        location = try container.decode(Location.self, forKey: .location)
        shelf = try container.decode(Shelf.self, forKey: .shelf)

    
    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(partNumber, forKey: .partNumber)
        try container.encode(name, forKey: .name)
        try container.encode(manufacturer, forKey: .manufacturer)
        try container.encode(barcode, forKey: .barcode)
        try container.encode(image, forKey: .image)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(bin, forKey: .bin)
        try container.encode(category, forKey: .category)
        try container.encode(location, forKey: .location)
        try container.encode(shelf, forKey: .shelf)

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
            _ = try decoder.decode([Part].self, from: jsonData)
            try managedObjectContext.save()

            return true
        } catch let error {
            print(error)
            return false
        }
    }
    
    
    
    class func addPart(name: String, manufacturer:String, partNumber:String, image: Data , quantity: Int16, barcode: String, plant: String, unit: String, shelf: String, bin: Int, category: String) {
        let context = AppDelegate.viewContext
        if !Part.partExists(with: partNumber) {
            print("---Part--adding new part------")
            let part = Part(context: context)
            part.set(name: name, manufacturer: manufacturer, partNumber: partNumber, image: image , quantity: quantity, barcode: barcode, plant: plant, unit: unit, shelf: shelf, bin: bin, category: category)
            do {
                try context.save()
            } catch {
                print("Falied saving")
            }
        }
        
    } //  addPart

    class func partExists(with partNumber:String) -> Bool {
        let request : NSFetchRequest<Part> = Part.fetchRequest()
        request.predicate = NSPredicate(format:  "partNumber = %@", partNumber)
        let context = AppDelegate.viewContext
        let part = try? context.fetch(request)
        if (part?.isEmpty)! {
            return false
        } else {
            return true
        }
    }
    
    // Get the parts
    class func getAllParts() -> [Part?]{
        let request : NSFetchRequest<Part> = Part.fetchRequest()
        let context = AppDelegate.viewContext

        let parts = try? context.fetch(request)
        return parts!
    }// getAllParts
    
    
    class func getPartWithBarcode(with barcode:String) -> Part? {
        let request : NSFetchRequest<Part> = Part.fetchRequest()
        request.predicate = NSPredicate(format:  "barcode = %@", barcode)
        let context = AppDelegate.viewContext
        let parts = try? context.fetch(request)
        if (parts?.isEmpty)! {
            return nil
        } else {
            return parts![0]
        }
    }

    func set(name: String, manufacturer: String, partNumber: String, image: Data , quantity: Int16, barcode: String, plant: String, unit: String, shelf: String, bin: Int, category: String){
        self.name = name
        self.manufacturer = manufacturer
        self.partNumber = partNumber
        self.quantity = quantity
        self.barcode = barcode
        self.location = getLocation(plant: plant, storageUnit: unit)
        self.shelf = getShelf(shelf: shelf)
        self.bin = getBin(bin: Int32(bin))
        self.image = image
        self.category = getCategory(categoryName: category)
    }
    
    // Get the part location
    func getLocation(plant: String, storageUnit: String) -> Location?{
        let request : NSFetchRequest<Location> = Location.fetchRequest()
        let predicate = NSPredicate(format: "plant == %@ AND storageUnit == %@", plant, storageUnit)
        request.predicate = predicate
        let context = AppDelegate.viewContext

        let locations = try? context.fetch(request)
        for location in locations!{
            return location
        }
        return nil
    }// getLocation
    
    
    // Get the shelf
    func getShelf(shelf:String) -> Shelf?{
        let request : NSFetchRequest<Shelf> = Shelf.fetchRequest()
        let predicate = NSPredicate(format: "name == %@", shelf)
        request.predicate = predicate
        let context = AppDelegate.viewContext

        let shelves = try? context.fetch(request)
        for shelf in shelves!{
            return shelf
        }
        return nil
    }// getLocation
    
    // Get the bin
    func getBin(bin:Int32) -> Bin?{
        let request : NSFetchRequest<Bin> = Bin.fetchRequest()
        let predicate = NSPredicate(format: "bin == %i   ", bin)
        request.predicate = predicate
        let context = AppDelegate.viewContext

        let bins = try? context.fetch(request)
        for bin in bins!{
            return bin
        }
        return nil
    }// getBin
    
    
    // Get the part category
    func getCategory(categoryName: String) -> Category? {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name = %@", categoryName)

        // direct way to get the context
        let container = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
        let context: NSManagedObjectContext = container.viewContext

        let category = try? context.fetch(request)
        if (category?.isEmpty)! {
             return nil
        } else {
             return category![0] as Category
        }
    }//  getCategory

    
}
