//
//  FriendsVC.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 12/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class FriendsVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,responseDelegate, UISearchBarDelegate {
    
    
    @IBOutlet weak var mySearchBar: UISearchBar!
    @IBOutlet var btnAddFriends : UIButton!
    @IBOutlet var btnInviteFriends : UIButton!
    @IBOutlet var collectionView : UICollectionView!
    
    var arrRecommendedUser = NSMutableArray()
    var currentPage : NSInteger = 0
    var refreshView : LGRefreshView!
    var loadNextPage : Bool = true
    var selectedIndex : NSInteger = -1
    var selectedFollowIndex : NSInteger = -1
    
    var isSearch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mySearchBar.delegate = self
        // Do any additional setup after loading the view.
        
        
        btnAddFriends.layer.borderWidth = 2
        btnAddFriends.backgroundColor = defaultColor
        btnAddFriends.setTitleColor(UIColor.white, for: .normal)
        btnAddFriends.layer.cornerRadius = btnAddFriends.frame.size.height/2
        
        btnInviteFriends.layer.borderWidth = 2
        btnInviteFriends.setTitleColor(defaultColor, for: .normal)
        btnInviteFriends.layer.cornerRadius = btnInviteFriends.frame.size.height/2
        btnInviteFriends.layer.borderColor = defaultColor.cgColor
        
        self.getRecommendedUser(showProgress: true)
        
        weak var wself = self
        
        refreshView = LGRefreshView.init(scrollView: self.collectionView, refreshHandler: { (refreshView) in
            if (wself != nil)
            {
                self.loadNextPage = true
                self.currentPage = 0
                self.arrRecommendedUser.removeAllObjects()
                self.getRecommendedUser(showProgress: false)
            }
        })
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.relaodData), name: NSNotification.Name(rawValue: "relaodFriend"), object: nil)
    }
    
    @objc func relaodData()
    {
        // self.loadNextPage = true
        //  self.currentPage = 0
        self.arrRecommendedUser.removeObject(at: selectedFollowIndex)
        // self.getRecommendedUser(showProgress: false)
        self.collectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if self.mySearchBar.text!.isEmpty {
            
            isSearch = false
            self.loadNextPage = true
            self.currentPage = 0
            self.mySearchBar.resignFirstResponder()
            self.getRecommendedUser(showProgress: true)
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.mySearchBar.resignFirstResponder()
        
        if !mySearchBar.text!.isEmptyField {
            getRecommendedUserSearching(showProgress: true)
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearch = false
        self.loadNextPage = true
        self.currentPage = 0
        self.mySearchBar.resignFirstResponder()
        self.arrRecommendedUser.removeAllObjects()
        self.view.endEditing(true)
        self.getRecommendedUser(showProgress: true)
        weak var wself = self
        
    }
    
    
    //MARK:- API Call
    func getRecommendedUser(showProgress:Bool)
    {
        print(currentPage)
        
        let strURL = "\(SERVER_URL)/recommended?page=\(currentPage)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "fetch-posts", bodyObject: nil, delegate: self, isShowProgress: showProgress)
    }
    
    func getRecommendedUserSearching(showProgress:Bool)
    {
        isSearch = true
        
        let strURL = "\(SERVER_URL)/recommended?page=0&query=\(self.mySearchBar.text!)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "fetch-posts-Searching", bodyObject: nil, delegate: self, isShowProgress: showProgress)
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            self.refreshView.endRefreshing()
            
            if ServiceName == "follow-request"
            {
                self.collectionView.isUserInteractionEnabled = true
                self.view.makeToast((Response.value(forKey: "responseMessage") as! String))
                self.arrRecommendedUser.removeObject(at: self.selectedIndex)
                self.collectionView.reloadData()
                self.selectedIndex = -1
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadFollowing"), object: nil, userInfo: nil)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPost"), object: nil, userInfo: nil)
                
            }
            else if ServiceName == "delete-recommended"
            {
                self.arrRecommendedUser.removeObject(at: self.selectedIndex)
                self.collectionView.reloadData()
                self.selectedIndex = -1
                
            } else if ServiceName == "fetch-posts-Searching" {
                
                self.arrRecommendedUser.removeAllObjects()
                self.collectionView.reloadData()
                
                
                let arrayPost = (Response.object(forKey: "recommendedUser") as! NSArray).mutableCopy() as! NSMutableArray
                
                if arrayPost.count == 0 {
                    
                    //  self.loadNextPage = false
                }
                else{
                    
                    //  self.loadNextPage = true
                    self.arrRecommendedUser.addObjects(from: arrayPost as! [Any])
                    // self.currentPage = Response.value(forKey: "nextPage") as! Int
                }
                self.collectionView.reloadData()
                
            } else {
                
                let arrayPost1 = (Response.object(forKey: "recommendedUser") as! NSArray).mutableCopy() as! NSMutableArray
                
                if arrayPost1.count != 0 {
                    
                    //   self.arrRecommendedUser.removeAllObjects()
                    self.collectionView.reloadData()
                    
                    let arrayPost = (Response.object(forKey: "recommendedUser") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    if arrayPost.count == 0 {
                        
                        //self.loadNextPage = false
                    }
                    else {
                        
                        self.loadNextPage = true
                        self.arrRecommendedUser.addObjects(from: arrayPost as! [Any])
                        
                        print(Response.value(forKey: "nextPage") as! Int)
                        
                        self.currentPage = Response.value(forKey: "nextPage") as! Int
                    }
                    
                    self.collectionView.reloadData()
                }
                
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = "Friends"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.init(name: "FiraSans-Bold", size: 15),NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.kern:2.0]
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.isTranslucent = false
        
        let rightBarBtn = UIBarButtonItem.init(image: UIImage.init(named: "menu"), style: .plain, target: self, action: #selector(clickOnMenu))
        self.navigationItem.rightBarButtonItem = rightBarBtn
        
        
        //--set select bottom tab
//        var frame = appDelegate.bottomView.frame
//        frame.origin.x = 3.0 * (UIScreen.main.bounds.width/5)
//        appDelegate.bottomView.frame  = frame
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.arrRecommendedUser.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellforfriends", for: indexPath)
        
        let imgViewProfile = cell.contentView.viewWithTag(1001) as! UIImageView
        let lblName = cell.contentView.viewWithTag(1002) as! UILabel
        let lblBio = cell.contentView.viewWithTag(1003) as! UILabel
        let btnFollow = cell.contentView.viewWithTag(1004) as! UIButton
        let btnDelete = cell.contentView.viewWithTag(1005) as! UIButton
        let btnDeleteAction = cell.contentView.viewWithTag(1006) as! UIButton
        
        imgViewProfile.layer.cornerRadius = 5
        imgViewProfile.layer.masksToBounds = true
        
        btnFollow.layer.borderWidth = 1
        btnFollow.layer.cornerRadius = btnFollow.frame.size.height/2
        btnFollow.setTitleColor(UIColor.init(red: 18/255, green: 171/255, blue: 220/255, alpha: 1), for: .normal)
        btnFollow.layer.borderColor = UIColor.init(red: 18/255, green: 171/255, blue: 220/255, alpha: 1).cgColor
        
        btnFollow.addTarget(self, action: #selector(self.clickOnFollow(sender:)), for: UIControl.Event.touchUpInside)
        
        cell.layer.addBorder(edge: .bottom, color: UIColor.init(red: 230/255, green: 230/255, blue: 230/255, alpha: 1), thickness: 0.5)
        
        if indexPath.item%2 == 0{
            cell.layer.addBorder(edge: .right, color: UIColor.init(red: 230/255, green: 230/255, blue: 230/255, alpha: 1), thickness: 0.5)
        }
        else{
            cell.layer.addBorder(edge: .right, color: UIColor.init(red: 230/255, green: 230/255, blue: 230/255, alpha: 1), thickness: 0)
        }
        
        let dicUser = self.arrRecommendedUser.object(at: indexPath.item) as! NSDictionary
        
        lblName.text = dicUser.value(forKey: "name") as? String
        lblBio.text = dicUser.value(forKey: "bio") as? String
        
        var stravatar = dicUser.value(forKey: "avatar") as? String
        stravatar = stravatar?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        if stravatar != nil{
            imgViewProfile.sd_setImage(with: URL.init(string: stravatar!), placeholderImage: nil, options: .continueInBackground, completed: nil)
        }
        
        
        btnDelete.addTarget(self, action: #selector(self.deleteRecommended(sender:)), for: UIControl.Event.touchUpInside)
        
        btnDeleteAction.addTarget(self, action: #selector(self.deleteRecommended(sender:)), for: UIControl.Event.touchUpInside)
        
        if isSearch == false {
            if indexPath.item == self.arrRecommendedUser.count - 1 && self.loadNextPage
            {
                self.getRecommendedUser(showProgress: true)
            }
        }
        
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return  UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = CGSize.init(width: ((UIScreen.main.bounds.size.width)/2), height: 250)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let profileVC = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationItem.title = ""
        profileVC.dicUserDetail = (arrRecommendedUser.object(at: indexPath.item) as? NSDictionary)!
        selectedFollowIndex = indexPath.item
        self.navigationController?.pushViewController(profileVC, animated: true)
        
    }
    
    @objc func clickOnFollow(sender:UIButton)
    {
        var tempView = sender as UIView
        var cell : UICollectionViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UICollectionViewCell.self)
            {
                cell = (tempView as! UICollectionViewCell)
                break
            }
        }
        
        collectionView.isUserInteractionEnabled = false
        
        let indexPath = collectionView.indexPath(for: cell)
        let dicRecommended = self.arrRecommendedUser.object(at: indexPath!.row) as! NSDictionary
        
        self.selectedIndex = (indexPath?.row)!
        
        let strURL = "\(SERVER_URL)/follow-request"
        
        let dicFollow = NSMutableDictionary()
        dicFollow.setValue(dicRecommended.value(forKey: "id") as! Int, forKey: "following_id")
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "follow-request", bodyObject: dicFollow as AnyObject, delegate: self, isShowProgress: true)
        
    }
    
    @objc func deleteRecommended(sender:UIButton)
    {
        var tempView = sender as UIView
        var cell : UICollectionViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UICollectionViewCell.self)
            {
                cell = (tempView as! UICollectionViewCell)
                break
            }
        }
        
        let indexPath = collectionView.indexPath(for: cell)
        let dicRecommended = self.arrRecommendedUser.object(at: indexPath!.row) as! NSDictionary
        
        let strURL = "\(SERVER_URL)/delete-recommended"
        
        self.selectedIndex = (indexPath?.row)!
        
        let strParameters = String.init(format: "opponentId=%d",dicRecommended.value(forKey: "id") as! Int)
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "delete-recommended", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
        
    }
    
    @objc func clickOnMenu(){
        
        let homeMenuVC = objMainSB.instantiateViewController(withIdentifier: "HomeMainMenuVC") as! HomeMainMenuVC
        
        self.navigationController?.pushViewController(homeMenuVC, animated: true)
        
    }
    
    
    @IBAction func clickOnInvite(sender:UIButton)
    {
        let shareProfileVC = objMainSB.instantiateViewController(withIdentifier: "ShareProfileViewController") as! ShareProfileViewController
        shareProfileVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(shareProfileVC, animated: true)
    }
    
    
}

extension CALayer {
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        
        let border = CALayer()
        
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        
        border.backgroundColor = color.cgColor;
        
        addSublayer(border)
    }
}
