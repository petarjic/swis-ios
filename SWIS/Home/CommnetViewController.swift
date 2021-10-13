//
//  CommnetViewController.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 11/03/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import TTTAttributedLabel


class CommnetViewController: UIViewController,responseDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,TTTAttributedLabelDelegate {
    
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var inputContainerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var growingTextView: NextGrowingTextView!
    @IBOutlet var tblView : UITableView!
    @IBOutlet var imgPost : UIImageView!
    @IBOutlet var imgUser : UIImageView!
    @IBOutlet var lblTitlePost : UILabel!
    @IBOutlet var btnSend : UIButton!
    
    
    var dicPost : NSDictionary!
    var strWebsite : String!
    var arrCommnet = NSMutableArray()
    var selectedIndex : NSInteger = -1
    var selectedSection : NSInteger = -1
    var arrExpandedObjects = NSMutableArray()
    var dicCommentSectionWise = NSMutableDictionary()
    var isFromHome : Bool = false
    var isFirstTimeLoad : Bool = true
    var strPostId : String = ""
    var strCommentId : String = ""
    var dicNewPost : NSDictionary!
    var selectedPostId : Int = -1
    var objUserID: String?
    var isFirstTime: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        // Do any additional setup after loading the view.
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommnetViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(CommnetViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.growingTextView.textView.delegate = self
        self.growingTextView.layer.cornerRadius = 4
        self.growingTextView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        self.growingTextView.placeholderAttributedText = NSAttributedString(
            string: "Add Comment",
            attributes: [
                .font: self.growingTextView.textView.font!,
                .foregroundColor: UIColor.gray
            ]
        )
        
        var strUserImg = appDelegate.dicLoginDetail.value(forKey: "avatar") as? String
        strUserImg = strUserImg?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        self.imgUser.sd_setImage(with: URL.init(string: strUserImg!), placeholderImage: nil, options: .refreshCached, completed: nil)
        
        self.imgUser.layer.cornerRadius = imgUser.frame.size.height/2
        self.imgUser.layer.masksToBounds = true
        
        self.imgPost.layer.cornerRadius = 5
        self.imgPost.layer.masksToBounds = true
        
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = 75
        
        tblView.separatorStyle = .none
        
        if self.isFromHome{
            self.growingTextView.textView.becomeFirstResponder()
        }
        
        if self.strPostId != ""
        {
            self.getPostDetail()
        }
        else{
            self.setupPostDetail()
            self.getAllCommnets()
            
        }
    }
    
    func setupPostDetail()
    {
        
        let arrWebsite = dicPost.value(forKey: "websites") as! NSArray
        
        if arrWebsite.count > 0{
            
            let dicFirstObj = arrWebsite.object(at: 0) as! NSDictionary
            lblTitlePost.text = dicFirstObj.value(forKey: "search_term") as? String
            
        }
        
        if (dicPost.object(forKey: "user") as AnyObject).isKind(of: NSDictionary.self){
            
            let dicUser = dicPost.object(forKey: "user") as! NSDictionary
            
            var stravatar = dicUser.value(forKey: "avatar") as? String
            stravatar = stravatar?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            self.imgPost.sd_setImage(with: URL.init(string: stravatar!), placeholderImage: nil, options: .continueInBackground, completed: nil)
            
        }
    }
    
    func getPostDetail()
    {
        let strURL = "\(SERVER_URL)/posts/\(strPostId)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "postsDetail", bodyObject: nil, delegate: self, isShowProgress: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = "Comments"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.init(name: "FiraSans-Bold", size: 15),NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.kern:2.0]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back-icon.png"), style: .plain, target: self, action: #selector(self.clickOnBack))
        
        let rightBarBtn = UIBarButtonItem.init(image: UIImage.init(named: "menu"), style: .plain, target: self, action: #selector(clickOnMenu))
        self.navigationItem.rightBarButtonItem = rightBarBtn
    }
    
    @objc func clickOnBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @objc func clickOnMenu(){
        
        let homeMenuVC = objMainSB.instantiateViewController(withIdentifier: "HomeMainMenuVC") as! HomeMainMenuVC
        
        self.navigationController?.pushViewController(homeMenuVC, animated: true)
        
    }
    
