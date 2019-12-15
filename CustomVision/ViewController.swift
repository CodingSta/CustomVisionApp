
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var btnA: UIButton!
    @IBOutlet weak var txtV: UITextView!
    
    var pickerA: UIImagePickerController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imgV.isUserInteractionEnabled = true
        let tapG = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapG.numberOfTouchesRequired = 1
        tapG.numberOfTouchesRequired = 1
        self.imgV.addGestureRecognizer(tapG)
        
        self.pickerA = UIImagePickerController()
        self.pickerA.delegate = self
        self.pickerA.allowsEditing = true
        self.pickerA.mediaTypes = ["public.image"]
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.pickerA.sourceType = .camera
        }
        
    }

    // Send Image to CustomVision API
    @IBAction func postIMG(_ sender: Any) {
        
        let urlStr = "https://changjo.cognitiveservices.azure.com/customvision/v3.0/Prediction/44285cd7-9519-41e3-af4e-548d711bbdd7/classify/iterations/FirstModel/image"
        let urlA = URL(string: urlStr)!
        var reqA = URLRequest(url: urlA)
        reqA.httpMethod = "POST"
        reqA.addValue("ae2528d055b04affad209b1490b91ae4", forHTTPHeaderField: "Prediction-Key")
        reqA.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        reqA.timeoutInterval = 30.0
        
        let boundary = String(format: "----iOSURLSessionBoundary.%08x%08x", arc4random(), arc4random())
        let imgData = self.imgV.image!.jpegData(compressionQuality: 1.0)
        var body = Data()
        let filename = "abc.jpg"

        body.append(("--\(boundary)" + "\r\n").data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"formName\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append(("Content-Type: \("image/jpeg")" + "\r\n" + "\r\n").data(using: .utf8)!)
        
        body.append(imgData!)
        body.append("\r\n".data(using: .utf8)!)

        body.append(("--\(boundary)--" + "\r\n").data(using: .utf8)!)
        reqA.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        reqA.httpBody = body
                
        URLSession.shared.dataTask(with: reqA) { (dataA, respA, errA) in
            if let data = dataA, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
                
                DispatchQueue.main.async {
                    let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    if let arrA = json["predictions"] as? Array<Dictionary<String, Any>> {
                        for dicA in arrA {
                            if Float(truncating: dicA["probability"] as! NSNumber) > 0.9 {
                                self.txtV.text = (dicA["tagName"] as! String)
                            }
                        }
                    }
                }
            }
        }.resume()
        
    }
    
    // When Tap ImageView
    @objc func tapped(_ getsture: UITapGestureRecognizer) {
        self.txtV.text = "New Image"
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            present(self.pickerA, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let imageA = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 1024, height: 1024), false, 1.0)
            imageA.draw(in: CGRect(x: 0, y: 0, width: 1024, height: 1024))
            let imgB = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            self.imgV.image = imgB
        }
        dismiss(animated: true, completion: nil)
    }
}

