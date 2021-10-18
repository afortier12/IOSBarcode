//
//  DetailViewController.swift
//  fort7350_a7
//
//  Created by Adam Fortier on 2021-04-10.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var navItem: UINavigationItem!
    private var card: Card?
    
    func initWithCard(card: Card) {
        self.card = card
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navItem.title = card?.getQuestion()
        answerLabel.text = card?.getAnswer()
        photoImageView.image = card?.getImage()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
