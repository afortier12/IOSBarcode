//
//  Scanner.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-18.
//

import Foundation
import Vision
import AVFoundation
import UIKit

protocol ScannerDelegate : class {
    func scannerViewController() -> UIViewController
    func processBarcode(barcode: String)
}
class Scanner : NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    public weak var delegate:ScannerDelegate?
    
    
    lazy var detectBarcodeRequest = VNDetectBarcodesRequest { request, error in
      guard error == nil else {
        guard let delegate = self.delegate else {
            return
        }
        delegate.scannerViewController().showAlert(
          withTitle: "Barcode error",
          message: error?.localizedDescription ?? "error")
        return
      }
        self.processClassification(request)
    }
    
    init(withDelegate delegate: ScannerDelegate){
        self.delegate = delegate
       
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // 1
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        // 2
        let imageRequestHandler = VNImageRequestHandler(
         cvPixelBuffer: pixelBuffer,
         orientation: .right)

        // 3
        do {
         try imageRequestHandler.perform([detectBarcodeRequest])
        } catch {
         print(error)
        }

    }
    
    private func processClassification(_ request: VNRequest) {
      // 1
      guard let barcodes = request.results else { return }
      DispatchQueue.main.async {

          for barcode in barcodes {
            guard
                let potentialBarcode = barcode as? VNBarcodeObservation,
                potentialBarcode.confidence > 0.5
            else { return }

            self.delegate?.processBarcode(barcode: potentialBarcode.payloadStringValue ?? "")

          }
      }
    }
}
