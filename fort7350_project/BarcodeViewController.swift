//
//  BarcodeViewController.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-18.
//

import UIKit
import AVFoundation

class BarcodeViewController: UIViewController, CameraDelegate, ScannerDelegate {

    private var camera: Camera?
    private var scanner: Scanner?
    
    private var bufferDelegate:AVCaptureVideoDataOutputSampleBufferDelegate?
    private var unwindSegue:String = "unwindAddPart"
    private var detailSegue:String = "ScanShow"
    var barcode: String?
    var addBarcode: Bool?
    var processed: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.camera = Camera(withDelegate: self)
        self.scanner = Scanner(withDelegate: self)
        guard let camera = self.camera else {
            return
        }
        
        self.bufferDelegate = self.scanner
        camera.setCameraOutput(withBuffer: self.bufferDelegate!)
        camera.requestCaptureSessionStartRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camera?.requestCaptureSessionStopRunning()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Mark - Camera delegate methods
    func cameraView() -> UIView
    {
       return self.view
    }

    func cameraViewController() -> UIViewController
    {
       return self
    }
    
    // Mark - Scanner delegate methods

    func scannerViewController() -> UIViewController
    {
       return self
    }
    
    func processBarcode(barcode: String) {
      
        if processed { return }
        self.barcode = barcode
        let alertController = UIAlertController(title: "Barcode Found", message: "Use barcode with value:\n\(barcode)", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            self.processed = true
            if let _ = self.addBarcode {
                self.performSegue(withIdentifier: self.unwindSegue, sender: self.barcode)
            } else {
                if let part = Part.getPartWithBarcode(with: barcode) {
                    self.performSegue(withIdentifier: self.detailSegue, sender: part)
                } else {
                    self.showAlert(withTitle: "No Part Found!", message: "Part with this barcode not found. Go to part list to add.")
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            self.processed = true
            if let _ = self.addBarcode {
                self.performSegue(withIdentifier: self.unwindSegue, sender: nil)
            } else {
                self.processed = false
            }
        }

        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
        
    }
    
    func getBarcode() -> String{
         return barcode ?? ""
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == detailSegue {
            if let navigationController = segue.destination as? UINavigationController, let partVC = navigationController.viewControllers.first as? PartViewController {
            partVC.navigationItem.hidesBackButton = true
            //invoke funtion in the destination view controller to pass data
            partVC.initWithPart(part:sender as! Part)
            }
        }
    }
    
}


