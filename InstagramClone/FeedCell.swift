//
//  FeedCell.swift
//  InstagramClone
//
//  Created by Bircan Sezgin on 26.05.2023.
//

import UIKit
import Firebase
import FirebaseFirestore
import OneSignal
class FeedCell: UITableViewCell {

    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var commetLabel: UILabel!
    @IBOutlet weak var LikeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var documentIDLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }

    @IBAction func likeButtonClick(_ sender: Any) {
        
        let fireStoreDatabase = Firestore.firestore()
        
        let userEmail = self.userEmail.text!
        fireStoreDatabase.collection("playerID").whereField("email", isEqualTo: userEmail).getDocuments { snapshot, error in
            if error == nil{
                if snapshot?.isEmpty == false && snapshot != nil{
                    for document in snapshot!.documents{
                        if let playerID = document.get("playerId") as? String{
                            OneSignal.postNotification( ["contents": ["en": "\(Auth.auth().currentUser!.email!) Liked Your Post!"], "include_player_ids": ["\(playerID)"]])
                            
                        }
                    }
                }
            }
        }
        
        // Kullanıcının kimlik bilgisi
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        // Beğenilen postun kimlik bilgisi
        guard let postID = documentIDLabel.text else { return }
        
        // Beğenme işlemini gerçekleştirmeden önce kontrol yapma
        fireStoreDatabase.collection("Likes").whereField("userID", isEqualTo: userID).whereField("postID", isEqualTo: postID).getDocuments { (snapshot, error) in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
                return
            }
            
            // Kullanıcı daha önce bu postu beğenmişse, beğenmeyi iptal et
            if let snapshot = snapshot, !snapshot.isEmpty {
                // Beğenmeyi iptal etmek için "Likes" koleksiyonundan ilgili belgeyi sil
                for document in snapshot.documents {
                    document.reference.delete()
                }
                
                // Beğeni sayısını azalt
                if let likeCount = Int(self.likeLabel.text!) {
                    let likeStore = ["likes": likeCount - 1] as [String: Any]
                    fireStoreDatabase.collection("Posts").document(postID).setData(likeStore, merge: true)
                    self.likeLabel.text = "\(likeCount - 1)"
                }
            }
            // Kullanıcı daha önce bu postu beğenmemişse, beğenmeyi gerçekleştir
            else {
                
                
                
                // Yeni beğeni için "Likes" koleksiyonuna yeni belge ekle
                let likeData = ["userID": userID, "postID": postID] as [String: Any]
                fireStoreDatabase.collection("Likes").addDocument(data: likeData) { (error) in
                    if let error = error {
                        print("Hata: \(error.localizedDescription)")
                        return
                    }

                    // Beğeni sayısını artır
                    if let likeCount = Int(self.likeLabel.text!) {
                        let likeStore = ["likes": likeCount + 1] as [String: Any]
                        fireStoreDatabase.collection("Posts").document(postID).setData(likeStore, merge: true)
                        self.likeLabel.text = "\(likeCount + 1)"
                    }
                }
            }
        }
    }
}
