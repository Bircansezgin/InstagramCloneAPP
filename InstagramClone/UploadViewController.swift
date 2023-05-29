//
//  UploadViewController.swift
//  InstagramClone
//
//  Created by Bircan Sezgin on 26.05.2023.
//

import UIKit
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var commetTextField: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadButton.isHidden = true
        // Resme Tiklanabilir hale Getirmek
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleTap() {
        view.endEditing(true) // Klavyenin kapanması için bu satırı ekleyin
    }

    
    @objc func chooseImage(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        
        // Datayi nerden alacagiz
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true)
        
      
        
    }
    
    // Image Selected!
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        // Resmi Sectikten sonra Kapat!
        self.dismiss(animated: true)
        uploadButton.isHidden = false
    }
    
    
    @IBAction func uploadClick(_ sender: Any) {
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){
            
            let uuid = UUID().uuidString // Ayni isim olmamasini istiyoruz
            
            let imageReference = mediaFolder.child("\(uuid).jpg") // Gorselin referansi
            imageReference.putData(data, metadata: nil) { metaData, error in
                if error != nil{
                    self.alerts(title: "Error", message: error?.localizedDescription ?? "Error")
                }else{
                    
                    imageReference.downloadURL { url, error in
                        
                        if error != nil{
                            self.alerts(title: "Error", message: error?.localizedDescription ?? "Error")
                        }else{
                            let imageUrl = url?.absoluteString
                            
                            // DATABASE
                            let fireStoreDataBase = Firestore.firestore()
                            var fireStoreReference : DocumentReference? = nil
                            
                            let fireStorePost = ["imageURL": imageUrl!, "postedBy" : Auth.auth().currentUser!.email!, "postComment" : self.commetTextField.text! , "date" : FieldValue.serverTimestamp(), "likes" : 0] as [String : Any]
                            
                            fireStoreReference = fireStoreDataBase.collection("Posts").addDocument(data: fireStorePost, completion: { error in
                                if error != nil{
                                    self.alerts(title: "Error", message: error?.localizedDescription ?? "Error")
                                }else{
                                    self.imageView.image = UIImage(named: "clickme")
                                    self.commetTextField.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                }
                            })
                            
                        }
                    }// Download Finish
                    
                }
            }
            
        }
        
    }
    
    
    
    
    func alerts(title:String, message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okbutton = UIAlertAction(title: "OKEY", style: .default)
        alert.addAction(okbutton)
        self.present(alert, animated: true)
    }
    
}
