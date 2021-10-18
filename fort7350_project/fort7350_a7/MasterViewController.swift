//
//  MasterViewController.swift
//  fort7350_a7
//
//  Created by Adam Fortier on 2021-04-10.
//

import UIKit


class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
}

class MasterViewController: UITableViewController, UITabBarDelegate {
    
    var deck: Deck?
    let tableIdentifier = "table_identifier"
    let cellIdentifier = "reuseIdentifier"
    let segueID = "ShowDetail"
    
    var detailViewController: DetailViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        _ = SharingDeck() // get the Singleton instance

        do{
            try SharingDeck.sharedDeck.loadDeck() //un-archive data
            deck = SharingDeck.sharedDeck.getDeck()
        } catch {
            print("failed to load deck")
        }
        
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    
    

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return deck?.getSize() ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell
        if (cell == nil){
            cell = TableViewCell(style: UITableViewCell.CellStyle.default,
                                   reuseIdentifier: cellIdentifier)
        }
        
        deck?.setCurrentIndex(to: indexPath.row)
        //set the cell image
        cell?.photoImageView.image = deck?.card()?.getImage()
            
        //set the cell text
        cell?.questionLabel.text = deck?.card()?.getQuestion()
        
        return cell!
    }
    
    /*override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
    
        tableView.deselectRow(at: indexPath, animated: true)
        deck?.setCurrentIndex(to: indexPath.row)
        performSegue(withIdentifier: segueID, sender: deck?.card())
    
    }*/
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data sour
            deck?.deleteCardAtIndex(index: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    

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

    
    // MARK: - Navigation
    
    @IBAction func unwindToDeck(_ sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? AddViewController{
            let card = sourceViewController.getCard()
            let newIndexPath = IndexPath(row: (deck?.getSize())!, section: 0)
            deck?.addCard(card: card!)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == segueID {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                deck?.setCurrentIndex(to: indexPath.row)
                controller.initWithCard(card: (deck?.card())!)
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
             }            //segue to the detail (destination) view controller
        }
    }
    

}