    func getAllCommnets()
    {
        var strURL  : String = ""
        
        if self.strPostId != ""
        {
            strURL = "\(SERVER_URL)/posts/fetch-reply?page=0&post_id=\(dicPost.value(forKey: "id") as! Int)&comment_id=\(strCommentId)"
            
        }
        else{
            strURL = "\(SERVER_URL)/posts/fetch-reply?page=0&post_id=\(dicPost.value(forKey: "id") as! Int)"
            
        }
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "fetch-reply", bodyObject: nil, delegate: self, isShowProgress: true)
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            if Response.value(forKey: "responseCode") as! Int == 200{
                
                if ServiceName == "reply"{
                    
                    self.view.endEditing(true)
                    self.btnSend.isEnabled = false
                    self.growingTextView.textView.text = ""
                    self.growingTextView.textView.resignFirstResponder()
                    self.isFirstTimeLoad = false
                    self.selectedIndex = -1
                    self.selectedSection = -1
                    self.dicNewPost = Response.object(forKey: "post") as! NSDictionary
                    self.getAllCommnets()
                }
                else if ServiceName == "toggle-like"{
                    
                    if self.selectedSection != -1 && self.selectedIndex == -1
                    {
                        let dicComment = self.arrCommnet.object(at: self.selectedSection) as! NSDictionary

                        if dicComment.value(forKey: "like")  as! Int == 0{
                            dicComment.setValue(1, forKey: "like")
                            let likeCount = dicComment.value(forKey: "likes_count") as! Int
                            dicComment.setValue(likeCount+1, forKey: "likes_count")
                        }
                        else{
                            dicComment.setValue(0, forKey: "like")
                            let likeCount = dicComment.value(forKey: "likes_count") as! Int
                            if likeCount > 0{
                                dicComment.setValue(likeCount-1, forKey: "likes_count")
                            }else{
                                dicComment.setValue(0, forKey: "likes_count")
                            }
                        }

                        self.arrCommnet.replaceObject(at: self.selectedSection, with: dicComment)

                        // self.dicCommentSectionWise.setObject(self.arrCommnet, forKey: self.selectedSection as NSCopying)

                         self.tblView.reloadSections(NSIndexSet.init(index: self.selectedSection) as IndexSet, with: .none)

                        //self.tblView.reloadData()

                        self.selectedSection = -1
                    }
                    else if self.selectedSection != -1 && self.selectedIndex != -1{

                        let dicCommnet = (self.arrCommnet.object(at: self.selectedSection) as! NSDictionary).mutableCopy() as! NSMutableDictionary

                        let arrayComment = (dicCommnet.value(forKey: "comments") as! NSArray).mutableCopy() as! NSMutableArray

                        let predicate = NSPredicate.init(format: "id=%d", self.selectedPostId)
                        
                        let filtered = arrayComment.filtered(using: predicate) as! NSArray

                        var index : Int = 0

                        if filtered.count > 0{

                            index = arrayComment.index(of: filtered.object(at: 0))
                        }

                        let dicDetail = arrayComment.object(at: index) as! NSDictionary

                        if dicDetail.value(forKey: "like")  as! Int == 0{
                            dicDetail.setValue(1, forKey: "like")
                            let likeCount = dicDetail.value(forKey: "likes_count") as! Int
                            dicDetail.setValue(likeCount+1, forKey: "likes_count")
                        }
                        else{
                            dicDetail.setValue(0, forKey: "like")
                            let likeCount = dicDetail.value(forKey: "likes_count") as! Int
                            if likeCount > 0{
                                dicDetail.setValue(likeCount-1, forKey: "likes_count")
                            }else{
                                dicDetail.setValue(0, forKey: "likes_count")
                            }
                        }

                        if filtered.count > 0{

                            arrayComment.replaceObject(at: index, with: filtered.object(at: 0))
                            dicCommnet.setValue(arrayComment, forKey: "comments")
                            self.arrCommnet.replaceObject(at: self.selectedSection, with: dicCommnet)

                            self.selectedPostId = -1

                        }
                       
                        self.tblView.reloadSections(NSIndexSet.init(index: self.selectedSection) as IndexSet, with: .none)
                        //self.tblView.reloadData()
                    }
                    
                }
                else if ServiceName == "postsDetail"
                {
                    self.dicPost = Response.object(forKey: "post") as? NSDictionary
                    
                    self.setupPostDetail()
                    self.getAllCommnets()
                }
                else{
                    self.arrExpandedObjects.removeAllObjects()
                    self.dicCommentSectionWise = NSMutableDictionary()
                    
                    self.arrCommnet = (Response.object(forKey: "comments") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    let dicNew = NSMutableDictionary()
                    dicNew.setObject(self.dicNewPost, forKey: "newPost" as NSCopying)
                    dicNew.setObject(self.dicPost, forKey: "post" as NSCopying)
                    
                    if !self.isFirstTimeLoad{
                        
                        self.dicPost = self.dicNewPost
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "commentReload"), object: self.arrCommnet, userInfo: dicNew as! [AnyHashable : Any])
                    }
                    
                    
                    self.tblView.reloadData()
                }
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.arrCommnet.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.arrExpandedObjects.contains(NSNumber.init(value: section)){
            
            let array = self.dicCommentSectionWise.object(forKey: NSNumber.init(value: section)) as! NSArray
            
            return array.count
        }
        else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tblView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        
        //        if dicCommentSectionWise.count != 0 {
        //            var array = self.dicCommentSectionWise.object(forKey: NSNumber.init(value: indexPath.section)) as! NSArray
        //
        //            if (array as! AnyObject).isKind(of: NSNull.self)
        //            {
        
        let array = self.dicCommentSectionWise.object(forKey: NSNumber.init(value: indexPath.section)) as! NSArray
        
        let dicDetail = array.object(at: indexPath.row) as! NSDictionary
        
        let dicUser = dicDetail.object(forKey: "user") as! NSDictionary
        
        let imgView = cell.contentView.viewWithTag(1001) as! UIImageView
        let lbluserName = cell.contentView.viewWithTag(1002) as! UILabel
        let lblComment = cell.contentView.viewWithTag(1003) as! TTTAttributedLabel
        let lblTime = cell.contentView.viewWithTag(1004) as! UILabel
        let btnLikeCount = cell.contentView.viewWithTag(1005) as! UIButton
        let btnlike = cell.contentView.viewWithTag(1007) as! UIButton
        let imgLike = cell.contentView.viewWithTag(1008) as! UIImageView
        
