//
//  OCRViewController.swift
//  PicAnswer
//
//  Created by Benjamin Sloutsky on 1/30/23.
//
import UIKit
import Vision
import FirebaseFirestore
import Firebase

class OCRViewController: UIViewController {

    var db = Firestore.firestore()
    var selectedImage: UIImage?


    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var txt1: UITextView!
    @IBOutlet weak var txt2: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Image Results"
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.addDoneButtonOnKeyboard()

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
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController = vc
        (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.makeKeyAndVisible()
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

        db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).getDocument { document, err in
            if let document = document, document.exists {
                let field = document.data()?["premium"]
                let date1 = document.data()?["premiumDate"]
                let date2 = Date()
                // use the field as desired
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                
                if ((field as! String != "no") && date1 as! String != ""){
                    let date = dateFormatter.date(from:date1 as! String)!
                    if (((date2.timeIntervalSince(date) / (60 * 60 * 24)) <= 30)){
                        self.txt2.text = "ChatGPT response loading..."
                        APICaller.shared.getResponse(input: self.txt1.text) { [weak self] result in
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
                        
                    }else{
                        if let o = document.data()?["pics"] as? Int64{
                            print("Num = " + String(o))
                            if (o >= 10){
                                self.showToast(message: "Unfortunately you used up your AI call limit this month.", font: UIFont.systemFont(ofSize: 16.0))
                            }else{
                                self.txt2.text = "ChatGPT response loading..."
                                APICaller.shared.getResponse(input: self.txt1.text) { [weak self] result in
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
                                self.db.collection("users").document(UserDefaults.standard.object(forKey: "id") as! String).updateData(["pics" : (o+1)])
                            }
                        }
                    }
                    
                }
            }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        //doneToolbar.barStyle = UIBarStyle.blackTranslucent

        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(OCRViewController.doneButtonAction))

        let items = NSMutableArray()
        items.add(flexSpace)
        items.add(done)

        doneToolbar.items = items as? [UIBarButtonItem]
        doneToolbar.sizeToFit()

        txt1.inputAccessoryView = doneToolbar

    }
    @objc func doneButtonAction()
    {
        txt1.resignFirstResponder()
    }
}
