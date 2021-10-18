//
//  TableViewController.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-02.
//

import UIKit
import CoreData

class TableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var partImage: UIImageView!
    @IBOutlet weak var manufacturerLabel: UILabel!
    @IBOutlet weak var partNumberLabel: UILabel!
    @IBOutlet weak var qtyLabel: UILabel!
    
}
class PartsTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate{
         var segueID = "ShowPart"

    @IBOutlet weak var searchBar: UISearchBar!
    //MARK:  -FetchedResult
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!

    func initializeFetchedResultsController(_ text: String = "") {
        let request : NSFetchRequest<Part> = Part.fetchRequest()
        let fetchSort = NSSortDescriptor(key: "manufacturer", ascending: true)
        request.sortDescriptors = [fetchSort]
        
        if text != "" {
            let predicate = NSPredicate(format:  "name contains[c] '\(text)'")
            request.predicate = predicate
        }
        let context = AppDelegate.viewContext
        fetchedResultsController = (NSFetchedResultsController(
                                        fetchRequest: request,
                                        managedObjectContext: context,
                                        sectionNameKeyPath: nil,
                                        cacheName: nil) as! NSFetchedResultsController<NSFetchRequestResult>)

        fetchedResultsController.delegate = self
        do {
             try fetchedResultsController.performFetch()
        } catch {
             fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        initializeFetchedResultsController()
        
        //let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Tap(_:)))
        //view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fetchedResultsController?.sections?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
             return sections[section].numberOfObjects
        } else {
             return 0
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    
        tableView.deselectRow(at: indexPath, animated: true)
        let part = fetchedResultsController.object(at: indexPath) as! Part
        performSegue(withIdentifier: segueID, sender: part)
    
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> TableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier") as! TableViewCell
        let obj = fetchedResultsController.object(at: indexPath) as! Part
        cell.manufacturerLabel?.text = obj.manufacturer
        cell.partNumberLabel?.text = obj.partNumber
        if let imgData = obj.image {
            cell.partImage.image = UIImage(data: imgData)
        }
        cell.qtyLabel?.text = String(obj.quantity)
            
        return cell
    }
    
    //Delete from core data
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let context = AppDelegate.viewContext
        switch editingStyle {
        case .delete:
            let part = fetchedResultsController.object(at: indexPath) as! Part
            context.delete(part)
            do {
                try context.save()
            } catch let error as NSError {
                print("Error saving context after delete: \(error.localizedDescription)")
            }
        default:
            break
        }
    }
    
    //  MARK: - FetchedResultsController Delegate
             
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
          tableView.beginUpdates()
    }
          
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
          tableView.endUpdates()
    }

    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo,  atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
          // 1
          switch type {
          case .insert:
             tableView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .automatic)
          case .delete:
             tableView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet, with: .automatic)
          default: break
          }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
       // 2
          switch type {
          case .insert:
             tableView.insertRows(at: [newIndexPath!],  with: .automatic)
          case .delete:
             tableView.deleteRows(at: [indexPath!], with: .automatic)
          default: break
          }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            initializeFetchedResultsController(searchText)
            tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)  {
        searchBar.resignFirstResponder()
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
   
    @objc func Tap(_ sender: UITapGestureRecognizer) {
        self.searchBar.endEditing(true)
    }
    
    // MARK: - Navigation
    @IBAction func unwindToPartList(_ sender: UIStoryboardSegue){
       
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == segueID {
            //segue to the detail (destination) view controller
            if let navigationController = segue.destination as? UINavigationController, let partVC = navigationController.viewControllers.first as? PartViewController {
            
            //invoke funtion in the destination view controller to pass data
            partVC.initWithPart(part:sender as! Part)
            }
        }
    }

}
