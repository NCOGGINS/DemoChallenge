//
//  ViewController.swift
//  DemoChallenge
//
//  Created by Nathan Coggins on 4/2/20.
//  Copyright © 2020 Nathan Coggins. All rights reserved.
//

import UIKit
import AWSRekognition

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    var rekognitionObject:AWSRekognition?
    var imageSelection = 0
    var image1Selected = false
    var image2Selected = false
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    
    @IBAction func selectImage1(_ sender: Any) {
        imageSelection = 1
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true)
        {
            self.image1Selected = true
        }
    }
    
    @IBAction func selectImage2(_ sender: Any) {
        imageSelection = 2
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .photoLibrary
        image.allowsEditing = false
        self.present(image, animated: true)
        {
            self.image2Selected = true
        }
    }
    
    @IBAction func takeImage1(_ sender: Any) {
        imageSelection = 1
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .camera
        image.allowsEditing = false
        self.present(image, animated: true)
        {
            self.image1Selected = true
        }
    }
    
    @IBAction func takeImage2(_ sender: Any) {
        imageSelection = 2
        let image = UIImagePickerController()
        image.delegate = self
        image.sourceType = .camera
        image.allowsEditing = false
        self.present(image, animated: true)
        {
            self.image2Selected = true
        }
    }
    
    @IBAction func compareFaces(_ sender: Any) {
        CompareImages(Image1: (image1.image?.jpegData(compressionQuality: 0.2))!, Image2: (image2.image?.jpegData(compressionQuality: 0.2))!)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            if imageSelection == 1{
                image1.image = image
            } else if imageSelection == 2 {
                image2.image = image
            }
        } else {
            fatalError("Image could not be loaded.")
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func CompareImages(Image1: Data, Image2: Data){
        if image1Selected && image2Selected {
            rekognitionObject = AWSRekognition.default()
            let image1 = AWSRekognitionImage()
            image1?.bytes = Image1
            
            let image2 = AWSRekognitionImage()
            image2?.bytes = Image2
            
            let request = AWSRekognitionCompareFacesRequest()
            request?.sourceImage = image1
            request?.targetImage = image2
            request?.similarityThreshold = 0
            
            rekognitionObject?.compareFaces(request!){
                (result, error) in
                if error != nil {
                    print (error!)
                    return
                }
                if result != nil{
                    print (result!)
                    if (result!.faceMatches!.count > 0){
                        for(_, faces) in result!.faceMatches!.enumerated(){
                            DispatchQueue.main.async {
                                self.similarityResult(similarity: faces.similarity!.floatValue)
                            }
                        }
                    }
                    else {
                        print(0)
                    }
                }
            }
        }
        else {
            let alert = UIAlertController(title: "Invalid input.", message: "Please select two faces to compare.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert,animated: true)
        }
    }
    
    func similarityResult(similarity: Float){
        let alert = UIAlertController(title: "Similarity of provided faces.", message: "\(similarity)%", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert,animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}

