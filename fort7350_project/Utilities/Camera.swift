//
//  Camera.swift
//  fort7350_project
//
//  Created by Adam Fortier on 2021-04-18.
//

import Foundation
import AVFoundation
import UIKit


protocol CameraDelegate : class {
    func cameraView() -> UIView
    func cameraViewController() -> UIViewController
}


class Camera {
    
    public weak var delegate:CameraDelegate?
    var captureSession = AVCaptureSession()
    
    init(withDelegate delegate: CameraDelegate)
    {
        self.delegate = delegate
        self.cameraSetup()

    }
    
    private func cameraSetup() {
        
        guard let delegate = self.delegate else {
            return
        }
        let viewController = delegate.cameraViewController()
        let cameraView = delegate.cameraView()
        
        if self.checkPermissions(viewController: viewController) {
            captureSession.sessionPreset = .hd1280x720
            let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            guard
                let device = videoDevice,
                let videoDeviceInput = try? AVCaptureDeviceInput(device: device), captureSession.canAddInput(videoDeviceInput)
            else {
                viewController.showAlert(withTitle: "Cannot Find Camera", message: "There seems to be a problem with the camera on your device.")
                return
            }
            
            captureSession.addInput(videoDeviceInput)
            
            configurePreviewLayer(cameraView: cameraView)
            
        }
    }
    
    public func setCameraOutput(withBuffer: AVCaptureVideoDataOutputSampleBufferDelegate)  {
        let captureOutput = AVCaptureVideoDataOutput()
        captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        captureOutput.setSampleBufferDelegate(withBuffer, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        captureSession.addOutput(captureOutput)
        
    }

    private func checkPermissions(viewController: UIViewController) ->  Bool{
      
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        // 1
        case .notDetermined:
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                viewController.showPermissionsAlert()

            }
        }
        return false

        // 2
        case .denied, .restricted:
            viewController.showPermissionsAlert()
            return false

        // 3
        default:
            return true
        }
    }
      
    private func configurePreviewLayer(cameraView: UIView) {
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.videoGravity = .resizeAspectFill
        cameraPreviewLayer.connection?.videoOrientation = .portrait
        cameraPreviewLayer.frame = cameraView.frame
        cameraView.layer.insertSublayer(cameraPreviewLayer, at: 0)
    }
    
    public func requestCaptureSessionStartRunning()
       {
           self.toggleCaptureSessionRunningState()
       }
       
       public func requestCaptureSessionStopRunning()
       {
           self.toggleCaptureSessionRunningState()
       }
       
       private func toggleCaptureSessionRunningState() {
           
           if !captureSession.isRunning
           {
               captureSession.startRunning()
           }
           else
           {
               captureSession.stopRunning()
           }
       }
}


