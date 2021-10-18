//
//  DocumentPicker.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-25.
//

import UIKit
import CoreData

public enum SourceType: Int {
    case category
    case location
    case parts
}


protocol CoreDataFileDelegate: class {
    func selectFileResult(filename: String, result: Bool, source: SourceType)
}


class CoreDataFilePicker: NSObject {

    private var pickerController: UIDocumentPickerViewController?
    private weak var presentationController: UIViewController?
    private weak var delegate: CoreDataFileDelegate?
    
    private var sourceType: SourceType!
    
    init(presentationController: UIViewController, delegate: CoreDataFileDelegate) {
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
    }
    
    public func present(from sourceView: UIView, sourceType: SourceType){

        self.pickerController = UIDocumentPickerViewController(documentTypes: ["public.json"], in: .import)
        self.pickerController!.delegate = self
        self.pickerController!.allowsMultipleSelection = true
        self.sourceType = sourceType
        self.presentationController?.present(self.pickerController!, animated: true)
    }
    
    public func presentExport(from sourceView: UIView, sourceType: SourceType){
           
        let encoder = JSONEncoder()
        let parts = Part.getAllParts()

        if let encodedData = try? encoder.encode(parts) {
          
            let filename = "parts.json"
            guard let exportURL = FileManager.default
                   .urls(for: .documentDirectory, in: .userDomainMask)
                   .first?.appendingPathComponent(filename) else { return }

            try? encodedData.write(to: exportURL)

            self.pickerController = UIDocumentPickerViewController(url: exportURL, in: UIDocumentPickerMode.exportToService)
            self.pickerController!.delegate = self
            self.pickerController!.allowsMultipleSelection = true
            self.sourceType = sourceType
            self.presentationController?.present(self.pickerController!, animated: true)
        }
        
    }
    
    func readCategories(url: URL){
        
        let context = AppDelegate.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Category")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
        } catch {
            print("failed to delete")
        }
        do {
            let dataStore = try Data(contentsOf: url)
            let results = NSString(data: dataStore as Data, encoding: String.Encoding.utf8.rawValue)
            print(" the result file content is ")
            print(results!)
            let fileName = (url.path as NSString).lastPathComponent
            
            if Category.parse(dataStore) {
                print("categories saved")
                self.presentationController?.showAlert(withTitle: "Import", message: "Import Successful")
                saveToDocuments(data: dataStore, withFileName: fileName)
                self.delegate?.selectFileResult(filename: fileName, result: true, source: .category)
            } else {
                print("error saving categories")
                self.presentationController?.showAlert(withTitle: "Import", message: "Import Failed")
                self.delegate?.selectFileResult(filename: fileName, result: false, source: .category)
            }
            
        } catch {
            print("error:\(error)")
        }
        
    }
    
    func readLocations(url: URL){
        
        let context = AppDelegate.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Location")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
        } catch {
            print("failed to delete")
        }
        let shelfRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Shelf")
        let deleteShelfRequest = NSBatchDeleteRequest(fetchRequest: shelfRequest)
        do {
            try context.execute(deleteShelfRequest)
        } catch {
            print("failed to delete")
        }
        let binRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Bin")
        let deleteBinRequest = NSBatchDeleteRequest(fetchRequest: binRequest)
        do {
            try context.execute(deleteBinRequest)
        } catch {
            print("failed to delete")
        }
            
        do {
            let dataStore = try Data(contentsOf: url)
            let results = NSString(data: dataStore as Data, encoding: String.Encoding.utf8.rawValue)
            print(" the result file content is ")
            print(results!)
            let fileName = (url.path as NSString).lastPathComponent
            
            if Location.parse(dataStore) {
                print("locations saved")
                self.presentationController?.showAlert(withTitle: "Import", message: "Import Successful")
                saveToDocuments(data: dataStore, withFileName: fileName)
                self.delegate?.selectFileResult(filename: url.path, result: true, source: .location)
                
            } else {
                print("error saving locations")
                self.presentationController?.showAlert(withTitle: "Import", message: "Import Failed")
                self.delegate?.selectFileResult(filename: url.path, result: true, source: .location)
                
            }
            
        } catch {
            print("error:\(error)")
        }

    }
    
    func readParts(url: URL){
        let context = AppDelegate.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Part")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try context.execute(deleteRequest)
        } catch {
            print("failed to delete")
        }

        do {
            let dataStore = try Data(contentsOf: url)
            let results = NSString(data: dataStore as Data, encoding: String.Encoding.utf8.rawValue)
            print(" the result file content is ")
            print(results!)
            let fileName = (url.path as NSString).lastPathComponent
            
            if Part.parse(dataStore) {
                print("categories saved")
                self.presentationController?.showAlert(withTitle: "Import", message: "Import Successful")
                saveToDocuments(data: dataStore, withFileName: fileName)
                self.delegate?.selectFileResult(filename: fileName, result: true, source: .category)
            } else {
                print("error saving categories")
                self.presentationController?.showAlert(withTitle: "Import", message: "Import Failed")
                self.delegate?.selectFileResult(filename: fileName, result: false, source: .category)
            }
            
        } catch {
            print("error:\(error)")
        }
    }
    
    
    func saveToDocuments(data: Data, withFileName fileName: String) {
        // Get a path in our document directory to temporarily store the data in
        guard let exportURL = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first?.appendingPathComponent(fileName) else { return }
        do{
            try data.write(to: exportURL)
        } catch {
            print("Error", error)

            return
        }
        print("Save successful")
            
    }

}
    
extension CoreDataFilePicker: UIDocumentPickerDelegate{
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            
        guard let url = urls.first else {
            return
        }
        if controller.documentPickerMode == .import || controller.documentPickerMode == .exportToService {
            switch self.sourceType {
            case .category:
                readCategories(url: url)
            case .location:
                readLocations(url: url)
            case .parts:
                readParts(url: url)
            default:
                return
            }
        }
        controller.dismiss(animated: true)
    }
        
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
    

}

extension CoreDataFilePicker: UINavigationControllerDelegate {}
