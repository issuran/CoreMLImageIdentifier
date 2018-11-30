//
//  SmartCameraViewController.swift
//  SmartCamera
//
//  Created by Tiago Oliveira on 29/11/18.
//  Copyright © 2018 Optimize 7. All rights reserved.
//

import UIKit
import AVKit
import Vision

class SmartCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a capture session
        let captureSession = AVCaptureSession()
        
        guard let captureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else {
            return
        }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        // Display camera preview on screen
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        // Monitor everytime a frame is capture by the camera
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    // Identify object using Vision
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        // Model not that inteligent
//        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else {
//            return
//        }
        
        // Model smarter one
        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
            return
        }
        
        let request = VNCoreMLRequest(model: model) { (finishedReq, err) in
            
            // result
            guard let results = finishedReq.results as? [VNClassificationObservation] else {
                return
            }
            
            guard let firstObservation = results.first else {
                return
            }
            
            print(firstObservation.identifier, firstObservation.confidence)
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}

