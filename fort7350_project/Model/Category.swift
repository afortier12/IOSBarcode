//
//  Category.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-02.
//

import Foundation
import CoreData

class Category: NSManagedObject, Codable {

    private enum CodingKeys: String, CodingKey {
        case name
    }
    
    
    required convenience init(from decoder:Decoder) throws {
        guard let codingKeyManagedObjectContext = CodingUserInfoKey.managedObjectContext,
              let managedObjectContext = decoder.userInfo[codingKeyManagedObjectContext] as? NSManagedObjectContext,
              let entity = NSEntityDescription.entity(forEntityName: "Category", in: managedObjectContext)
        else {
            fatalError("Failed to decode Location")
        }

        self.init(entity: entity, insertInto: managedObjectContext)
        
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)

    }
    
    // MARK: - Encodable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        
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
            _ = try decoder.decode([Category].self, from: jsonData)
            try managedObjectContext.save()

            return true
        } catch let error {
            print(error)
            return false
        }
    }

  /*  class func addCategory(name: String){
        let context = AppDelegate.viewContext
        if !Category.categoryExists(with: name) {
            print("---Category--adding new category------")
            let category = Category(context: context)
            category.set(name: name)
        }
        
    } //  addCategory

    class func categoryExists(with name:String) -> Bool {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format:  "name = %@", name)
        let context = AppDelegate.viewContext
        let category = try? context.fetch(request)
        if (category?.isEmpty)! {
            return false
        } else {
            return true
        }
    }
    
    class func addCategories(_ categories: [CategoryCodable]) {
        let context = AppDelegate.viewContext
        for category in categories {
            if !Category.categoryExists(with: category.name) {
                print("---Category--adding new category------")
                let categoryModel = Category(context: context)
                categoryModel.set(name: category.name)
                do {
                    try context.save()
                } catch {
                    print("Falied saving")
                }
                
            }
        }
        
        
    }
    
    func set(name: String) {
        self.name = name
    }
 */
 }
