//
//  UtilitiesViewController.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-23.
//

import UIKit
import MobileCoreServices

class UtilitiesViewController: UIViewController, CoreDataFileDelegate {
    
    var filePicker: CoreDataFilePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        filePicker = CoreDataFilePicker(presentationController: self, delegate: self)
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func importCategories(_ sender: Any) {
        filePicker.present(from: view, sourceType: .category)
    }
    
    
    @IBAction func importLocations(_ sender: Any) {
        filePicker.present(from: view, sourceType: .location)
    }
    
    @IBAction func importParts(_ sender: Any) {
        filePicker.present(from: view, sourceType: .parts)
    }
    
    @IBAction func exportParts(_ sender: Any) {
        filePicker.presentExport(from: view, sourceType: .parts)
    }
    
    
    func selectFileResult(filename: String, result: Bool, source: SourceType) {
        print(filename)
    }
    
}
