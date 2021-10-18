//
//  PartViewController.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-02.
//

import UIKit

class PartViewController: UIViewController {
    
    @IBOutlet weak var partValue: UILabel!
    @IBOutlet weak var manufacturerValue: UILabel!
    @IBOutlet weak var locationValue: UILabel!
    @IBOutlet weak var qtyValue: UILabel!
    @IBOutlet weak var numberValue: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    private var part: Part?
    
    func initWithPart(part: Part) {
        self.part = part
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        partValue.text = part?.name
        numberValue.text = part?.partNumber
        manufacturerValue.text = part?.manufacturer
        
        let plant:String = (part?.location?.plant)!
        let unit:String = (part?.location?.storageUnit)!
        let shelfName:String = (part?.shelf?.name)!
        let binName:String = String((part?.bin?.bin)!)
        locationValue.text = plant + " / " + unit + " / " + shelfName + " / " + binName
        qtyValue.text = String(part!.quantity)
        photoImageView.image = UIImage(data:(part?.image)!,scale:1.0)         // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
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
