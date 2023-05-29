//
//  FeedViewController.swift
//  InstagramClone
//
//  Created by Bircan Sezgin on 26.05.2023.
//

import UIKit
import Firebase
import FirebaseFirestore
import SDWebImage
import OneSignal
class FeedViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var userEmailArray = [String]()
    var userCommetArray = [String]()
    var userLike = [Int]()
    var userImageArray = [String]()
    var documentIDArray = [String]()
    
    
    let fireStoreDataBase = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        tableView.dataSource = self
        tableView.delegate = self
        
        getDataFormFireStore()
        
        
        

        
        
        // Player ID
        
        let status : OSDeviceState = OneSignal.getDeviceState()
        let playerId = status.userId


        if let playerNewID = playerId{
            fireStoreDataBase.collection("playerID").whereField("email", isEqualTo: Auth.auth().currentUser!.email!).getDocuments { snapshot, error in
                if error == nil{
                    if snapshot?.isEmpty == false && snapshot != nil{
                        for document in snapshot!.documents{
                            if let playerIDFromFirebase = document.get("playerId") as? String{
                                let documentID = document.documentID
                                if playerNewID != playerIDFromFirebase{
                                    // DATABASE OLUSTURMAK
                                    // DATEbASE ICERIGINI OLURTURMAK
                                    let playerIDdictionary = ["email" : Auth.auth().currentUser!.email!, "playerId" : playerNewID] as! [String : Any]
                                    
                                    self.fireStoreDataBase.collection("playerID").addDocument(data: playerIDdictionary) { error in
                                        if error != nil{
                                            print(error?.localizedDescription ?? "error")
                                        }
                                    }
                                }
                            }
                        }
                    }else{
                        let playerIDdictionary = ["email" : Auth.auth().currentUser!.email!, "playerId" : playerNewID] as! [String : Any]
                        
                        self.fireStoreDataBase.collection("playerID").addDocument(data: playerIDdictionary) { error in
                            if error != nil{
                                print(error?.localizedDescription ?? "error")
                            }
                        }
                    }
                }
            }
            
            

        }
        
    }// ViewDidLoad Finish
    
// Verileri cekmek
    func getDataFormFireStore(){
        
       // Instance olusturmak

        // ekeleme Tarihine gore siralama
        fireStoreDataBase.collection("Posts").order(by: "date", descending: true).addSnapshotListener { snapshot, error in
            if error != nil{
                print("HATA ALDIM")
            }else{
                if snapshot?.isEmpty != true && snapshot != nil{
                    
                    // Veri tekrarlanmasin icin siliyoruz!
                    self.userImageArray.removeAll(keepingCapacity: false)
                    self.userLike.removeAll(keepingCapacity: false)
                    self.userCommetArray.removeAll(keepingCapacity: false)
                    self.userEmailArray.removeAll(keepingCapacity: false)
                    self.documentIDArray.removeAll(keepingCapacity: false)
                    
                    for document in snapshot!.documents{
                        let documentID = document.documentID // ID ALMAK!
                        self.documentIDArray.append(documentID)
                        
                        if let postedBy = document.get("postedBy") as? String{
                            self.userEmailArray.append(postedBy)
                        }
                        
                        if let postCommet = document.get("postComment") as? String{
                            self.userCommetArray.append(postCommet)
                        }
                        
                        if let likes = document.get("likes") as? Int{
                            self.userLike.append(likes)
                        }
                        
                        if let imageURL = document.get("imageURL") as? String{
                            self.userImageArray.append(imageURL)
                        }
                    }
                    
                    self.tableView.reloadData()
                }
               
            }
        }
        
        
    }
  

}

extension FeedViewController : UITableViewDelegate, UITableViewDataSource{
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userEmailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedCell
     
        cell.userEmail.text = userEmailArray[indexPath.row]
        cell.likeLabel.text = String(userLike[indexPath.row])
        cell.commetLabel.text = userCommetArray[indexPath.row]
        cell.userImageView.sd_setImage(with: URL(string: userImageArray[indexPath.row]))
        cell.documentIDLabel.text = documentIDArray[indexPath.row]
        
        return cell
    }
    
    
}
