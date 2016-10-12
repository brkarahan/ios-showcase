//
//  Post.swift
//  Showcase
//
//  Created by Burak Karahan on 26/08/16.
//  Copyright © 2016 Burak Karahan. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _postDescription: String!
    private var _imageUrl: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    
    var postDescription: String {
        return _postDescription
    }
    
    var imgUrl: String? {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var username: String {
        return _username
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(description: String, imgUrl: String?, username:String){
        self._postDescription = postDescription
        self._imageUrl = imgUrl
        self._username = username
    }
    
    init(postkey: String, dictionary: Dictionary <String, AnyObject>){
        self._postKey = postkey
        
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let imgUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
        self._postRef = DataService.ds.REF_POSTS.child(self.postKey)
        
    }
    
    func adjustLikes(adLike: Bool){
        if adLike {
            _likes = _likes + 1
        }else {
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
    }
}