        let tapGestureUserName = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnUserNameDetail(gesture:)))
        lbluserName.addGestureRecognizer(tapGestureUserName)
        lbluserName.isUserInteractionEnabled = true
        
        let tapGestureImg = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnUserProfile(gesture:)))
        imgView.addGestureRecognizer(tapGestureImg)
        imgView.isUserInteractionEnabled = true
        
        btnlike.addTarget(self, action: #selector(self.clickOnLikeChild(sender:)), for: UIControl.Event.touchUpInside)
        
        let like = dicDetail.value(forKey: "like") as! Int
        
        if like == 1{
            imgLike.image = UIImage.init(named: "likeblue.png")
        }
        else{
            imgLike.image = UIImage.init(named: "like.png")
        }
        
        let likeCount = dicDetail.value(forKey: "likes_count") as! Int
        let strCreatedAt = dicDetail.value(forKey: "created_at") as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: strCreatedAt!)
        
        lblTime.text = date?.timeAgoSimple
        
        let btnReplay = cell.contentView.viewWithTag(1006) as! UIButton
        btnReplay.addTarget(self, action: #selector(self.clikcOnReplay(sender:)), for: UIControl.Event.touchUpInside)
        
        btnReplay.translatesAutoresizingMaskIntoConstraints = true
        btnLikeCount.translatesAutoresizingMaskIntoConstraints = true
        lblComment.translatesAutoresizingMaskIntoConstraints = true
        lblTime.translatesAutoresizingMaskIntoConstraints = true
        
        imgView.sd_setImage(with: URL.init(string: dicUser.value(forKey: "avatar") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
        
        imgView.layer.cornerRadius = 5
        
        lbluserName.text = "\(dicUser.value(forKey: "username") as! String)"
        
        let mainView = cell.contentView.viewWithTag(10) as UIView?
        lblComment.frame = CGRect.init(x: 55, y: 25, width: (tblView?.frame.size.width)!-150, height: 21)
        mainView!.translatesAutoresizingMaskIntoConstraints = true
        
        lblComment.numberOfLines = 0
        lblComment.text = dicDetail.value(forKey: "comment") as? String
        lblComment.sizeToFit()
        
        let LinkAttributes = NSMutableDictionary(dictionary: lblComment.linkAttributes)
        LinkAttributes[NSAttributedString.Key.underlineStyle] =  NSNumber(value: false)
        lblComment.linkAttributes = LinkAttributes as NSDictionary as! [AnyHashable: Any]
        
        let arrayName = (lblComment.text! as! String).components(separatedBy: " ") as! NSArray
        
        for index in 0..<arrayName.count
        {
            let strUserName = arrayName.object(at: index) as! String
            
            let range = (lblComment.text as! NSString).range(of: "\(strUserName)")
            
            lblComment.delegate = self
            
            if strUserName.contains("@"){
                let strLinkUserName = strUserName.replacingOccurrences(of: "@", with: "")
                
                var url = "http://\(strLinkUserName)"
                url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                lblComment.addLink(to: URL.init(string: url), with: range)
                lblComment.isUserInteractionEnabled = true
            }
        }
        
        var frame = CGRect()
        
        if likeCount == 0{
            
            frame = btnReplay.frame
            frame.origin.x = 83
            frame.origin.y = lblComment.frame.origin.y + lblComment.frame.size.height
            btnReplay.frame = frame
            
            btnLikeCount.isHidden = true
            cell.contentView.bringSubviewToFront(btnReplay)
            
        }
        else{
            btnLikeCount.isHidden = false
            
            if likeCount > 1{
                btnLikeCount.setTitle("\(likeCount) likes", for: UIControl.State.normal)
            }
            else{
                btnLikeCount.setTitle("\(likeCount) like", for: UIControl.State.normal)
            }
            
            frame = btnLikeCount.frame
            frame.origin.x = 83
            frame.origin.y = lblComment.frame.origin.y + lblComment.frame.size.height
            btnLikeCount.frame = frame
            
            frame = btnReplay.frame
            frame.origin.x = 136
            frame.origin.y = lblComment.frame.origin.y + lblComment.frame.size.height
            btnReplay.frame = frame
        }
        
        frame = lblTime.frame
        frame.origin.y = lblComment.frame.origin.y + lblComment.frame.size.height
        lblTime.frame = frame
        
        frame = mainView!.frame
        frame.size.height = btnReplay.frame.origin.y + btnReplay.frame.size.height + 5
        frame.size.width = self.tblView.frame.size.width - 50
        mainView!.frame = frame
        
        cell.accessibilityValue = "\(dicDetail.value(forKey: "id") as! Int)"
        
        cell.selectionStyle = .none
        
        btnLikeCount.addTarget(self, action: #selector(self.clickOnViewLikes(sender:)), for: UIControl.Event.touchUpInside)
        
        //            }
        //        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
//        let cell = tblView.dequeueReusableCell(withIdentifier: "cell")
//
//        //        if dicCommentSectionWise.count != 0 {
//        var array = self.dicCommentSectionWise.object(forKey: NSNumber.init(value: indexPath.section)) as! NSArray
//        //
//        //            if (array as! AnyObject).isKind(of: NSNull.self)
//        //            {
//
//        array = array.reversed() as NSArray
//
//        let dicDetail = array.object(at: indexPath.row) as! NSDictionary
//
//        let dicUser = dicDetail.object(forKey: "user") as! NSDictionary
//
//        let imgView = cell!.contentView.viewWithTag(1001) as! UIImageView
//        let lbluserName = cell!.contentView.viewWithTag(1002) as! UILabel
//        let lblComment = cell!.contentView.viewWithTag(1003) as! UILabel
//        let lblTime = cell!.contentView.viewWithTag(1004) as! UILabel
//        let btnLikeCount = cell!.contentView.viewWithTag(1005) as! UIButton
//
//        let likeCount = dicDetail.value(forKey: "likes_count") as! Int
//        let strCreatedAt = dicDetail.value(forKey: "created_at") as? String
//
//        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        let date = dateFormatter.date(from: strCreatedAt!)
//
//        lblTime.text = date?.timeAgoSimple
//
//        let btnReplay = cell!.contentView.viewWithTag(1006) as! UIButton
//
//        btnReplay.translatesAutoresizingMaskIntoConstraints = true
//        btnLikeCount.translatesAutoresizingMaskIntoConstraints = true
//        lblComment.translatesAutoresizingMaskIntoConstraints = true
//        lblTime.translatesAutoresizingMaskIntoConstraints = true
//
//        imgView.sd_setImage(with: URL.init(string: dicUser.value(forKey: "avatar") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
//
//        imgView.layer.cornerRadius = 5
//
//        lbluserName.text = dicUser.value(forKey: "username") as? String
//
//        let mainView = cell!.contentView.viewWithTag(10) as UIView?
//        lblComment.frame = CGRect.init(x: 55, y: 25, width: (tblView?.frame.size.width)!-150, height: 21)
//        mainView!.translatesAutoresizingMaskIntoConstraints = true
//
//        lblComment.numberOfLines = 0
//        lblComment.text = dicDetail.value(forKey: "comment") as? String
//        lblComment.sizeToFit()
//
//        var frame = CGRect()
//
//        frame = lblTime.frame
//        frame.origin.y = lblComment.frame.origin.y + lblComment.frame.size.height
//        lblTime.frame = frame
//
//        if likeCount == 0{
//
//            frame = btnReplay.frame
//            frame.origin.x = 83
//            frame.origin.y = lblComment.frame.origin.y + lblComment.frame.size.height
//            btnReplay.frame = frame
//
//            btnLikeCount.isHidden = true
//            cell!.contentView.bringSubviewToFront(btnReplay)
//
//        }
//        else{
//            btnLikeCount.isHidden = false
//
//            if likeCount > 1{
//                btnLikeCount.setTitle("\(likeCount) likes", for: UIControl.State.normal)
//            }
//            else{
//                btnLikeCount.setTitle("\(likeCount) like", for: UIControl.State.normal)
//            }
//
//            frame = btnLikeCount.frame
//            frame.origin.x = 83
//            frame.origin.y = lblComment.frame.origin.y + lblComment.frame.size.height
//            btnLikeCount.frame = frame
//
//            frame = btnReplay.frame
//            frame.origin.x = 136
//            frame.origin.y = lblComment.frame.origin.y + lblComment.frame.size.height
//            btnReplay.frame = frame
//        }
//
//        frame = mainView!.frame
//        frame.size.height = btnReplay.frame.origin.y + btnReplay.frame.size.height + 5
//        frame.size.width = self.tblView.frame.size.width - 50
//
//        mainView!.frame = frame
        
        return UITableView.automaticDimension
        
        //            }
        //        }
        
        //  return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        let headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: [:])?.last as! HeaderView
        
        let dicCommnet = self.arrCommnet.object(at: section) as! NSDictionary
        let dicUser = dicCommnet.value(forKey: "user") as! NSDictionary
        
        headerView.imgUserView.sd_setImage(with: URL.init(string: dicUser.value(forKey: "avatar") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
        
        headerView.imgUserView.layer.cornerRadius = 5
        headerView.imgUserView.layer.masksToBounds = true
        
        headerView.lblComment.translatesAutoresizingMaskIntoConstraints = true
        headerView.lblUserName.text = "\(dicUser.value(forKey: "username") as! String)"
        headerView.lblComment.frame = CGRect.init(x: 60, y: headerView.lblComment.frame.origin.y, width: tblView.frame.size.width-100, height:18)
        headerView.lblComment.numberOfLines = 0
        headerView.lblComment.text = dicCommnet.value(forKey: "comment") as? String
        headerView.lblComment.sizeToFit()
        
        let likeCount = dicCommnet.value(forKey: "likes_count") as! Int
        let strCreatedAt = dicCommnet.value(forKey: "created_at") as? String
        let like = dicCommnet.value(forKey: "like") as! Int
        
        if like == 1{
            headerView.imgLike.image = UIImage.init(named: "likeblue.png")
        }
        else{
            headerView.imgLike.image = UIImage.init(named: "like.png")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: strCreatedAt!)
        
        headerView.lblTime.text = date?.timeAgoSimple
        
        headerView.btnLikeCount.translatesAutoresizingMaskIntoConstraints = true
        headerView.bReplay.translatesAutoresizingMaskIntoConstraints = true
        headerView.btnReplay.translatesAutoresizingMaskIntoConstraints = true
        
        var frame = CGRect()
        
        if likeCount == 0{
            
            frame = headerView.bReplay.frame
            frame.origin.x = 95
            headerView.bReplay.frame = frame
            
            headerView.btnLikeCount.isHidden = true
            headerView.bringSubviewToFront(headerView.bReplay)
        }
        else{
            headerView.btnLikeCount.isHidden = false
            
            headerView.btnLikeCount.setTitle("\(likeCount) likes", for: UIControl.State.normal)
            
            frame = headerView.btnLikeCount.frame
            frame.origin.x = 95
            headerView.btnLikeCount.frame = frame
            
            frame = headerView.bReplay.frame
            frame.origin.x = 150
            headerView.bReplay.frame = frame
        }
        
        let array = dicCommnet.object(forKey: "comments") as! NSArray
        
        if array.count > 0{
            
            headerView.lblReplayCount.isHidden = false
            
            let dicComment = self.arrCommnet.object(at: section) as! NSDictionary
            let array = (dicComment.object(forKey: "comments") as! NSArray) as NSArray
            let totalComments = array.count
            
            if self.dicCommentSectionWise.object(forKey: NSNumber.init(value: section)) != nil{
                
                let arrCommentSection = self.dicCommentSectionWise.object(forKey: NSNumber.init(value: section)) as! NSArray
                
                let remamingCount = totalComments - arrCommentSection.count
                
                if remamingCount > 0{
                    headerView.lblReplayCount.text = "---- View previous replies(\(remamingCount))"
                }else{
                    headerView.lblReplayCount.text = "---- hide replies"
                }
            }
            else{
                headerView.lblReplayCount.text = "---- View replies(\(array.count))"
            }
            
            
            frame = headerView.lblTime.frame
            frame.origin.y = headerView.lblComment.frame.origin.y + headerView.lblComment.frame.size.height + 2
            headerView.lblTime.frame = frame
            
            frame = headerView.bReplay.frame
            frame.origin.y = headerView.lblComment.frame.origin.y + headerView.lblComment.frame.size.height + 2
            headerView.bReplay.frame = frame
            
            frame = headerView.btnLikeCount.frame
            frame.origin.y = headerView.lblComment.frame.origin.y + headerView.lblComment.frame.size.height + 2
            headerView.btnLikeCount.frame = frame
            
            frame = headerView.lblReplayCount.frame
            frame.origin.y = headerView.bReplay.frame.origin.y + headerView.bReplay.frame.size.height
            headerView.lblReplayCount.frame = frame
            
            frame = headerView.btnReplay.frame
            frame.origin.y = headerView.bReplay.frame.origin.y + headerView.bReplay.frame.size.height
            headerView.btnReplay.frame = frame
            
            
            headerView.frame = CGRect.init(x: 0, y: 0, width: tblView.frame.size.width, height: headerView.lblReplayCount.frame.origin.y+headerView.lblReplayCount.frame.size.height)
            
            return headerView.frame.size.height + 5
            
            
        }
        else{
            
            headerView.frame = CGRect.init(x: 0, y: 0, width: tblView.frame.size.width, height: headerView.lblComment.frame.origin.y+headerView.lblComment.frame.size.height+25)
            
            frame = headerView.lblTime.frame
            frame.origin.y = headerView.lblComment.frame.origin.y + headerView.lblComment.frame.size.height + 2
            headerView.lblTime.frame = frame
            
            frame = headerView.bReplay.frame
            frame.origin.y = headerView.lblComment.frame.origin.y + headerView.lblComment.frame.size.height + 2
            headerView.bReplay.frame = frame
            
            frame = headerView.btnLikeCount.frame
            frame.origin.y = headerView.lblComment.frame.origin.y + headerView.lblComment.frame.size.height + 2
            headerView.btnLikeCount.frame = frame
            
            frame = headerView.frame
            frame.size.height = headerView.bReplay.frame.origin.y + headerView.bReplay.frame.size.height
            headerView.frame = frame
            
            return headerView.frame.size.height
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = Bundle.main.loadNibNamed("HeaderView", owner: self, options: [:])?.last as! HeaderView
        
        let dicCommnet = self.arrCommnet.object(at: section) as! NSDictionary
        let dicUser = dicCommnet.value(forKey: "user") as! NSDictionary
        
        headerView.imgUserView.sd_setImage(with: URL.init(string: dicUser.value(forKey: "avatar") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
        
        headerView.imgUserView.layer.cornerRadius = 5
        headerView.imgUserView.layer.masksToBounds = true
        headerView.imgUserView.tag = section
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnProfile(gesture:)))
        
        headerView.imgUserView.addGestureRecognizer(tapGesture)
        headerView.imgUserView.isUserInteractionEnabled = true
        
        headerView.lblComment.translatesAutoresizingMaskIntoConstraints = true
        headerView.lblUserName.text = "\(dicUser.value(forKey: "username") as! String)"
        
        let tapGestureUserName = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnUserName(gesture:)))
        
        headerView.lblUserName.tag = section
        headerView.lblUserName.addGestureRecognizer(tapGestureUserName)
        headerView.lblUserName.isUserInteractionEnabled = true
        
        headerView.lblComment.frame = CGRect.init(x: 60, y: headerView.lblComment.frame.origin.y, width: tblView.frame.size.width-100, height:18)
        headerView.lblComment.numberOfLines = 0
        headerView.lblComment.text = dicCommnet.value(forKey: "comment") as? String
        headerView.lblComment.sizeToFit()
        
        let string = headerView.lblComment.text! as! String
        
        let LinkAttributes = NSMutableDictionary(dictionary: headerView.lblComment.linkAttributes)
        LinkAttributes[NSAttributedString.Key.underlineStyle] =  NSNumber(value: false)
        headerView.lblComment.linkAttributes = LinkAttributes as NSDictionary as! [AnyHashable: Any]
        
        let arrayName = (headerView.lblComment.text! as! String).components(separatedBy: " ") as! NSArray
        
        for index in 0..<arrayName.count
        {
            let strUserName = arrayName.object(at: index) as! String
            
            let range = (headerView.lblComment.text as! NSString).range(of: "\(strUserName)")
            
            headerView.lblComment.delegate = self
            
            if strUserName.contains("@"){
                let strLinkUserName = strUserName.replacingOccurrences(of: "@", with: "")
                
                var url = "http://\(strLinkUserName)"
                url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                headerView.lblComment.addLink(to: URL.init(string: url), with: range)
                headerView.lblComment.isUserInteractionEnabled = true
                
            }
        }
        
        let likeCount = dicCommnet.value(forKey: "likes_count") as! Int
        let strCreatedAt = dicCommnet.value(forKey: "created_at") as? String
        let like = dicCommnet.value(forKey: "like") as! Int
        
        if like == 1{
            headerView.imgLike.image = UIImage.init(named: "likeblue.png")
        }
        else{
            headerView.imgLike.image = UIImage.init(named: "like.png")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: strCreatedAt!)
        
        headerView.lblTime.text = date?.timeAgoSimple
        
        headerView.btnLikeCount.translatesAutoresizingMaskIntoConstraints = true
        headerView.bReplay.translatesAutoresizingMaskIntoConstraints = true
        headerView.btnReplay.translatesAutoresizingMaskIntoConstraints = true
        
        
        
        var frame = CGRect()
        
        if likeCount == 0{
            
            frame = headerView.bReplay.frame
            frame.origin.x = 95
            headerView.bReplay.frame = frame
            
            headerView.btnLikeCount.isHidden = true
            headerView.bringSubviewToFront(headerView.bReplay)
        }
        else{
            headerView.btnLikeCount.isHidden = false
            
            headerView.btnLikeCount.setTitle("\(likeCount) likes", for: UIControl.State.normal)
            
            frame = headerView.btnLikeCount.frame
            frame.origin.x = 95
            headerView.btnLikeCount.frame = frame
            
            frame = headerView.bReplay.frame
            frame.origin.x = 150
            headerView.bReplay.frame = frame
        }
        
        let array = dicCommnet.object(forKey: "comments") as! NSArray
        
        if array.count > 0{
            
            headerView.lblReplayCount.isHidden = false
            
            let dicComment = self.arrCommnet.object(at: section) as! NSDictionary
            let array = (dicComment.object(forKey: "comments") as! NSArray) as NSArray
            let totalComments = array.count
            
            if self.dicCommentSectionWise.object(forKey: NSNumber.init(value: section)) != nil{
                
                let arrCommentSection = self.dicCommentSectionWise.object(forKey: NSNumber.init(value: section)) as! NSArray
                
                let remamingCount = totalComments - arrCommentSection.count
                
                if remamingCount > 0{
                    headerView.lblReplayCount.text = "---- View previous replies(\(remamingCount))"
                }else{
                    
                    if array.count > 1{
                        headerView.lblReplayCount.text = "---- hide replies"

                    }else{
                        headerView.lblReplayCount.text = ""

                    }
                }
            }
            else{
                headerView.lblReplayCount.text = "---- View replies(\(array.count))"
            }
            
            frame = headerView.lblTime.frame
            frame.origin.y = headerView.lblComment.frame.origin.y + headerView.lblComment.frame.size.height + 2
            headerView.lblTime.frame = frame
            
            frame = headerView.bReplay.frame
            frame.origin.y = headerView.lblComment.frame.origin.y + headerView.lblComment.frame.size.height + 2
            headerView.bReplay.frame = frame
            
            frame = headerView.btnLikeCount.frame
            frame.origin.y = headerView.lblComment.frame.origin.y + headerView.lblComment.frame.size.height + 2
            headerView.btnLikeCount.frame = frame
            
            frame = headerView.lblReplayCount.frame
            frame.origin.y = headerView.bReplay.frame.origin.y + headerView.bReplay.frame.size.height
            headerView.lblReplayCount.frame = frame
            
            frame = headerView.btnReplay.frame
            frame.origin.y = headerView.bReplay.frame.origin.y + headerView.bReplay.frame.size.height
            headerView.btnReplay.frame = frame
            
            headerView.frame = CGRect.init(x: 0, y: 0, width: tblView.frame.size.width, height: headerView.lblReplayCount.frame.origin.y+headerView.lblReplayCount.frame.size.height)
            
            headerView.btnReplay.isUserInteractionEnabled = true
        }
        else{
            
            headerView.frame = CGRect.init(x: 0, y: 0, width: tblView.frame.size.width, height: headerView.lblComment.frame.origin.y+headerView.lblComment.frame.size.height+25)
            
            frame = headerView.lblTime.frame
            frame.origin.y = headerView.lblComment.frame.origin.y + headerView.lblComment.frame.size.height + 2
            headerView.lblTime.frame = frame
            
            frame = headerView.bReplay.frame
            frame.origin.y = headerView.lblComment.frame.origin.y + headerView.lblComment.frame.size.height + 2
            headerView.bReplay.frame = frame
            
            frame = headerView.btnLikeCount.frame
            frame.origin.y = headerView.lblComment.frame.origin.y + headerView.lblComment.frame.size.height + 2
            headerView.btnLikeCount.frame = frame
            
            frame = headerView.frame
            frame.size.height = headerView.bReplay.frame.origin.y + headerView.bReplay.frame.size.height
            headerView.frame = frame
            
            headerView.lblReplayCount.isHidden = true
            headerView.btnReplay.isUserInteractionEnabled = false
        }
        
        headerView.bReplay.tag = section
        headerView.bReplay.addTarget(self, action: #selector(self.clickOnReplayComment(sender:)), for: UIControl.Event.touchUpInside)
        
        headerView.btnReplay.tag = section
        headerView.btnReplay.addTarget(self, action: #selector(self.clickOnViewReplay(sender:)), for: UIControl.Event.touchUpInside)
        
        headerView.btnLike.tag = section
        headerView.btnLike.addTarget(self, action: #selector(self.clickOnLike(sender:)), for: UIControl.Event.touchUpInside)
        
        headerView.btnLikeCount.tag = section
        headerView.btnLikeCount.addTarget(self, action: #selector(self.clickOnViewLikesHeaderComment(sender:)), for: UIControl.Event.touchUpInside)
        
        if section == 0 && array.count > 0{
            if self.isFirstTime {
                if array.count > 1
                {
                    headerView.lblReplayCount.text = "---- hide replies"
                }
                else{
                    headerView.lblReplayCount.text = ""
                }
                self.clickOnViewReplay(sender: headerView.btnReplay)
            }
            
        }
        
        return headerView
    }
    
    @objc func openReplay(sender:UIButton)
    {
        self.clickOnViewReplay(sender: sender)
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        
        var str = (url.absoluteString.components(separatedBy: "//") as! NSArray).object(at: 1) as! String
        
        let profileDetailVC = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileDetailVC.strCommentUserName = str
        profileDetailVC.isFromComment = true
        profileDetailVC.hidesBottomBarWhenPushed = false
        
        self.navigationController?.pushViewController(profileDetailVC, animated: true)
    }
    
    @objc func clickOnViewReplay(sender:UIButton)
    {
        let section = sender.tag
        let headerView = sender.superview as! HeaderView
        
        if !self.arrExpandedObjects.contains(section)
        {
            self.arrExpandedObjects.add(NSNumber.init(value: section))
        }
        
        let dicComment = self.arrCommnet.object(at: section) as! NSDictionary
        let array = (dicComment.object(forKey: "comments") as! NSArray) as NSArray
        
        let arrCommentSection = NSMutableArray()
        
        if headerView.lblReplayCount.text == "---- hide replies"
        {
            arrCommentSection.add(array.lastObject)
            
            let totalComments = array.count
            
            if self.isFirstTime{
                
                self.isFirstTime = false
                
                let remamingCount = totalComments - arrCommentSection.count
                
                let headerView = sender.superview as! HeaderView
                
                if remamingCount > 0{
                    headerView.lblReplayCount.text = "---- View previous replies(\(remamingCount))"
                }else{
                    headerView.lblReplayCount.text = "---- hide replies"
                }
                
            }
        }
        else{
            
            let totalComments = array.count
            let limit = 3
            
            if totalComments > limit
            {
                if self.dicCommentSectionWise.object(forKey: NSNumber.init(value: section)) != nil{
                    
                    arrCommentSection.addObjects(from: self.dicCommentSectionWise.object(forKey: NSNumber.init(value: section)) as! [Any])
                    
                    let remamingCount = totalComments - arrCommentSection.count
                    let headerView = sender.superview as! HeaderView
                    
                    if remamingCount > 0{
                        headerView.lblReplayCount.text = "---- View previous replies(\(remamingCount))"
                    }else{
                        headerView.lblReplayCount.text = "---- hide replies"
                    }
                    
                    if remamingCount >= 3{
                        
                        let object = Array(array.prefix(arrCommentSection.count+3))
                        arrCommentSection.removeAllObjects()
                        arrCommentSection.addObjects(from: object)
                    }
                    else{
                        if remamingCount > 0{
                            
                            let object = Array(array.prefix(arrCommentSection.count+remamingCount))
                            arrCommentSection.removeAllObjects()
                            arrCommentSection.addObjects(from: object)
                        }
                        
                    }
                }
                else{
                    let object = Array(array.suffix(3))
                    arrCommentSection.addObjects(from: object)
                }
            }
            else{
                arrCommentSection.addObjects(from: array as! [Any])
            }
        }
        self.dicCommentSectionWise.setObject(arrCommentSection, forKey: NSNumber.init(value: section))
        self.tblView.reloadSections(NSIndexSet.init(index: section) as IndexSet, with: .automatic)
        
    }
    
    @objc func clickOnLike(sender:UIButton)
    {
        let section = sender.tag
        let dicComment = self.arrCommnet.object(at: section) as! NSDictionary
        
        self.selectedIndex = -1
        self.selectedSection = section
        
        let strURL = "\(SERVER_URL)/posts/toggle-like"
        
        let dicFav = NSMutableDictionary()
        dicFav.setValue(dicComment.value(forKey: "id") as! Int, forKey: "post_id")
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "toggle-like", bodyObject: dicFav as AnyObject, delegate: self, isShowProgress: true)
    }
    
    @objc func clickOnLikeChild(sender:UIButton)
    {
        var tempView = sender as UIView
        var cell : UITableViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UITableViewCell.self)
            {
                cell = (tempView as! UITableViewCell)
                break
            }
        }
        
        
        let indexPath = tblView.indexPath(for: cell)
        self.selectedIndex = (indexPath?.row)!
        self.selectedSection = (indexPath?.section)!
        
        let dicCommnet = self.arrCommnet.object(at: self.selectedSection) as! NSDictionary
        let arrComment = dicCommnet.value(forKey: "comments") as! NSArray
        let dicDetail = arrComment.object(at: self.selectedIndex) as! NSDictionary
        
        let strURL = "\(SERVER_URL)/posts/toggle-like"
        
        let dicFav = NSMutableDictionary()
        dicFav.setValue(cell.accessibilityValue, forKey: "post_id")
        
        self.selectedPostId = Int(cell.accessibilityValue!)!
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "toggle-like", bodyObject: dicFav as AnyObject, delegate: self, isShowProgress: true)
    }
    @objc func clickOnViewLikesHeaderComment(sender:UIButton)
    {
        let section = sender.tag
        
        let dicCommnet = self.arrCommnet.object(at: section) as! NSDictionary
        //let arrComment = dicCommnet.value(forKey: "comments") as! NSArray
        //let dicDetail = arrComment.object(at: (indexPath?.row)!) as! NSDictionary
        
        //--new code
        let likeVC = objHomeSB.instantiateViewController(withIdentifier: "LikeViewController") as! LikeViewController
        likeVC.dicPostDetail = dicCommnet
        self.navigationController?.pushViewController(likeVC, animated: true)
    }
    @objc func clickOnViewLikes(sender:UIButton)
    {
        var tempView = sender as UIView
        var cell : UITableViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UITableViewCell.self)
            {
                cell = (tempView as! UITableViewCell)
                break
            }
        }
        
        let indexPath = tblView.indexPath(for: cell)
        
        let dicCommnet = self.arrCommnet.object(at: (indexPath?.section)!) as! NSDictionary
        let arrComment = dicCommnet.value(forKey: "comments") as! NSArray
        let dicDetail = arrComment.object(at: (indexPath?.row)!) as! NSDictionary
        
        //--new code
        let likeVC = objHomeSB.instantiateViewController(withIdentifier: "LikeViewController") as! LikeViewController
        likeVC.dicPostDetail = dicDetail
        self.navigationController?.pushViewController(likeVC, animated: true)
    }
    
    @objc func clikcOnReplay(sender:UIButton)
    {
        var tempView = sender as UIView
        var cell : UITableViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UITableViewCell.self)
            {
                cell = (tempView as! UITableViewCell)
                break
            }
        }
        
        let indexPath = tblView.indexPath(for: cell)
        self.selectedIndex = (indexPath?.row)!
        self.selectedSection = (indexPath?.section)!
        
        let array = self.dicCommentSectionWise.object(forKey: NSNumber.init(value: indexPath!.section)) as! NSArray

        let dicDetail1 = array.object(at: indexPath!.row) as! NSDictionary
        
        let dicUser1 = dicDetail1.object(forKey: "user") as! NSDictionary

        
        let dicCommnet = self.arrCommnet.object(at: self.selectedSection) as! NSDictionary
        let arrComment = dicCommnet.value(forKey: "comments") as! NSArray
        let dicDetail = arrComment.object(at: self.selectedIndex) as! NSDictionary
        let dicUser = dicDetail.object(forKey: "user") as! NSDictionary
        
        self.growingTextView.textView.text = "@\(dicUser1.value(forKey: "username") as! String) "
        
        self.growingTextView.textView.becomeFirstResponder()
    }
    
    @objc func clickOnReplayComment(sender:UIButton)
    {
        self.selectedSection = sender.tag
        
        let dicCommnet = self.arrCommnet.object(at: self.selectedSection) as! NSDictionary
        let dicUser = dicCommnet.object(forKey: "user") as! NSDictionary
        
        self.objUserID = "\(dicUser.value(forKey: "id") as! Int) "
        
        print(self.objUserID ?? "")
        
        self.growingTextView.textView.text = "@\(dicUser.value(forKey: "username") as! String) "
        
        self.growingTextView.textView.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func handleSendButton(_ sender: AnyObject) {
        
        if selectedIndex == -1 && selectedSection == -1{
            
            self.selectedSection = sender.tag
            
            let strURL = "\(SERVER_URL)/posts/reply"
            
            let dicReplay = NSMutableDictionary()
            dicReplay.setValue(dicPost.value(forKey: "id") as! Int, forKey: "post_id")
            dicReplay.setValue(self.growingTextView.textView.text!, forKey: "comment")
            dicReplay.setValue(dicPost.value(forKey: "id") as! Int, forKey: "main_post_id")
            dicReplay.setValue(self.objUserID, forKey: "user_id")
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "reply", bodyObject: dicReplay, delegate: self, isShowProgress: true)
        }
        else if selectedSection != -1{
            
            let strURL = "\(SERVER_URL)/posts/reply"
            
            let dicCommnet = self.arrCommnet.object(at: self.selectedSection) as! NSDictionary
            
            let dicReplay = NSMutableDictionary()
            dicReplay.setValue(dicCommnet.value(forKey: "id") as! Int, forKey: "post_id")
            dicReplay.setValue(self.growingTextView.textView.text!, forKey: "comment")
            dicReplay.setValue(dicPost.value(forKey: "id") as! Int, forKey: "main_post_id")
            dicReplay.setValue(self.objUserID, forKey: "user_id")
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "reply", bodyObject: dicReplay, delegate: self, isShowProgress: true)
        }
        else{
            self.sendReplay()
        }
        
    }
    
    func sendReplay()
    {
        
        let strURL = "\(SERVER_URL)/posts/reply"
        
        let dicCommnet = self.arrCommnet.object(at: self.selectedSection) as! NSDictionary
        let arrComment = dicCommnet.value(forKey: "comments") as! NSArray
        let dicDetail = arrComment.object(at: self.selectedIndex) as! NSDictionary
        
        let dicReplay = NSMutableDictionary()
        dicReplay.setValue(dicDetail.value(forKey: "id") as! Int, forKey: "post_id")
        dicReplay.setValue(dicPost.value(forKey: "id") as! Int, forKey: "main_post_id")
        dicReplay.setValue(self.growingTextView.textView.text!, forKey: "comment")
        dicReplay.setValue(self.objUserID, forKey: "user_id")
        
        print(dicReplay)
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "reply", bodyObject: dicReplay, delegate: self, isShowProgress: true)
        
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            if let _ = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                //key point 0,
                self.inputContainerViewBottom.constant =  0
                //textViewBottomConstraint.constant = keyboardHeight
                UIView.animate(withDuration: 0.25, animations: { () -> Void in self.view.layoutIfNeeded() })
            }
        }
    }
    @objc func keyboardWillShow(_ sender: Notification) {
        if let userInfo = (sender as NSNotification).userInfo {
            
            if let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height {
                
                self.inputContainerViewBottom.constant = keyboardHeight
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @objc func tapOnProfile(gesture:UITapGestureRecognizer)
    {
        let profileVC = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationItem.title = ""
        let dicCommnet = self.arrCommnet.object(at: (gesture.view?.tag)!) as! NSDictionary
        let dicUser = dicCommnet.value(forKey: "user") as! NSDictionary
        profileVC.dicUserDetail = dicUser
        profileVC.hidesBottomBarWhenPushed = false
        
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc func tapOnUserName(gesture:UITapGestureRecognizer)
    {
        let profileVC = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationItem.title = ""
        let dicCommnet = self.arrCommnet.object(at: (gesture.view?.tag)!) as! NSDictionary
        let dicUser = dicCommnet.value(forKey: "user") as! NSDictionary
        profileVC.dicUserDetail = dicUser
        profileVC.hidesBottomBarWhenPushed = false
        
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc func tapOnUserNameDetail(gesture:UITapGestureRecognizer)
    {
        var tempView = gesture.view as! UIView
        var cell : UITableViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UITableViewCell.self)
            {
                cell = (tempView as! UITableViewCell)
                break
            }
        }
        
        let indexPath = tblView.indexPath(for: cell)
        
        let array = self.dicCommentSectionWise.object(forKey: NSNumber.init(value: indexPath!.section)) as! NSArray
        
        let dicDetail = array.object(at: indexPath!.row) as! NSDictionary
        
        let dicUser = dicDetail.object(forKey: "user") as! NSDictionary
        
        let profileVC = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationItem.title = ""
        profileVC.dicUserDetail = dicUser
        profileVC.hidesBottomBarWhenPushed = false
        
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    @objc func tapOnUserProfile(gesture:UITapGestureRecognizer)
    {
        var tempView = gesture.view as! UIView
        var cell : UITableViewCell!
        
        while true {
            
            tempView = tempView.superview!
            
            if tempView.isKind(of: UITableViewCell.self)
            {
                cell = (tempView as! UITableViewCell)
                break
            }
        }
        
        let indexPath = tblView.indexPath(for: cell)
        
        let array = self.dicCommentSectionWise.object(forKey: NSNumber.init(value: indexPath!.section)) as! NSArray
        
        let dicDetail = array.object(at: indexPath!.row) as! NSDictionary
        
        let dicUser = dicDetail.object(forKey: "user") as! NSDictionary
        
        let profileVC = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        self.navigationItem.title = ""
        profileVC.dicUserDetail = dicUser
        profileVC.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
//        if text.count > 0 || text == "" {
//            btnSend.isEnabled = true
//        }
//        else{
//            btnSend.isEnabled = false
//        }
        
        if text == "\n"{
            
            textView.resignFirstResponder()
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        if !textView.text.isEmptyField {
            
            btnSend.isEnabled = true
        }
        else{
            
            btnSend.isEnabled = false
        }
    }
}

extension StringProtocol where Index == String.Index {
    var isEmptyField: Bool {
        return trimmingCharacters(in: .whitespaces) == ""
    }
}



extension String {
    var containsSpecialCharacter: Bool {
        let regex = "@"
        let testString = NSPredicate(format:"SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
}
