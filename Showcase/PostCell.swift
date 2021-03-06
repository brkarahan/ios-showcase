//
//  PostCell.swift
//  Showcase
//
//  Created by Burak Karahan on 14/06/16.
//  Copyright © 2016 Burak Karahan. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    
    var post: Post!
    var request: Request?
    var likeRef: FIRDatabaseReference!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }
    
    func configureCell(post: Post, img: UIImage?){
        self.post = post
        likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        
        descriptionText.text = post.postDescription
        likesLbl.text = "\(post.likes)"
        
        if post.imgUrl != nil {
            if img != nil {
                self.showcaseImg.image = img
            }else{
                request = Alamofire.request(.GET, post.imgUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imgUrl!)
                    }
                    
                })
            }
            
        }
        else{
            self.showcaseImg.hidden = true
        }
        
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                //This means we have not liked this specific post
                self.likeImage.image = UIImage(named: "heart-empty")
            }else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let doesNotExist = snapshot.value as? NSNull {
                //This means we have not liked this specific post
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            }else {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
    }

}
