//
//  OCRViewController.swift
//  PicAnswer
//
//  Created by Benjamin Sloutsky on 1/30/23.
//
import UIKit
import Vision

class OCRViewController: UIViewController {

  var selectedImage: UIImage?

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var txt1: UITextView!
    @IBOutlet weak var txt2: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Image Results"
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
      }
    override func viewDidAppear(_ animated: Bool) {
        performOCR()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //if self.isMovingFromParent {
            // Back button was pressed
            let story = UIStoryboard(name: "Main", bundle:nil)
            let vc = story.instantiateViewController(withIdentifier: "NavController") as! UINavigationController
            UIApplication.shared.windows.first?.rootViewController = vc
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        //}
    }


  func performOCR() {
    guard let ciImage = CIImage(image: selectedImage!) else { return }

    let request = VNRecognizeTextRequest { (request, error) in
      guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

      var recognizedText = ""
      for observation in observations {
        guard let topCandidate = observation.topCandidates(1).first else { return }
        recognizedText += topCandidate.string
        recognizedText += "\n"
      }

        self.img.image = self.selectedImage
        self.txt1.text = recognizedText
      print(recognizedText)
        APICaller.shared.getResponse(input: recognizedText) { [weak self] result in
            
                switch result {
                case .success(let output):
                    DispatchQueue.main.async {
                        self?.txt2.text = output
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.txt2.text = error.localizedDescription
                    }
                }
            
        }
    }

    request.recognitionLevel = .accurate
    request.recognitionLanguages = ["en-US"]

    let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
    try! handler.perform([request])
  }
    @IBAction func update(_ sender: Any) {
        APICaller.shared.getResponse(input: self.txt1.text) { [weak self] result in
            switch result {
            case .success(let output):
                self?.txt2.text = output
            case .failure(let error):
                self?.txt2.text = error.localizedDescription
            }
        }
    }
}
