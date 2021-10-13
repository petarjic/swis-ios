//
//  SearchViewController.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 12/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SafariServices
import CoreLocation

class SearchViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,responseDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,CLLocationManagerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet var tblViewAll : UITableView!
    @IBOutlet var tblViewVideos : UITableView!
    @IBOutlet var tblViewNews : UITableView!
    @IBOutlet var tblViewImage : UITableView!
    
    @IBOutlet var tblViewAllTrending : UITableView!
    @IBOutlet var tblViewVideosTrending : UITableView!
    @IBOutlet var tblViewNewsTrending : UITableView!
    @IBOutlet var tblViewImageTreding : UITableView!
    
    @IBOutlet var TrendingView : UIView!
    
    @IBOutlet var txtSearch : UITextField!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet var mainView : UIView!
    @IBOutlet var btnCount : UIButton!
    
    @IBOutlet var imgWindow : UIImageView!
    @IBOutlet var btnClear : UIButton!
    
    var isStartSearch: Bool = false
    var arrSectionCount = 0
    
    var locationManager = CLLocationManager()
    var arrAllSearchBussiness = NSMutableArray()
    var arrAllSearchVideos = NSMutableArray()
    
    var arrAll = NSMutableArray()
    var arrNews = NSMutableArray()
    var arrImage = NSMutableArray()
    var arrVideo = NSMutableArray()
    
    var currentPageAll : NSInteger = 0
    var currentPageImage : NSInteger = 0
    var currentPageVideo : NSInteger = 0
    var currentPageNews : NSInteger = 0
    
    var isSwitchOn : Bool = true
    var selectedIndexHistory : NSInteger = -1
    
    var dicSaveSearch = NSMutableDictionary()
    var strSearchTerm : String = ""
    
    var arrAllTrending = NSMutableArray()
    var arrNewsTrending = NSMutableArray()
    var arrImageTrending = NSMutableArray()
    var arrVideoTrending = NSMutableArray()
    
    var currentPageAllTrending : NSInteger = 0
    var currentPageImageTrending : NSInteger = 0
    var currentPageVideoTrending : NSInteger = 0
    var currentPageNewsTrending : NSInteger = 0
    
    var totalPageAllTrending : NSInteger = 0
    var totalPageNewsTrending : NSInteger = 0
    var totalPageImageTrending : NSInteger = 0
    var totalPageVideoTrending : NSInteger = 0
    
    var totalPageAll : NSInteger = 0
    var totalPageNews : NSInteger = 0
    var totalPageImage : NSInteger = 0
    var totalPageVideo : NSInteger = 0
    var cellHeights: [IndexPath : CGFloat] = [:]
    var selectedSearchIndex : NSInteger = 0
    
    
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var strCountry : String = ""
    var strCity : String = ""
    var strZip : String = ""

    var isSearchFrom: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.hidesBottomBarWhenPushed = true
        
        imgWindow.image = imgWindow.image?.withRenderingMode(.alwaysTemplate)
        imgWindow.tintColor = UIColor.black
        
        collectionView.delegate = self
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
        
        viewSearch.layer.cornerRadius = viewSearch.frame.size.height/2
        viewSearch.layer.borderWidth = 1.5
        viewSearch.layer.borderColor = UIColor.gray.cgColor
        viewSearch.layer.masksToBounds = true
        
        tblViewAll.tableFooterView = UIView()
        tblViewVideos.tableFooterView = UIView()
        tblViewNews.tableFooterView = UIView()
        tblViewImage.tableFooterView = UIView()
        
        tblViewImage.rowHeight = UITableView.automaticDimension
        tblViewImage.estimatedRowHeight = 225
        
        tblViewNews.rowHeight = UITableView.automaticDimension
        tblViewNews.estimatedRowHeight = 200
        
        tblViewVideos.rowHeight = UITableView.automaticDimension
        tblViewVideos.estimatedRowHeight = 225
        
        tblViewAll.rowHeight = UITableView.automaticDimension
        tblViewAll.estimatedRowHeight = 95
        
        tblViewAllTrending.tableFooterView = UIView()
        tblViewVideosTrending.tableFooterView = UIView()
        tblViewNewsTrending.tableFooterView = UIView()
        tblViewImageTreding.tableFooterView = UIView()
        
        tblViewImageTreding.rowHeight = UITableView.automaticDimension
        tblViewImageTreding.estimatedRowHeight = 225
        
        tblViewAllTrending.rowHeight = UITableView.automaticDimension
        tblViewAllTrending.estimatedRowHeight = 390
        
        tblViewNewsTrending.rowHeight = UITableView.automaticDimension
        tblViewNewsTrending.estimatedRowHeight = 250
        
        IQKeyboardManager.shared.enable = false
        
        
        if UserDefaults.standard.object(forKey: "SaveSearch") != nil{
            
            btnCount.isHidden = false
            imgWindow.isHidden = false
        }
        
        if dicSaveSearch.count > 0{
            
            self.dicSaveSearch.setValue("1", forKey: "Recent")
            
            self.TrendingView.isHidden = true
            
            let arrObject = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "SaveSearch") as! Data) as! NSMutableArray
            
            txtSearch.text = dicSaveSearch.value(forKey: "searchText") as? String
            
            let strType = dicSaveSearch.value(forKey: "searchType") as? String
            
            //            if strType == "Image"{
            //                self.clickOnImage(sender: btnImage)
            //            }
            //            else if strType == "Video"{
            //                self.clickOnVideos(sender: btnVideo)
            //            }
            //            else if strType == "News"{
            //                self.clickOnNews(sender: btnNews)
            //            }
            //            else if strType == "All"{
            //
            //                tblViewVideos.isHidden = true
            //                tblViewImage.isHidden = true
            //                tblViewNews.isHidden = true
            //                tblViewAll.isHidden = false
            //
            //                self.searchAll(showProgress: false)
            //            }
            gotoTrending()
            isStartSearch = true
        }
        else if strSearchTerm != ""
        {
            txtSearch.text = self.strSearchTerm
            
            self.TrendingView.isHidden = true
            
            tblViewVideos.isHidden = true
            tblViewImage.isHidden = true
            tblViewNews.isHidden = true
            tblViewAll.isHidden = false
            
            self.searchAll(showProgress: false)
            gotoTrending()
            isStartSearch = true
        }
        else{
            
            // self.getAll(showProgress: false)
            gotoTrending()
        }
        
        //     self.setupTextField(textField: txtSearch)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
        
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = "Search"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.init(name: "FiraSans-Bold", size: 15),NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.kern:2.0]
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        let rightBarBtn = UIBarButtonItem.init(image: UIImage.init(named: "menu"), style: .plain, target: self, action: #selector(clickOnMenu))
        //    self.navigationItem.rightBarButtonItem = rightBarBtn
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back-icon.png"), style: .plain, target: self, action: #selector(self.clickOnBack))
        
        if UserDefaults.standard.object(forKey: "SaveSearch") != nil {
            
            let arrObject = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "SaveSearch") as! Data) as! NSMutableArray
            
            if arrObject.count > 0{
                
                let predicate = NSPredicate.init(format: "searchType!=%@","Home")
                let filtered = arrObject.filtered(using: predicate) as! NSArray
                
                btnCount.isHidden = false
                imgWindow.isHidden = false
                btnCount.setTitle("\(filtered.count)", for: UIControl.State.normal)
                
            }else{
                btnCount.isHidden = true
                imgWindow.isHidden = true
            }
            
        }
        else{
            btnCount.isHidden = true
            imgWindow.isHidden = true
        }
        
    }
    
    @objc func openHome()
    {
        self.setupSearchOnBackground()
        
        
        //self.navigationController?.popViewController(animated: false)
        if navigationController?.viewControllers.count ?? 0 > 1
        {
            if let object = navigationController?.viewControllers[(navigationController?.viewControllers.count ?? 0) - 2] {
                print("\(object)")
                if object.isKind(of: ProfileViewController.classForCoder()) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                else if object.isKind(of: LocationSearchVC.classForCoder()) {
                    self.navigationController?.popToRootViewController(animated: true)
                }
                else{
                    self.navigationController?.popViewController(animated: false)
                    appDelegate.setHome()
                }
            }else{
                self.navigationController?.popViewController(animated: false)
                appDelegate.setHome()
            }
        }
        else{
            self.navigationController?.popViewController(animated: false)
            appDelegate.setHome()
        }
        
        
        //appDelegate.setHome()
        
    }
    
    @objc func setupSearchOnBackground()
    {
        self.setSaveSearch()
        
        var arrSaveSearch = NSMutableArray()
        
        if UserDefaults.standard.object(forKey: "SaveSearch") != nil{
            
            let arrObject = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "SaveSearch") as! Data) as! NSMutableArray
            
            arrSaveSearch = NSMutableArray.init(array: arrObject)
        }
        
        for index in 0..<arrSaveSearch.count{
            let dic = arrSaveSearch.object(at: index) as! NSMutableDictionary
            dic.setValue("0", forKey: "Recent")
            arrSaveSearch.replaceObject(at: index, with: dic)
        }
        
        let data = NSKeyedArchiver.archivedData(withRootObject: arrSaveSearch)
        UserDefaults.standard.setValue(data, forKey: "SaveSearch")
        UserDefaults.standard.synchronize()
    }
    
    @objc func clickOnBack()
    {
        self.perform(#selector(self.openHome), on: Thread.main, with: nil, waitUntilDone: true)
    }
    
    @objc func clickOnMenu(){
        
        let homeMenuVC = objMainSB.instantiateViewController(withIdentifier: "HomeMainMenuVC") as! HomeMainMenuVC
        
        self.navigationController?.pushViewController(homeMenuVC, animated: true)
        
    }
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            if Response.value(forKey: "responseCode") as? Int == 200{
                
                if ServiceName == "searchAll"
                {
                    print(Response)
                    
                    let arrayAllVideo = (Response.object(forKey: "videos") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    let arrayAll = (Response.object(forKey: "searchResults") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    if self.currentPageAll == 0 {
                        self.arrAllSearchVideos.addObjects(from: arrayAllVideo as! [Any])
                    }
                    
                    self.arrAll.addObjects(from: arrayAll as! [Any])
                    self.currentPageAll = Response.value(forKey: "nextOffset") as! Int
                    self.totalPageAll = (Response.value(forKey: "total_page") as! NSNumber).intValue
                    
                    self.perform(#selector(self.setSaveSearch), on: Thread.main, with: nil, waitUntilDone: true)
                    
                    // self.perform(#selector(self.setSaveSearch), with: nil, afterDelay: 0.0)
                    
                    if self.arrAllSearchBussiness.count == 0 && self.arrAll.count == 0 && self.arrAllSearchVideos.count == 0{
                        self.view.makeToast("No data found")
                    }
                    
                    self.tblViewAll.reloadData()
                    if self.currentPageAll == 1
                    {
                        self.tblViewAll.scrollToTop(animated: false)
                    }
                    //                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: UInt64(5.0)), execute: {
                    //
                    //                        self.tblViewAll.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: false)
                    //
                    //                    })
                    
                }
                else if ServiceName == "searchImage"
                {
                    let arrayImage = (Response.object(forKey: "searchResults") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    self.arrImage.addObjects(from: arrayImage as! [Any])
                    self.currentPageImage = Response.value(forKey: "nextOffset") as! Int
                    self.totalPageImage = (Response.value(forKey: "total_page") as! NSNumber).intValue
                    
                    self.perform(#selector(self.setSaveSearch), on: Thread.main, with: nil, waitUntilDone: true)
                    
                    // self.perform(#selector(self.setSaveSearch), with: nil, afterDelay: 0.0)
                    
                    if self.arrImage.count == 0{
                        self.view.makeToast("No data found")
                    }
                    
                    self.tblViewImage.reloadData()
                    if self.currentPageImage == 1
                    {
                        self.tblViewImage.scrollToTop(animated: false)
                    }
                    
                    //                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: UInt64(5.0)), execute: {
                    //
                    //                        self.tblViewImage.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: false)
                    //
                    //                    })
                    
                }
                else if ServiceName == "searchVideo"
                {
                    let arrayVideo = (Response.object(forKey: "searchResults") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    self.arrVideo.addObjects(from: arrayVideo as! [Any])
                    self.currentPageVideo = Response.value(forKey: "nextOffset") as! Int
                    self.totalPageVideo = (Response.value(forKey: "total_page") as! NSNumber).intValue
                    
                    self.perform(#selector(self.setSaveSearch), on: Thread.main, with: nil, waitUntilDone: true)
                    
                    //  self.perform(#selector(self.setSaveSearch), with: nil, afterDelay: 2.0)
                    
                    if self.arrVideo.count == 0{
                        self.view.makeToast("No data found")
                    }
                    
                    self.tblViewVideos.reloadData()
                    if self.currentPageVideo == 1
                    {
                        self.tblViewVideos.scrollToTop(animated: false)
                    }
                    
                    //                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: UInt64(5.0)), execute: {
                    //
                    //                        self.tblViewVideos.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: false)
                    //
                    //                    })
                    
                }
                else if ServiceName == "searchNews"{
                    print(Response)
                    let arrayNews = (Response.object(forKey: "searchResults") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    self.arrNews.addObjects(from: arrayNews as! [Any])
                    if(Response.value(forKey: "nextOffset") as! AnyObject).isKind(of: NSNumber.self){
                     self.currentPageNews = Response.value(forKey: "nextOffset") as! Int
                    }
                    else{
                        self.currentPageNews = (Response.value(forKey: "nextOffset") as! NSString).integerValue
                    }
                    self.totalPageNews = (Response.value(forKey: "total_page") as! NSNumber).intValue
                    
                    self.perform(#selector(self.setSaveSearch), on: Thread.main, with: nil, waitUntilDone: true)
                    
                    // self.perform(#selector(self.setSaveSearch), with: nil, afterDelay: 0.0)
                    
                    if self.arrNews.count == 0{
                        self.view.makeToast("No data found")
                    }
                    
                    self.tblViewNews.reloadData()
                    if self.currentPageNews == 1
                    {
                        self.tblViewNews.scrollToTop(animated: false)
                    }
                    //
                    //                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.init(uptimeNanoseconds: UInt64(5.0)), execute: {
                    //
                    //                        self.tblViewNews.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: false)
                    //
                    //                    })
                    
                }
                else if ServiceName == "updateProfile"
                {
                    
                    appDelegate.dicLoginDetail = Response.object(forKey: "user") as? NSDictionary
                    
                    let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
                    
                    UserDefaults.standard.set(data, forKey: "LoginDetail")
                    UserDefaults.standard.synchronize()
                }
                else if ServiceName == "trendingAll"
                {
                    print(Response)
                    let arrayAll = (Response.object(forKey: "searchResults") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    self.arrAllTrending.addObjects(from: arrayAll as! [Any])
                    self.currentPageAllTrending = Response.value(forKey: "nextOffset") as! Int
                    self.totalPageAllTrending = (Response.value(forKey: "total_page") as! NSNumber).intValue
                    
                    self.tblViewAllTrending.reloadData()
                    
                }
                else if ServiceName == "trendingImage"
                {
                    
                    let arrayImage = (Response.object(forKey: "searchResults") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    self.arrImageTrending.addObjects(from: arrayImage as! [Any])
                    self.currentPageImageTrending = Response.value(forKey: "nextOffset") as! Int
                    self.totalPageImageTrending = (Response.value(forKey: "total_page") as! NSNumber).intValue
                    
                    self.tblViewImageTreding.reloadData()
                }
                else if ServiceName == "trendingVideo"
                {
                    
                    let arrayVideo = (Response.object(forKey: "searchResults") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    self.arrVideoTrending.addObjects(from: arrayVideo as! [Any])
                    self.currentPageVideoTrending = Response.value(forKey: "nextOffset") as! Int
                    self.totalPageVideoTrending = (Response.value(forKey: "total_page") as! NSNumber).intValue
                    
                    self.tblViewVideosTrending.reloadData()
                }
                else if ServiceName == "trendingNews"{
                    
                    let arrayNews = (Response.object(forKey: "searchResults") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    self.arrNewsTrending.addObjects(from: arrayNews as! [Any])
                    self.currentPageNewsTrending = Response.value(forKey: "nextOffset") as! Int
                    self.totalPageNewsTrending = (Response.value(forKey: "total_page") as! NSNumber).intValue
                    
                    self.tblViewNewsTrending.reloadData()
                } else if ServiceName == "searchAllNewAPI" {
                    
                    print(Response)
                    
                    self.tblViewAll.isHidden = false
                    let arrayAll = (Response.object(forKey: "places") as! NSArray).mutableCopy() as! NSMutableArray
                    
                    self.arrAllSearchBussiness.addObjects(from: arrayAll as! [Any])
                    //                    self.currentPageAll = Response.value(forKey: "nextOffset") as! Int
                    //                    self.totalPageAll = (Response.value(forKey: "total_page") as! NSNumber).intValue
                    
                    self.perform(#selector(self.setSaveSearch), on: Thread.main, with: nil, waitUntilDone: true)
                    
                    // self.perform(#selector(self.setSaveSearch), with: nil, afterDelay: 0.0)
                    
                    //                    if self.arrAllSearchBussiness.count == 0 && self.arrAll.count == 0 && self.arrAllSearchVideos.count == 0{
                    //                        self.view.makeToast("No data found")
                    //                    }
                    
                    self.tblViewAll.reloadData()
                    self.tblViewAll.scrollToTop(animated: false)
                } else if ServiceName == "update-location"{
                    
                    appDelegate.dicLoginDetail = Response.object(forKey: "user") as? NSDictionary
                    
                    let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
                    
                    UserDefaults.standard.set(data, forKey: "LoginDetail")
                    UserDefaults.standard.synchronize()
                    
                }
                else{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadPost"), object: nil, userInfo: [:])
                    
                }
                
            } else {
                self.view.makeToast(Response.value(forKey: "responseMessage") as? String)
            }
            
        }
    }
    
    @objc func setSaveSearch()
    {
        if (self.arrAll.count > 0 || self.arrImage.count > 0 || self.arrVideo.count > 0 || self.arrNews.count > 0)
        {
            var image : UIImage!
            var searchType : String = ""
            
            if !self.tblViewAll.isHidden{
                searchType = "All"
            }
            else if !self.tblViewImage.isHidden{
                searchType = "Image"
            }
            else if !self.tblViewVideos.isHidden{
                searchType = "Video"
            }
            else{
                searchType = "News"
            }
            
            image = self.mainView.takeScreenshot()
            
            var arrSaveSearch = NSMutableArray()
            
            if UserDefaults.standard.object(forKey: "SaveSearch") != nil {
                
                let arrObject = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "SaveSearch") as! Data) as! NSMutableArray
                
                arrSaveSearch = NSMutableArray.init(array: arrObject)
                
            }
            
            if selectedIndexHistory != -1{
                
                var dicRecentSearch = arrSaveSearch.object(at: selectedIndexHistory) as! NSMutableDictionary
                dicRecentSearch.setValue(image, forKey: "searchImage")
                dicRecentSearch.setValue(self.txtSearch.text!, forKey: "searchText")
                dicRecentSearch.setValue(searchType, forKey: "searchType")
                
                arrSaveSearch.replaceObject(at: selectedIndexHistory, with: dicRecentSearch)
                
            }
            else{
                
                let predicate = NSPredicate.init(format: "Recent=%@","1")
                let filteredArray = arrSaveSearch.filtered(using: predicate) as NSArray
                
                if filteredArray.count > 0{
                    arrSaveSearch.remove(filteredArray.object(at: 0))
                }
                
                let dicRecentSearch = NSMutableDictionary()
                dicRecentSearch.setValue(image, forKey: "searchImage")
                dicRecentSearch.setValue(self.txtSearch.text!, forKey: "searchText")
                dicRecentSearch.setValue(searchType, forKey: "searchType")
                dicRecentSearch.setValue("1", forKey: "Recent")
                
                arrSaveSearch.insert(dicRecentSearch, at: 0)
            }
            
            let data = NSKeyedArchiver.archivedData(withRootObject: arrSaveSearch)
            UserDefaults.standard.setValue(data, forKey: "SaveSearch")
            UserDefaults.standard.synchronize()
            
            self.imgWindow.isHidden = false
            self.btnCount.isHidden = false
            self.btnCount.setTitle("\(arrSaveSearch.count)", for: UIControl.State.normal)
        }
        
    }
    
    
    //MARK:- TableView Delegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if TrendingView.isHidden{
            
            if tableView == tblViewAll{
                
                return 3
            }
            return 1
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if TrendingView.isHidden
        {
            if tableView == tblViewAll {
                
                if section == 0 {
                    return self.arrAllSearchBussiness.count
                } else if section == 1 {
                    return 1
                } else {
                    
                    if currentPageAll < totalPageAll {
                        return self.arrAll.count + 1
                    }
                    
                    return self.arrAll.count
                }
                
            }
            else if tableView == tblViewNews{
                if currentPageNews < totalPageNews{
                    return self.arrNews.count + 1
                }
                
                return self.arrNews.count
            }
            else if tableView == tblViewImage{
                if currentPageImage < totalPageImage{
                    return self.arrImage.count + 1
                }
                return self.arrImage.count
            }
            else{
                if currentPageVideo < totalPageVideo{
                    return self.arrVideo.count + 1
                }
                
                return self.arrVideo.count
            }
        }
        else{
            if tableView == tblViewAllTrending{
                if currentPageAllTrending < totalPageAllTrending{
                    return self.arrAllTrending.count + 1
                }
                
                return self.arrAllTrending.count
            }
            else if tableView == tblViewNewsTrending{
                if currentPageNewsTrending < totalPageNewsTrending{
                    return self.arrNewsTrending.count + 1
                }
                
                return self.arrNewsTrending.count
            }
            else if tableView == tblViewImageTreding{
                
                if currentPageImageTrending < totalPageImageTrending{
                    return self.arrImageTrending.count + 1
                }
                
                return self.arrImageTrending.count
            }
            else{
                
                if currentPageVideoTrending < totalPageVideoTrending{
                    return self.arrVideoTrending.count + 1
                }
                
                return self.arrVideoTrending.count
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == tblViewAll {
            
            if indexPath.section == 0 {
                if indexPath.row < self.arrAllSearchBussiness.count{
                    return setupCell(tableView: tableView, indexPath: indexPath)
                }
                else{
                    return self.loadingCellSearching()!
                }
            } else if indexPath.section == 1 {
                if indexPath.row < self.arrAllSearchVideos.count{
                    return setupCell(tableView: tableView, indexPath: indexPath)
                }
                else{
                    return self.loadingCellSearching()!
                }
            } else {
                
                if indexPath.row < self.arrAll.count{
                    return setupCell(tableView: tableView, indexPath: indexPath)
                }
                else{
                    return self.loadingCellSearching()!
                }
            }
            
        }
        else if tableView == tblViewNews{
            if indexPath.row < self.arrNews.count{
                return setupCell(tableView: tableView, indexPath: indexPath)
            }
            else{
                return self.loadingCellSearching()!
            }
        }
        else if tableView == tblViewImage{
            if indexPath.row < self.arrImage.count{
                return setupCell(tableView: tableView, indexPath: indexPath)
            }
            else{
                return self.loadingCellSearching()!
            }
        }
        else if tableView == tblViewVideos{
            if indexPath.row < self.arrVideo.count{
                return setupCell(tableView: tableView, indexPath: indexPath)
            }
            else{
                return self.loadingCellSearching()!
            }
        }
        else if tableView == tblViewAllTrending{
            
            if indexPath.row < self.arrAllTrending.count{
                return setupCell(tableView: tableView, indexPath: indexPath)
            }
            else{
                return self.loadingCell()!
            }
        }
        else if tableView == tblViewNewsTrending{
            if indexPath.row < self.arrNewsTrending.count{
                return setupCell(tableView: tableView, indexPath: indexPath)
            }
            else{
                return self.loadingCell()!
            }
        }
        else if tableView == tblViewImageTreding{
            if indexPath.row < self.arrImageTrending.count{
                return setupCell(tableView: tableView, indexPath: indexPath)
            }
            else{
                return self.loadingCell()!
            }
        }
        else {
            if indexPath.row < self.arrVideoTrending.count{
                return setupCell(tableView: tableView, indexPath: indexPath)
            }
            else{
                return self.loadingCell()!
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cellHeights[indexPath] = cell.frame.size.height
        
        if cell.tag == 10{
            
            if tableView == tblViewAllTrending
            {
                self.getAll(showProgress: false)
            }
            else if tableView == tblViewNewsTrending
            {
                self.getAllNews(showProgress: false)
            }
            else if tableView == tblViewImageTreding
            {
                self.getImages(showProgress: false)
            }
            else if tableView == tblViewVideosTrending
            {
                self.getVideos(showProgress: false)
            }
            else if tableView == tblViewAll
            {
                
                if indexPath.row < self.arrAll.count{
                    
                }
                else{
                    self.searchAll(showProgress: false)
                }
            }
            else if tableView == tblViewNews
            {
                self.searchNews(showProgress: false)
            }
            else if tableView == tblViewImage
            {
                self.searchImage(showProgress: false)
            }
            else if tableView == tblViewVideos
            {
                self.searchVideo(showProgress: false)
            }
            
        }
    }
    
    func loadingCell() -> UITableViewCell? {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = CGPoint.init(x: tblViewAll.frame.size.width/2, y: cell.frame.size.height/2)
        cell.addSubview(activityIndicator)
        
        if arrAllSearchVideos.count == 0 || arrAllSearchBussiness.count == 0 {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
        
        cell.tag = 10
        
        return cell
    }
    
    func loadingCellSearching() -> UITableViewCell? {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.center = CGPoint.init(x: tblViewAll.frame.size.width/2, y: cell.frame.size.height/2)
        cell.addSubview(activityIndicator)
        
        if arrAllSearchVideos.count == 0 || arrAllSearchBussiness.count == 0 {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
        
        cell.tag = 10
        
        return cell
    }
    
    func setupCell(tableView:UITableView,indexPath:IndexPath)->UITableViewCell
    {
        if self.TrendingView.isHidden {
            
            if tableView == tblViewAll {
                
                if indexPath.section == 0 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SearchBussinessListCell", for: indexPath)
                    
                    let view = cell.contentView.viewWithTag(1000) as! UIView
                    view.layer.borderColor = UIColor(red: 223/255, green: 226/255, blue: 226/255, alpha: 1).cgColor
                    view.layer.borderWidth = 1
                    
                    //                    view.layer.shadowColor = UIColor.gray.cgColor
                    //                    view.layer.shadowOpacity = 0.5
                    //                    view.layer.shadowOffset = CGSize.zero
                    //                    view.layer.shadowRadius = 6
                    
                    let viewLine = cell.contentView.viewWithTag(1005) as! UIView
                    
                    let lastRowIndex = tableView.numberOfRows(inSection: tableView.numberOfSections-1)
                    
                    if indexPath.row == 0 {
                        if #available(iOS 11.0, *) {
                            view.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
                        } else {
                            // Fallback on earlier versions
                        }
                        view.layer.cornerRadius = 5
                    }
                    
                    let dicAll = self.arrAllSearchBussiness.object(at: indexPath.row) as! NSDictionary
                    
                    
                    let btnCallClick = cell.contentView.viewWithTag(2000) as! UIButton
                    let btnDirectionClick = cell.contentView.viewWithTag(2001) as! UIButton
                    let btnWebsiteClick = cell.contentView.viewWithTag(2002) as! UIButton
                    
                    btnCallClick.addTarget(self, action: #selector(self.clickOnCallSearch(sender:)), for: UIControl.Event.touchUpInside)
                    
                    btnDirectionClick.addTarget(self, action: #selector(self.clickOnDirectionSearch(sender:)), for: UIControl.Event.touchUpInside)
                    
                    btnWebsiteClick.addTarget(self, action: #selector(self.clickOnWebsiteSearch(sender:)), for: UIControl.Event.touchUpInside)
                    
                    let roundView = cell.contentView.viewWithTag(1001) as! UIView
                    let lblCountNumber = cell.contentView.viewWithTag(1002) as! UILabel
                    let lblTitle = cell.contentView.viewWithTag(1003) as! UILabel
                    let lblAddress = cell.contentView.viewWithTag(1004) as! UILabel
                    let lineView = cell.contentView.viewWithTag(1005) as! UIView
                    
                    
                    roundView.layer.cornerRadius = roundView.frame.height / 2
                    roundView.clipsToBounds = true
                    
                    lblCountNumber.text = "\(indexPath.row + 1)"
                    
                    lblTitle.text = dicAll.value(forKey: "name") as? String
                    
                    let dicAddress = dicAll.value(forKey: "address") as? NSDictionary
                    
                    let locality = dicAddress?.value(forKey: "locality") as? String
                    let neighborhood = dicAddress?.value(forKey: "neighborhood") as? String
                    
                    if neighborhood != "" {
                        lblAddress.text = "\(neighborhood ?? ""), \(locality ?? "")"
                    } else {
                        lblAddress.text = "\(locality ?? "")"
                    }
                    
                    //                    lblAddress.text = dicAddress?.value(forKey: "text") as? String
                    
                    cell.selectionStyle = .none
                    
                    return cell
                    
                } else if indexPath.section == 1 {
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
                    
                    //                    let view = cell.contentView.viewWithTag(1000) as! UIView
                    //                    view.layer.cornerRadius = 5
                    //
                    //                    view.layer.shadowColor = UIColor.gray.cgColor
                    //                    view.layer.shadowOpacity = 0.5
                    //                    view.layer.shadowOffset = CGSize.zero
                    //                    view.layer.shadowRadius = 6
                    
                    let collectionView = cell.contentView.viewWithTag(7000) as! UICollectionView
                    
                    collectionView.delegate = self
                    collectionView.dataSource = self
                    
                    collectionView.reloadData()
                    
                    //                    let btnVideo = collectionView.viewWithTag(100) as! UIButton
                    //                    btnVideo.addTarget(self, action: #selector(self.clickOnVideoFromSearch(sender:)), for: UIControl.Event.touchUpInside)
                    //
                    //                    let dicVideo = self.arrAllSearchVideos.object(at: indexPath.row) as! NSDictionary
                    //
                    //                    let lblTitle = collectionView.viewWithTag(1002) as! UILabel
                    //                    let lblWeb = collectionView.viewWithTag(1003) as! UILabel
                    //                    let imgView = collectionView.viewWithTag(1004) as! UIImageView
                    //
                    //                    lblTitle.text  = dicVideo.value(forKey: "title") as? String
                    //                    lblWeb.text  = dicVideo.value(forKey: "website") as? String
                    //                    let imgURL = dicVideo.value(forKey: "thumbnailUrl") as? String
                    //
                    //                    imgView.sd_setImage(with: URL.init(string: imgURL!), placeholderImage: nil, options: .continueInBackground, completed: nil)
                    
                    cell.selectionStyle = .none
                    
                    return cell
                    
                    
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                    
                    let view = cell.contentView.viewWithTag(1000) as! UIView
                    view.layer.cornerRadius = 5
                    view.layer.borderColor = UIColor(red: 223/255, green: 226/255, blue: 226/255, alpha: 1).cgColor
                    view.layer.borderWidth = 1
                    
                    view.layer.shadowColor = UIColor.lightGray.cgColor
                    view.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
                    view.layer.shadowOpacity = 1.0
                    view.layer.shadowRadius = 0.0
                    view.layer.masksToBounds = false
                    
                    //                    view.layer.shadowColor = UIColor.gray.cgColor
                    //                    view.layer.shadowOpacity = 0.5
                    //                    view.layer.shadowOffset = CGSize.zero
                    //                    view.layer.shadowRadius = 6
                    
                    let dicAll = self.arrAll.object(at: indexPath.row) as! NSDictionary
                    
                    let lblTitle = cell.contentView.viewWithTag(1001) as! UILabel
                    let lblWeb = cell.contentView.viewWithTag(1002) as! UILabel
                    let lblDesc = cell.contentView.viewWithTag(1003) as! UILabel
                    
                    let lblDesc1 = cell.contentView.viewWithTag(1005) as! UITextView
                    
                    lblDesc1.textContainer.maximumNumberOfLines = 5
                    lblTitle.text  = dicAll.value(forKey: "title") as? String
                    lblWeb.text  = dicAll.value(forKey: "website") as? String
                    lblDesc.text  = dicAll.value(forKey: "description") as? String
                    lblDesc1.text  = dicAll.value(forKey: "description") as? String
                    
                    cell.selectionStyle = .none
                    
                    return cell
                    
                }
                
            }
            else if tableView == tblViewNews
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
                
                let dicNews = self.arrNews.object(at: indexPath.row) as! NSDictionary
                
                let lblTitle = cell.contentView.viewWithTag(1001) as! UILabel
                let lblTitle1 = cell.contentView.viewWithTag(2001) as! UITextView
                
                
                let imgView = cell.contentView.viewWithTag(1002) as! UIImageView
                let lblProvider = cell.contentView.viewWithTag(1003) as! UILabel
                let lblTime = cell.contentView.viewWithTag(1004) as! UILabel
                let ImgViewDescript = cell.contentView.viewWithTag(1005) as! UIImageView
                
                lblTitle1.textContainer.maximumNumberOfLines = 2
                
                let view = cell.contentView.viewWithTag(1000) as! UIView
                view.layer.cornerRadius = 5
                
                view.layer.shadowColor = UIColor.gray.cgColor
                view.layer.shadowOpacity = 0.5
                view.layer.shadowOffset = CGSize.zero
                view.layer.shadowRadius = 6
                
                view.layer.shadowColor = UIColor.lightGray.cgColor
                view.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
                view.layer.shadowOpacity = 1.0
                view.layer.shadowRadius = 0.0
                view.layer.masksToBounds = false
                
                lblProvider.frame = CGRect.init(x: 45, y: 353.5, width: 150, height: 21)
                
                
                
                
                lblProvider.text = dicNews.value(forKey: "provider") as? String
                lblTime.text = dicNews.value(forKey: "datetime") as? String
                
                lblProvider.translatesAutoresizingMaskIntoConstraints = true
                lblProvider.sizeToFit()
                lblProvider.frame = CGRect.init(x: 45, y: 353.5, width: lblProvider.frame.size.width, height: lblProvider.frame.size.height)
                
                lblTime.translatesAutoresizingMaskIntoConstraints = true
                lblTime.frame = CGRect.init(x: lblProvider.frame.origin.x + lblProvider.frame.size.width + 10, y: 353.5, width: 100, height: lblProvider.frame.size.height)
                
                
                //---
                let contentLabel = cell.contentView.viewWithTag(1100) as! UILabel
                let viewLabel = cell.contentView.viewWithTag(1220) as! UIView
                let strContentMsg = dicNews.value(forKey: "title") as? String
                if (dicNews.value(forKey: "image") as! String) == ""
                {
                    viewLabel.isHidden = false
                    contentLabel.isHidden = false
                    imgView.isHidden = true
                    contentLabel.text = dicNews.value(forKey: "description") as? String
                    
                    contentLabel.setLineHeight(lineHeight: 1.2)
                    
                    lblTitle1.text  = strContentMsg
                    lblTitle.text  = strContentMsg
                    
                }
                else
                {
                    viewLabel.isHidden = true
                    contentLabel.isHidden = true
                    imgView.isHidden = false
                    
                    lblTitle1.text  = dicNews.value(forKey: "description") as? String
                    lblTitle.text  = dicNews.value(forKey: "description") as? String
                    
                    imgView.sd_setImage(with: URL.init(string: dicNews.value(forKey: "image") as! String))
                    //imgView.sd_setImage(with: URL.init(string: dicNews.value(forKey: "image") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
                    
                }
                
                ImgViewDescript.sd_setImage(with: URL.init(string: dicNews.value(forKey: "provider_icon") as! String))
                //ImgViewDescript.sd_setImage(with: URL.init(string: dicNews.value(forKey: "provider_icon") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
                
                cell.selectionStyle = .none
                
                return cell
            }
            else if tableView == tblViewImage
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
                
                let view = cell.contentView.viewWithTag(1000) as! UIView
                view.layer.cornerRadius = 5
                
                view.layer.shadowColor = UIColor.gray.cgColor
                view.layer.shadowOpacity = 0.5
                view.layer.shadowOffset = CGSize.zero
                view.layer.shadowRadius = 6
                
                //                view.layer.shadowColor = UIColor.lightGray.cgColor
                //                view.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
                //                view.layer.shadowOpacity = 1.0
                //                view.layer.shadowRadius = 0.0
                //                view.layer.masksToBounds = false
                
                let lblTitle = cell.contentView.viewWithTag(1002) as! UILabel
                let lblWeb = cell.contentView.viewWithTag(1003) as! UILabel
                let imgView = cell.contentView.viewWithTag(1004) as! UIImageView
                
                let dicImage = self.arrImage.object(at: indexPath.row) as! NSDictionary
                
                lblTitle.text  = dicImage.value(forKey: "title") as? String
                lblWeb.text  = dicImage.value(forKey: "website") as? String
                
                imgView.sd_setImage(with: URL.init(string: dicImage.value(forKey: "image") as! String))
                //imgView.sd_setImage(with: URL.init(string: dicImage.value(forKey: "image") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
                
                cell.selectionStyle = .none
                
                return cell
            }
            else if tableView == tblViewVideos
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath)
                
                let view = cell.contentView.viewWithTag(1000) as! UIView
                view.layer.cornerRadius = 5
                
                view.layer.shadowColor = UIColor.gray.cgColor
                view.layer.shadowOpacity = 0.5
                view.layer.shadowOffset = CGSize.zero
                view.layer.shadowRadius = 6
                
                //                view.layer.shadowColor = UIColor.lightGray.cgColor
                //                view.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
                //                view.layer.shadowOpacity = 1.0
                //                view.layer.shadowRadius = 0.0
                //                view.layer.masksToBounds = false
                
                let btnVideo = cell.contentView.viewWithTag(100) as! UIButton
                btnVideo.addTarget(self, action: #selector(self.clickOnVideo(sender:)), for: UIControl.Event.touchUpInside)
                
                let dicVideo = self.arrVideo.object(at: indexPath.row) as! NSDictionary
                
                let lblTitle = cell.contentView.viewWithTag(1002) as! UILabel
                let lblWeb = cell.contentView.viewWithTag(1003) as! UILabel
                let imgView = cell.contentView.viewWithTag(1004) as! UIImageView
                
                lblTitle.text  = dicVideo.value(forKey: "title") as? String
                lblWeb.text  = dicVideo.value(forKey: "website") as? String
                
                imgView.sd_setImage(with: URL.init(string: dicVideo.value(forKey: "thumbnailUrl") as! String))
                //imgView.sd_setImage(with: URL.init(string: dicVideo.value(forKey: "thumbnailUrl") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
                
                cell.selectionStyle = .none
                
                
                return cell
            }
            
            return UITableViewCell()
        }
        else{
            if tableView == tblViewAllTrending {
                
                if indexPath.row < 3 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "NewTraddingTopCell", for: indexPath)
                    
                    let dicAll = self.arrAllTrending.object(at: indexPath.row) as! NSDictionary
                    
                    let lblTitle = cell.contentView.viewWithTag(1001) as! UILabel
                    let imgView = cell.contentView.viewWithTag(1002) as! UIImageView
                    let lblProvider = cell.contentView.viewWithTag(1003) as! UILabel
                    //         let ImgViewDescript = cell.contentView.viewWithTag(1005) as! UIImageView
                    
                    let view = cell.contentView.viewWithTag(1000) as! UIView
                    
                    let viewBottomLine = cell.contentView.viewWithTag(9000) as! UIView
                    
                    view.layer.borderColor = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1).cgColor
                    view.layer.borderWidth = 1
                    
                    //                    view.layer.shadowColor = UIColor.gray.cgColor
                    //                    view.layer.shadowOpacity = 0.5
                    //                    view.layer.shadowOffset = CGSize.zero
                    //                    view.layer.shadowRadius = 6
                    
                    if indexPath.row == 0 {
                        if #available(iOS 11.0, *) {
                            view.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
                        } else {
                            // Fallback on earlier versions
                        }
                        view.layer.cornerRadius = 5
                        viewBottomLine.isHidden = true
                    } else if indexPath.row == 2 {
                        if #available(iOS 11.0, *) {
                            view.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
                        } else {
                            // Fallback on earlier versions
                        }
                        view.layer.cornerRadius = 5
                        viewBottomLine.isHidden = false
                        
                    } else {
                        viewBottomLine.isHidden = true
                        
                    }
                    
                    lblTitle.text  = dicAll.value(forKey: "description") as? String
                    lblProvider.text = dicAll.value(forKey: "provider") as? String
                    
                    let viewLine1 = cell.contentView.viewWithTag(5000) as! UIView
                    
                    //                    if indexPath.row == 2 {
                    //                        viewLine1.isHidden = true
                    //                    } else {
                    //                        viewLine1.isHidden = false
                    //                    }
                    
                    //                    lblProvider.translatesAutoresizingMaskIntoConstraints = true
                    //                    lblProvider.sizeToFit()
                    
                    imgView.sd_setImage(with: URL.init(string: dicAll.value(forKey: "image") as! String))
                    //imgView.sd_setImage(with: URL.init(string: dicAll.value(forKey: "image") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
                    
                    //
                    cell.selectionStyle = .none
                    
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
                    
                    let dicAll = self.arrAllTrending.object(at: indexPath.row) as! NSDictionary
                    
                    let lblTitle = cell.contentView.viewWithTag(1001) as! UILabel
                    let imgView = cell.contentView.viewWithTag(1002) as! UIImageView
                    let lblProvider = cell.contentView.viewWithTag(1003) as! UILabel
                    //     let lblTime = cell.contentView.viewWithTag(1004) as! UILabel
                    //  let ImgViewDescript = cell.contentView.viewWithTag(1005) as! UIImageView
                    
                    let view = cell.contentView.viewWithTag(1000) as! UIView
                    view.layer.cornerRadius = 5
                    //       view.clipsToBounds = true
                    
                    view.layer.borderColor = UIColor(red: 223/255, green: 226/255, blue: 226/255, alpha: 1).cgColor
                    view.layer.borderWidth = 1
                    
                    view.layer.shadowColor = UIColor.lightGray.cgColor
                    view.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
                    view.layer.shadowOpacity = 1.0
                    view.layer.shadowRadius = 0.0
                    view.layer.masksToBounds = false
                    
                    //                    view.layer.shadowColor = UIColor.gray.cgColor
                    //                    view.layer.shadowOpacity = 0.5
                    //                    view.layer.shadowOffset = CGSize.zero
                    //                    view.layer.shadowRadius = 6
                    
                    //     lblProvider.frame = CGRect.init(x: 45, y: 353.5, width: 150, height: 21)
                    
                    lblTitle.text  = dicAll.value(forKey: "description") as? String
                    lblProvider.text = dicAll.value(forKey: "provider") as? String
                    //       lblTime.text = dicAll.value(forKey: "datetime") as? String
                    
                    //                    lblProvider.translatesAutoresizingMaskIntoConstraints = true
                    //                    lblProvider.sizeToFit()
                    //                    lblProvider.frame = CGRect.init(x: 45, y: 353.5, width: lblProvider.frame.size.width, height: lblProvider.frame.size.height)
                    
                    //                    lblTime.translatesAutoresizingMaskIntoConstraints = true
                    //                    lblTime.frame = CGRect.init(x: lblProvider.frame.origin.x + lblProvider.frame.size.width + 10, y: 353.5, width: 110, height: lblProvider.frame.size.height)
                    
                    imgView.sd_setImage(with: URL.init(string: dicAll.value(forKey: "image") as! String))
                    //imgView.sd_setImage(with: URL.init(string: dicAll.value(forKey: "image") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
                    //
                    //                    ImgViewDescript.sd_setImage(with: URL.init(string: dicAll.value(forKey: "provider_icon") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
                    
                    cell.selectionStyle = .none
                    
                    return cell
                }
                
                
            }
            else if tableView == tblViewNewsTrending
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath)
                
                let dicNews = self.arrNewsTrending.object(at: indexPath.row) as! NSDictionary
                
                let lblTitle = cell.contentView.viewWithTag(1001) as! UILabel
                let imgView = cell.contentView.viewWithTag(1002) as! UIImageView
                let lblProvider = cell.contentView.viewWithTag(1003) as! UILabel
                let lblTime = cell.contentView.viewWithTag(1004) as! UILabel
                let ImgViewDescript = cell.contentView.viewWithTag(1005) as! UIImageView
                
                let view = cell.contentView.viewWithTag(1000) as! UIView
                view.layer.cornerRadius = 5
                
                view.layer.shadowColor = UIColor.lightGray.cgColor
                view.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
                view.layer.shadowOpacity = 1.0
                view.layer.shadowRadius = 0.0
                view.layer.masksToBounds = false
                
                view.layer.shadowColor = UIColor.gray.cgColor
                view.layer.shadowOpacity = 0.5
                view.layer.shadowOffset = CGSize.zero
                view.layer.shadowRadius = 6
                
                lblProvider.frame = CGRect.init(x: 45, y: 353.5, width: 150, height: 21)
                
                lblTitle.text  = dicNews.value(forKey: "description") as? String
                lblProvider.text = dicNews.value(forKey: "provider") as? String
                lblTime.text = dicNews.value(forKey: "datetime") as? String
                
                lblProvider.translatesAutoresizingMaskIntoConstraints = true
                lblProvider.sizeToFit()
                lblProvider.frame = CGRect.init(x: 45, y: 353.5, width: lblProvider.frame.size.width, height: lblProvider.frame.size.height)
                
                
                //        lblTime.translatesAutoresizingMaskIntoConstraints = true
                lblTime.frame = CGRect.init(x: lblProvider.frame.origin.x + lblProvider.frame.size.width + 10, y: 353.5, width: 110, height: lblProvider.frame.size.height)
                
                
                //                imgView.sd_setImage(with: URL.init(string: dicNews.value(forKey: "image") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
                //
                //                ImgViewDescript.sd_setImage(with: URL.init(string: dicNews.value(forKey: "provider_icon") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
                imgView.sd_setImage(with: URL.init(string: dicNews.value(forKey: "image") as! String))
                
                ImgViewDescript.sd_setImage(with: URL.init(string: dicNews.value(forKey: "provider_icon") as! String))
                
                cell.selectionStyle = .none
                
                
                return cell
            }
            else if tableView == tblViewImageTreding
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
                
                let view = cell.contentView.viewWithTag(1000) as! UIView
                view.layer.cornerRadius = 5
                
                view.layer.shadowColor = UIColor.gray.cgColor
                view.layer.shadowOpacity = 0.5
                view.layer.shadowOffset = CGSize.zero
                view.layer.shadowRadius = 6
                
                view.layer.borderColor = UIColor(red: 223/255, green: 226/255, blue: 226/255, alpha: 1).cgColor
                view.layer.borderWidth = 1
                
                view.layer.shadowColor = UIColor.lightGray.cgColor
                view.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
                view.layer.shadowOpacity = 1.0
                view.layer.shadowRadius = 0.0
                view.layer.masksToBounds = false
                
                let lblTitle = cell.contentView.viewWithTag(1002) as! UILabel
                let lblWeb = cell.contentView.viewWithTag(1003) as! UILabel
                let imgView = cell.contentView.viewWithTag(1004) as! UIImageView
                
                let dicImage = self.arrImageTrending.object(at: indexPath.row) as! NSDictionary
                
                lblTitle.text  = dicImage.value(forKey: "title") as? String
                lblWeb.text  = dicImage.value(forKey: "website") as? String
                
                var strURL = dicImage.value(forKey: "image") as! String
                strURL = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                //imgView.sd_setImage(with: URL.init(string: strURL), placeholderImage: nil, options: .continueInBackground, completed: nil)
                imgView.sd_setImage(with: URL.init(string: strURL))
                
                cell.selectionStyle = .none
                
                
                
                return cell
            }
            else
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCellTrending", for: indexPath)
                
                let view = cell.contentView.viewWithTag(1000) as! UIView
                view.layer.cornerRadius = 5
                
                view.layer.shadowColor = UIColor.gray.cgColor
                view.layer.shadowOpacity = 0.5
                view.layer.shadowOffset = CGSize.zero
                view.layer.shadowRadius = 6
                
                view.layer.borderColor = UIColor(red: 223/255, green: 226/255, blue: 226/255, alpha: 1).cgColor
                view.layer.borderWidth = 1
                
                view.layer.shadowColor = UIColor.lightGray.cgColor
                view.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
                view.layer.shadowOpacity = 1.0
                view.layer.shadowRadius = 0.0
                view.layer.masksToBounds = false
                
                let btnVideo = cell.contentView.viewWithTag(100) as! UIButton
                btnVideo.addTarget(self, action: #selector(self.clickOnVideoTrending(sender:)), for: UIControl.Event.touchUpInside)
                
                let dicVideo = self.arrVideoTrending.object(at: indexPath.row) as! NSDictionary
                
                let lblTitle = cell.contentView.viewWithTag(1002) as! UILabel
                let lblWeb = cell.contentView.viewWithTag(1003) as! UILabel
                let imgView = cell.contentView.viewWithTag(1004) as! UIImageView
                
                lblTitle.text  = dicVideo.value(forKey: "title") as? String
                lblWeb.text  = dicVideo.value(forKey: "website") as? String
                
                imgView.sd_setImage(with: URL.init(string: dicVideo.value(forKey: "image") as! String))
                
                //imgView.sd_setImage(with: URL.init(string: dicVideo.value(forKey: "image") as! String), placeholderImage: nil, options: .continueInBackground, completed: nil)
                
                cell.selectionStyle = .none
                
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.TrendingView.isHidden {
            if tableView == tblViewAll {
                
                if indexPath.section == 0 {
                    let dicAll = self.arrAllSearchBussiness.object(at: indexPath.row) as! NSDictionary
                    
                    let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
                    browserVC.hidesBottomBarWhenPushed = true
                    browserVC.strURL = dicAll.value(forKey: "detail_url") as! String
                    browserVC.objId = dicAll.value(forKey: "id") as! String
                    browserVC.isFromPreviousPage = true
                    browserVC.isFromSearch = true
                    self.navigationController?.pushViewController(browserVC, animated: true)
                    
                    let strURL = "\(SERVER_URL)/save-search"
                    
                    let strParameters = String.init(format: "journey_id=%d&query=%@&title=%@&website=%@&type=text&bing_id=%@",appDelegate.ObjRandomNumber!,dicAll.value(forKey: "name") as! String,dicAll.value(forKey: "name") as! String,dicAll.value(forKey: "website") as! String,dicAll.value(forKey: "id") as! String)
                    
                    WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "save-search", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: false)
                    
                } else if indexPath.section == 1 {
                    
                } else {
                    
                    let dicAll = self.arrAll.object(at: indexPath.row) as! NSDictionary
                    let browserVC = self.storyboard?.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
                    browserVC.hidesBottomBarWhenPushed = true
                    browserVC.strURL = dicAll.value(forKey: "website") as! String
                    browserVC.selectedIndexHistory = self.selectedIndexHistory
                    browserVC.searchType = "All"
                    browserVC.strTitle = dicAll.value(forKey: "title") as! String
                    browserVC.isFromSearch = true
                    browserVC.objId = dicAll.value(forKey: "id") as! String
                    browserVC.isFromPreviousPage = true
                    self.navigationController?.pushViewController(browserVC, animated: true)
                    
                    let strURL = "\(SERVER_URL)/save-search"
                    
                    var strWebsite = dicAll.value(forKey: "website") as! String
                    strWebsite = strWebsite.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    
                    let dic = NSMutableDictionary()
                    dic.setValue(txtSearch.text!, forKey: "query")
                    dic.setValue(dicAll.value(forKey: "title") as! String, forKey: "title")
                    dic.setValue(strWebsite, forKey: "website")
                    dic.setValue(dicAll.value(forKey: "description") as! String, forKey: "description")
                    dic.setValue("text", forKey: "type")
                    dic.setValue(dicAll.value(forKey: "id") as! String, forKey: "bing_id")
                    dic.setValue("", forKey: "image")
                    dic.setValue(appDelegate.ObjRandomNumber, forKey: "journey_id")
                    
                    
                    WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "save-search", bodyObject: dic as AnyObject, delegate: self, isShowProgress: false)
                    
                    
                }
                
            }
            else if tableView == tblViewImage
            {
                let dicImage = self.arrImage.object(at: indexPath.row) as! NSDictionary
                
                let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
                browserVC.hidesBottomBarWhenPushed = true
                browserVC.selectedIndexHistory = self.selectedIndexHistory
                browserVC.searchType = "Image"
                browserVC.strURL = dicImage.value(forKey: "website") as! String
                browserVC.strTitle = dicImage.value(forKey: "title") as! String
                browserVC.isFromSearch = true
                browserVC.isFromPreviousPage = true
                browserVC.objId = dicImage.value(forKey: "id") as! String
                self.navigationController?.pushViewController(browserVC, animated: true)
                
                let strURL = "\(SERVER_URL)/save-search"
                
                var strWebsite = dicImage.value(forKey: "website") as! String
                strWebsite = strWebsite.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                let dic = NSMutableDictionary()
                dic.setValue(txtSearch.text!, forKey: "query")
                dic.setValue(dicImage.value(forKey: "title") as! String, forKey: "title")
                dic.setValue(strWebsite, forKey: "website")
                dic.setValue("", forKey: "description")
                dic.setValue("image", forKey: "type")
                dic.setValue(dicImage.value(forKey: "id") as! String, forKey: "bing_id")
                dic.setValue(dicImage.value(forKey: "image") as! String, forKey: "image")
                dic.setValue(appDelegate.ObjRandomNumber, forKey: "journey_id")
                
                WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "save-search", bodyObject: dic as AnyObject, delegate: self, isShowProgress: false)
            }
            else if tableView == tblViewVideos
            {
                let dicVideo = self.arrVideo.object(at: indexPath.row) as! NSDictionary
                
                let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
                browserVC.hidesBottomBarWhenPushed = true
                browserVC.selectedIndexHistory = self.selectedIndexHistory
                browserVC.searchType = "Video"
                browserVC.strURL = dicVideo.value(forKey: "website") as! String
                browserVC.strTitle = dicVideo.value(forKey: "title") as! String
                browserVC.isFromSearch = true
                browserVC.isFromPreviousPage = true
                browserVC.objId = dicVideo.value(forKey: "id") as! String
                self.navigationController?.pushViewController(browserVC, animated: true)
                
                let strURL = "\(SERVER_URL)/save-search"
                
                var strWebsite = dicVideo.value(forKey: "website") as! String
                strWebsite = strWebsite.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                let dic = NSMutableDictionary()
                dic.setValue(txtSearch.text!, forKey: "query")
                dic.setValue(dicVideo.value(forKey: "title") as! String, forKey: "title")
                dic.setValue(strWebsite, forKey: "website")
                dic.setValue(dicVideo.value(forKey: "description") as! String, forKey: "description")
                dic.setValue("video", forKey: "type")
                dic.setValue(dicVideo.value(forKey: "id") as! String, forKey: "bing_id")
                dic.setValue(dicVideo.value(forKey: "thumbnailUrl") as! String, forKey: "image")
                dic.setValue(appDelegate.ObjRandomNumber, forKey: "journey_id")
                
                WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "save-search", bodyObject: dic as AnyObject, delegate: self, isShowProgress: false)
                
            }
            else if tableView == tblViewNews
            {
                let dicNews = self.arrNews.object(at: indexPath.row) as! NSDictionary
                
                let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
                browserVC.hidesBottomBarWhenPushed = true
                browserVC.selectedIndexHistory = self.selectedIndexHistory
                browserVC.searchType = "News"
                browserVC.strURL = dicNews.value(forKey: "website") as! String
                browserVC.strTitle = dicNews.value(forKey: "title") as! String
                browserVC.isFromSearch = true
                browserVC.isFromPreviousPage = true
                browserVC.objId = dicNews.value(forKey: "id") as! String
                self.navigationController?.pushViewController(browserVC, animated: true)
                
                let strURL = "\(SERVER_URL)/save-search"
                
                var strWebsite = dicNews.value(forKey: "website") as! String
                strWebsite = strWebsite.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                let dic = NSMutableDictionary()
                dic.setValue(txtSearch.text!, forKey: "query")
                dic.setValue(dicNews.value(forKey: "title") as! String, forKey: "title")
                dic.setValue(strWebsite, forKey: "website")
                dic.setValue(dicNews.value(forKey: "description") as! String, forKey: "description")
                dic.setValue("news", forKey: "type")
                dic.setValue(dicNews.value(forKey: "id") as! String, forKey: "bing_id")
                dic.setValue(dicNews.value(forKey: "image") as! String, forKey: "image")
                dic.setValue(appDelegate.ObjRandomNumber, forKey: "journey_id")
                
                WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "save-search", bodyObject: dic as AnyObject, delegate: self, isShowProgress: false)
            }
        }
        else{
            if tableView == tblViewAllTrending{
                
                let dicAll = self.arrAllTrending.object(at: indexPath.row) as! NSDictionary
                
                let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
                browserVC.hidesBottomBarWhenPushed = true
                browserVC.strURL = dicAll.value(forKey: "website") as! String
                browserVC.strTitle = dicAll.value(forKey: "title") as! String
                browserVC.isFromSearch = false
                browserVC.objId = dicAll.value(forKey: "id") as! String
                browserVC.isFromPreviousPage = true
                self.navigationController?.pushViewController(browserVC, animated: true)
                
                let strURL = "\(SERVER_URL)/save-search"
                
                var strWebsite = dicAll.value(forKey: "website") as! String
                strWebsite = strWebsite.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                let dic = NSMutableDictionary()
                dic.setValue(dicAll.value(forKey: "title") as! String, forKey: "query")
                dic.setValue(dicAll.value(forKey: "title") as! String, forKey: "title")
                dic.setValue(strWebsite, forKey: "website")
                dic.setValue(dicAll.value(forKey: "description") as! String, forKey: "description")
                dic.setValue("text", forKey: "type")
                dic.setValue(dicAll.value(forKey: "id") as! String, forKey: "bing_id")
                dic.setValue(dicAll.value(forKey: "image") as! String, forKey: "image")
                dic.setValue(appDelegate.ObjRandomNumber, forKey: "journey_id")
                
                WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "save-search", bodyObject: dic as AnyObject, delegate: self, isShowProgress: false)
                
            }
            else if tableView == tblViewImageTreding
            {
                let dicImage = self.arrImageTrending.object(at: indexPath.row) as! NSDictionary
                
                let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
                browserVC.hidesBottomBarWhenPushed = true
                browserVC.strURL = dicImage.value(forKey: "website") as! String
                browserVC.strTitle = dicImage.value(forKey: "title") as! String
                browserVC.isFromSearch = false
                browserVC.isFromPreviousPage = true
                browserVC.objId = dicImage.value(forKey: "id") as! String
                self.navigationController?.pushViewController(browserVC, animated: true)
                
                
                let strURL = "\(SERVER_URL)/save-search"
                
                var strWebsite = dicImage.value(forKey: "website") as! String
                strWebsite = strWebsite.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                let dic = NSMutableDictionary()
                dic.setValue(dicImage.value(forKey: "title") as! String, forKey: "query")
                dic.setValue(dicImage.value(forKey: "title") as! String, forKey: "title")
                dic.setValue(strWebsite, forKey: "website")
                dic.setValue("", forKey: "description")
                dic.setValue("image", forKey: "type")
                dic.setValue(dicImage.value(forKey: "id") as! String, forKey: "bing_id")
                dic.setValue(dicImage.value(forKey: "image") as! String, forKey: "image")
                dic.setValue(appDelegate.ObjRandomNumber, forKey: "journey_id")
                
                WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "save-search", bodyObject: dic as AnyObject, delegate: self, isShowProgress: false)
            }
            else if tableView == tblViewVideosTrending
            {
                let dicVideo = self.arrVideoTrending.object(at: indexPath.row) as! NSDictionary
                
                let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
                browserVC.hidesBottomBarWhenPushed = true
                browserVC.strURL = dicVideo.value(forKey: "website") as! String
                browserVC.strTitle = dicVideo.value(forKey: "title") as! String
                browserVC.isFromSearch = false
                browserVC.isFromPreviousPage = true
                browserVC.objId = dicVideo.value(forKey: "id") as! String
                self.navigationController?.pushViewController(browserVC, animated: true)
                
                let strURL = "\(SERVER_URL)/save-search"
                
                
                var strWebsite = dicVideo.value(forKey: "website") as! String
                strWebsite = strWebsite.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                let dic = NSMutableDictionary()
                dic.setValue(dicVideo.value(forKey: "title") as! String, forKey: "query")
                dic.setValue(dicVideo.value(forKey: "title") as! String, forKey: "title")
                dic.setValue(strWebsite, forKey: "website")
                dic.setValue(dicVideo.value(forKey: "description") as! String, forKey: "description")
                dic.setValue("video", forKey: "type")
                dic.setValue(dicVideo.value(forKey: "id") as! String, forKey: "bing_id")
                dic.setValue(dicVideo.value(forKey: "image") as! String, forKey: "image")
                dic.setValue(appDelegate.ObjRandomNumber, forKey: "journey_id")
                
                WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "save-search", bodyObject: dic as AnyObject, delegate: self, isShowProgress: false)
                
            }
            else if tableView == tblViewNewsTrending
            {
                let dicNews = self.arrNewsTrending.object(at: indexPath.row) as! NSDictionary
                
                let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
                browserVC.hidesBottomBarWhenPushed = true
                browserVC.strURL = dicNews.value(forKey: "website") as! String
                browserVC.strTitle = dicNews.value(forKey: "title") as! String
                browserVC.isFromSearch = false
                browserVC.isFromPreviousPage = true
                browserVC.objId = dicNews.value(forKey: "id") as! String
                self.navigationController?.pushViewController(browserVC, animated: true)
                
                let strURL = "\(SERVER_URL)/save-search"
                
                var strWebsite = dicNews.value(forKey: "website") as! String
                strWebsite = strWebsite.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                let dic = NSMutableDictionary()
                dic.setValue(dicNews.value(forKey: "title") as! String, forKey: "query")
                dic.setValue(dicNews.value(forKey: "title") as! String, forKey: "title")
                dic.setValue(strWebsite, forKey: "website")
                dic.setValue(dicNews.value(forKey: "description") as! String, forKey: "description")
                dic.setValue("news", forKey: "type")
                dic.setValue(dicNews.value(forKey: "id") as! String, forKey: "bing_id")
                dic.setValue(dicNews.value(forKey: "image") as! String, forKey: "image")
                dic.setValue(appDelegate.ObjRandomNumber, forKey: "journey_id")
                
                WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "save-search", bodyObject: dic as AnyObject, delegate: self, isShowProgress: false)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == tblViewAllTrending{
            
            if indexPath.row < 3 {
                return 115
            } else {
                return UITableView.automaticDimension
            }
            
        } else if tableView == tblViewAll {
            
            if indexPath.section == 1 {
                
                return CGFloat((arrAllSearchVideos.count / 2) * 220).rounded().nextUp
            } else {
                return UITableView.automaticDimension
            }
            
        } else {
            return UITableView.automaticDimension
        }
        
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt
        indexPath: IndexPath) -> CGFloat {
        
        if tableView == tblViewAllTrending{
            if indexPath.row < 3 {
                return 115
            } else {
                return cellHeights[indexPath] ?? 70.0
            }
        } else {
            return cellHeights[indexPath] ?? 70.0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if TrendingView.isHidden {
            
            if section == 1 {
                if tableView == tblViewAll {
                    if arrAllSearchVideos.count != 0 {
                        return 58
                    } else {
                        return 0
                    }
                }
                return CGFloat.leastNormalMagnitude
            } else {
                return 0
            }
            
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if TrendingView.isHidden {
            if section == 0 {
                if tableView == tblViewAll{
                    
                    if arrAllSearchBussiness.count != 0 {
                        return 40
                    } else {
                        return 0
                    }
                }
                return 0
            } else if section == 1 {
                
                if tableView == tblViewAll {
                    if arrAllSearchVideos.count != 0 {
                        return 44
                    } else {
                        return 0 //CGFloat.leastNormalMagnitude
                    }
                }
                return 0
            } else {
                return 0 //CGFloat.leastNormalMagnitude
            }
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 {
            let headerView = Bundle.main.loadNibNamed("SearchHeaderVedioView", owner: self, options: [:])?.first as! SearchHeaderVedioView
            
            let view = headerView.viewWithTag(1001) as! UIView
            view.layer.cornerRadius = 5
            view.layer.borderColor = UIColor(red: 223/255, green: 226/255, blue: 226/255, alpha: 1).cgColor
            view.layer.borderWidth = 1
            
            
            //            view.layer.shadowColor = UIColor.gray.cgColor
            //            view.layer.shadowOpacity = 0.5
            //            view.layer.shadowOffset = CGSize.zero
            //            view.layer.shadowRadius = 6
            
            if #available(iOS 11.0, *) {
                view.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
            } else {
                // Fallback on earlier versions
            }
            
            return headerView
        } else {
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        if section == 0 {
            let headerView = Bundle.main.loadNibNamed("SearchMoreBussinessView", owner: self, options: [:])?.first as! SearchMoreBussinessView
            
            let view = headerView.viewWithTag(1001) as! UIView
            
            view.layer.cornerRadius = 5
            view.layer.borderColor = UIColor(red: 223/255, green: 226/255, blue: 226/255, alpha: 1).cgColor
            view.layer.borderWidth = 1
            
            //            view.layer.shadowColor = UIColor.gray.cgColor
            //            view.layer.shadowOpacity = 0.5
            //            view.layer.shadowOffset = CGSize.zero
            //            view.layer.shadowRadius = 6
            
            if #available(iOS 11.0, *) {
                view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
            
            let btnShowMore = headerView.viewWithTag(1002) as! UIButton
            
            let viewTapGesture1 = UITapGestureRecognizer(target: self, action: #selector(self.showMoreTap1(_:)))
            btnShowMore.addGestureRecognizer(viewTapGesture1)
            
            return headerView
        } else {
            let headerView = Bundle.main.loadNibNamed("SearchMoreVedioView", owner: self, options: [:])?.first as! SearchMoreVedioView
            
            let view = headerView.viewWithTag(1001) as! UIView
            
            view.layer.cornerRadius = 5
            view.layer.borderColor = UIColor(red: 223/255, green: 226/255, blue: 226/255, alpha: 1).cgColor
            view.layer.borderWidth = 1
            
            view.layer.shadowColor = UIColor.lightGray.cgColor
            view.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
            view.layer.shadowOpacity = 1.0
            view.layer.shadowRadius = 0.0
            view.layer.masksToBounds = false
            
            //            view.layer.shadowColor = UIColor.gray.cgColor
            //            view.layer.shadowOpacity = 0.5
            //            view.layer.shadowOffset = CGSize.zero
            //            view.layer.shadowRadius = 6
            
            if #available(iOS 11.0, *) {
                view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
            
            let btnShowMore = headerView.viewWithTag(1002) as! UIButton
            
            btnShowMore.tag = section
            btnShowMore.addTarget(self, action: #selector(clickOnVideos(_:)), for: .touchUpInside)
            
            
            
            if section == 1 {
                if tableView == tblViewAll {
                    if arrAllSearchVideos.count != 0 {
                        headerView.isHidden = false
                        
                    } else {
                        headerView.isHidden = true
                    }
                }
            }
            
            return headerView
        }
        
    }
    
    @objc private func showMoreTap1(_ sender: UITapGestureRecognizer) {
        let searchBussinessVc = objHomeSB.instantiateViewController(withIdentifier: "SearchBussinessListVC") as! SearchBussinessListVC
        searchBussinessVc.objArrAllSearchBussiness = arrAllSearchBussiness
        searchBussinessVc.objTitle = txtSearch.text!
        self.navigationController?.pushViewController(searchBussinessVc, animated: true)
    }
    
    @objc private func showMoreTap2(_ sender: UITapGestureRecognizer) {
        
    }
    
    //MARK:- CollectionView Delegate & DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 7000 {
            return arrAllSearchVideos.count
        } else {
            return 1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 7000 {
            
            let collectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchVideoCollectionCell", for: indexPath)
            
            let view = collectionCell.contentView.viewWithTag(1000) as! UIView
            view.layer.borderColor = UIColor(red: 223/255, green: 226/255, blue: 226/255, alpha: 1).cgColor
            view.layer.borderWidth = 1
            
            view.layer.shadowColor = UIColor.lightGray.cgColor
            view.layer.shadowOffset = CGSize(width: 0.0, height: 0.5)
            view.layer.shadowOpacity = 1.0
            view.layer.shadowRadius = 0.0
            view.layer.masksToBounds = false
            
            //  view.layer.cornerRadius = 5
            //            view.layer.shadowColor = UIColor.gray.cgColor
            //            view.layer.shadowOpacity = 0.5
            //            view.layer.shadowOffset = CGSize.zero
            //            view.layer.shadowRadius = 6
            
            let dicVideo = self.arrAllSearchVideos.object(at: indexPath.row) as! NSDictionary
            
            let lblTitle = collectionCell.viewWithTag(1002) as! UILabel
            let lblWeb = collectionCell.viewWithTag(1003) as! UILabel
            let imgView = collectionCell.viewWithTag(1004) as! UIImageView
            let lblTimeDuration = collectionCell.viewWithTag(1100) as! UILabel
            let lblDatetime = collectionCell.viewWithTag(1200) as! UILabel
            
            // lblTimeDuration.layer.cornerRadius = 4
            //   lblTimeDuration.clipsToBounds = true
            lblTimeDuration.text = dicVideo.value(forKey: "video_duration") as? String
            
            lblDatetime.text  = dicVideo.value(forKey: "datetime") as? String
            lblTitle.text  = dicVideo.value(forKey: "title") as? String
            lblWeb.text  = dicVideo.value(forKey: "provider") as? String
            let imgURL = dicVideo.value(forKey: "thumbnailUrl") as? String
            
            
            
            
            imgView.sd_setImage(with: URL.init(string: imgURL!), placeholderImage: nil, options: .continueInBackground, completed: nil)
            
            return collectionCell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCollectionCell", for: indexPath) as! searchCollectionCell
            
            if isStartSearch == true {
                cell.btnAll.setTitle("ALL", for: .normal)
                cell.btnAllContastwidth.constant = 40
                
            } else {
                cell.btnAll.setTitle("TRENDING", for: .normal)
                cell.btnAllContastwidth.constant = 70
            }
            
            if selectedSearchIndex == 0 {
                cell.btnImage.setTitleColor(UIColor.gray, for: .normal)
                cell.btnAll.setTitleColor(UIColor.blue, for: .normal)
                cell.btnNews.setTitleColor(UIColor.gray, for: .normal)
                cell.btnVideo.setTitleColor(UIColor.gray, for: .normal)
                cell.btnMap.setTitleColor(UIColor.gray, for: .normal)
                cell.btnAmozon.setTitleColor(UIColor.gray, for: .normal)
                cell.btnYoutube.setTitleColor(UIColor.gray, for: .normal)
                
                if TrendingView.isHidden == false {
                    self.tblViewAllTrending.isHidden = false
                    self.tblViewNewsTrending.isHidden = true
                    self.tblViewImageTreding.isHidden = true
                    self.tblViewVideosTrending.isHidden = true
                    
                    if self.arrAllTrending.count == 0{
                        self.getAll(showProgress: false)
                    }
                }
                
                
            } else if selectedSearchIndex == 1 {
                cell.btnImage.setTitleColor(UIColor.gray, for: .normal)
                cell.btnAll.setTitleColor(UIColor.gray, for: .normal)
                cell.btnNews.setTitleColor(UIColor.blue, for: .normal)
                cell.btnVideo.setTitleColor(UIColor.gray, for: .normal)
                cell.btnMap.setTitleColor(UIColor.gray, for: .normal)
                cell.btnAmozon.setTitleColor(UIColor.gray, for: .normal)
                cell.btnYoutube.setTitleColor(UIColor.gray, for: .normal)
                
                if TrendingView.isHidden == false {
                    self.tblViewAllTrending.isHidden = true
                    self.tblViewNewsTrending.isHidden = false
                    self.tblViewImageTreding.isHidden = true
                    self.tblViewVideosTrending.isHidden = true
                    
                    self.txtSearch.resignFirstResponder()
                    
                    if self.arrNewsTrending.count == 0{
                        self.getAllNews(showProgress: false)
                    }
                }
                
                
            } else if selectedSearchIndex == 2 {
                cell.btnImage.setTitleColor(UIColor.gray, for: .normal)
                cell.btnAll.setTitleColor(UIColor.gray, for: .normal)
                cell.btnNews.setTitleColor(UIColor.gray, for: .normal)
                cell.btnVideo.setTitleColor(UIColor.blue, for: .normal)
                cell.btnMap.setTitleColor(UIColor.gray, for: .normal)
                cell.btnAmozon.setTitleColor(UIColor.gray, for: .normal)
                cell.btnYoutube.setTitleColor(UIColor.gray, for: .normal)
                
                if TrendingView.isHidden == false {
                    self.tblViewAllTrending.isHidden = true
                    self.tblViewNewsTrending.isHidden = true
                    self.tblViewImageTreding.isHidden = true
                    self.tblViewVideosTrending.isHidden = false
                    
                    self.txtSearch.resignFirstResponder()
                    
                    if self.arrVideoTrending.count == 0{
                        self.getVideos(showProgress: false)
                    }
                }
            } else if selectedSearchIndex == 3 {
                cell.btnImage.setTitleColor(UIColor.blue, for: .normal)
                cell.btnAll.setTitleColor(UIColor.gray, for: .normal)
                cell.btnNews.setTitleColor(UIColor.gray, for: .normal)
                cell.btnVideo.setTitleColor(UIColor.gray, for: .normal)
                cell.btnMap.setTitleColor(UIColor.gray, for: .normal)
                cell.btnAmozon.setTitleColor(UIColor.gray, for: .normal)
                cell.btnYoutube.setTitleColor(UIColor.gray, for: .normal)
                
                if TrendingView.isHidden == false {
                    self.tblViewAllTrending.isHidden = true
                    self.tblViewNewsTrending.isHidden = true
                    self.tblViewImageTreding.isHidden = false
                    self.tblViewVideosTrending.isHidden = true
                    
                    self.txtSearch.resignFirstResponder()
                    
                    if self.arrImageTrending.count == 0{
                        self.getImages(showProgress: false)
                    }
                }
                
               
            }
            
            cell.btnAll.tag = indexPath.row
            cell.btnAll.addTarget(self, action: #selector(clickOnAll(_:)), for: .touchUpInside)
            
            cell.btnNews.tag = indexPath.row
            cell.btnNews.addTarget(self, action: #selector(clickOnNews(_:)), for: .touchUpInside)
            
            cell.btnImage.tag = indexPath.row
            cell.btnImage.addTarget(self, action: #selector(clickOnImage(_:)), for: .touchUpInside)
            
            cell.btnVideo.tag = indexPath.row
            cell.btnVideo.addTarget(self, action: #selector(clickOnVideos(_:)), for: .touchUpInside)
            
            cell.btnMap.tag = indexPath.row
            cell.btnMap.addTarget(self, action: #selector(clickOnMap(_:)), for: .touchUpInside)
            
            cell.btnYoutube.tag = indexPath.row
            cell.btnYoutube.addTarget(self, action: #selector(clickOnYoutube(_:)), for: .touchUpInside)
            
            cell.btnAmozon.tag = indexPath.row
            cell.btnAmozon.addTarget(self, action: #selector(clickOnAmozon(_:)), for: .touchUpInside)
            
            if dicSaveSearch.count > 0{
                
                self.dicSaveSearch.setValue("1", forKey: "Recent")
                
                if isStartSearch
                {
                    txtSearch.text = dicSaveSearch.value(forKey: "searchText") as? String
                    self.TrendingView.isHidden = true
                }
                else{
                    
                    txtSearch.text = ""
                    self.TrendingView.isHidden = false
                }
                
                let arrObject = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "SaveSearch") as! Data) as! NSMutableArray
                
                let strType = dicSaveSearch.value(forKey: "searchType") as? String
                
                if strType == "Image"{
                    self.clickOnImage(cell.btnImage)
                }
                else if strType == "Video"{
                    self.clickOnVideos(cell.btnVideo)
                }
                else if strType == "News"{
                    self.clickOnNews(cell.btnNews)
                }
                else if strType == "All"{
                    
                    
                    if isStartSearch {
                        tblViewVideos.isHidden = true
                        tblViewImage.isHidden = true
                        tblViewNews.isHidden = true
                        tblViewAll.isHidden = false
                        self.searchAll(showProgress: false)
                    }
                }
                
            }
            else if strSearchTerm != ""
            {
                if isSearchFrom == true {
                    txtSearch.text = txtSearch.text
                } else {
                    txtSearch.text = self.strSearchTerm
                }
                
                if selectedSearchIndex == 0 {
                    
                    if isStartSearch {
                        
                        TrendingView.isHidden = true
                        tblViewVideos.isHidden = true
                        tblViewImage.isHidden = true
                        tblViewNews.isHidden = true
                        tblViewAll.isHidden = false
                        self.searchAll(showProgress: false)
                    }
                }
                
                
            }
            else{
                
                if TrendingView.isHidden == false {
                    self.getAll(showProgress: false)
                }
            }
            
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 7000 {
            
            let dicVideo = self.arrAllSearchVideos.object(at: indexPath.row) as! NSDictionary
            
            let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
            browserVC.hidesBottomBarWhenPushed = true
            browserVC.isFromPreviousPage = true
            browserVC.isFromSearch = false
            browserVC.strURL = dicVideo.value(forKey: "website") as! String
            self.navigationController?.pushViewController(browserVC, animated: true)
            
            let strURL = "\(SERVER_URL)/save-search"
            
            print(appDelegate.ObjRandomNumber!)
            
            let strParameters = String.init(format:"journey_id=%d&query=%@&title=%@&website=%@&description=%@&type=video&bing_id=%@&image=%@",appDelegate.ObjRandomNumber!,txtSearch.text!,dicVideo.value(forKey: "title") as! String,dicVideo.value(forKey: "website") as! String,dicVideo.value(forKey: "description") as! String,dicVideo.value(forKey: "id") as! String,dicVideo.value(forKey: "thumbnailUrl") as! String)
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "save-search", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: false)
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 7000 {
            
            let width = (UIScreen.main.bounds.size.width - 20) / 2
            
            return CGSize(width: width, height: 220)
        } else {
            
            if isStartSearch == true {
                return CGSize(width: 455, height: 38)
            } else {
                return CGSize(width: 430, height: 38)
            }
            
        }
        
    }
    
    
    @objc func clickOnCallSearch(sender:UIButton) {
        
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
        
        let indexPath = tblViewAll.indexPath(for: cell)
        
        let dicAll = self.arrAllSearchBussiness.object(at: indexPath!.row) as! NSDictionary
        
        let phone = dicAll.value(forKey: "phone") as? String
        
        if let url = URL(string: "tel://\(phone ?? "")"),
            UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // add error message here
        }
        
    }
    @objc func clickOnDirectionSearch(sender:UIButton) {
        
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
        
        let indexPath = tblViewAll.indexPath(for: cell)
        
        
        let dicAll = self.arrAllSearchBussiness.object(at: indexPath!.row) as! NSDictionary
        
        let dicDirection = dicAll.value(forKey: "latlng") as? NSDictionary
        let lat = dicDirection?.value(forKey: "latitude") as? Double
        let long = dicDirection?.value(forKey: "longitude") as? Double
        
        
        var strLocation = String.init(format: "https://www.google.co.in/maps/dir/?saddr=\(lat ?? 0.0),\(long ?? 0.0)")
        strLocation = strLocation.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let url = URL.init(string: strLocation)
        
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        
    }
    @objc func clickOnWebsiteSearch(sender:UIButton) {
        
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
        
        let indexPath = tblViewAll.indexPath(for: cell)
        
        let dicAll = self.arrAllSearchBussiness.object(at: indexPath!.row) as! NSDictionary
        
        let website = dicAll.value(forKey: "website") as? String
    
        
        if website != "" {
            let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
            browserVC.hidesBottomBarWhenPushed = true
            browserVC.strURL = website!
            self.navigationController?.pushViewController(browserVC, animated: true)
        }
        
        
        let strURL = "\(SERVER_URL)/save-search"
        
        let strParameters = String.init(format: "journey_id=%d&query=%@&title=%@&website=%@&type=website&bing_id=%@",appDelegate.ObjRandomNumber!,dicAll.value(forKey: "name") as! String,dicAll.value(forKey: "name") as! String,dicAll.value(forKey: "website") as! String,dicAll.value(forKey: "id") as! String)
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "save-search", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: false)
        
        
    }
    
    @objc func clickOnVideoFromSearch(sender:UIButton)
    {
        
        self.selectedSearchIndex = 2
        
        let cell1 = self.collectionView.dequeueReusableCell(withReuseIdentifier: "searchCollectionCell", for: IndexPath.init(item: 2, section: 0))  as! searchCollectionCell
        
        cell1.btnVideo.setTitleColor(UIColor.blue, for: .normal)
        cell1.btnAll.setTitleColor(UIColor.gray, for: .normal)
        cell1.btnNews.setTitleColor(UIColor.gray, for: .normal)
        cell1.btnImage.setTitleColor(UIColor.gray, for: .normal)
        
        collectionView.reloadData()
        
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
        
        let indexPath = tblViewAll.indexPath(for: cell)
        
        let dicVideo = self.arrAllSearchVideos.object(at: indexPath!.row) as! NSDictionary
        
        let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        browserVC.hidesBottomBarWhenPushed = true
        browserVC.strURL = dicVideo.value(forKey: "website") as! String
        self.navigationController?.pushViewController(browserVC, animated: true)
        
        
        let strURL = "\(SERVER_URL)/save-search"
        
        let strParameters = String.init(format: "query=%@&title=%@&website=%@&description=%@&type=video&bing_id=%@&image=%@",txtSearch.text!,dicVideo.value(forKey: "title") as! String,dicVideo.value(forKey: "website") as! String,dicVideo.value(forKey: "description") as! String,dicVideo.value(forKey: "id") as! String,dicVideo.value(forKey: "thumbnailUrl") as! String)
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "save-search", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: false)
        
    }
    
    
    @objc func clickOnVideo(sender:UIButton)
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
        
        let indexPath = tblViewVideos.indexPath(for: cell)
        
        
        let dicVideo = self.arrVideo.object(at: indexPath!.row) as! NSDictionary
        
        let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        browserVC.hidesBottomBarWhenPushed = true
        browserVC.strURL = dicVideo.value(forKey: "website") as! String
        self.navigationController?.pushViewController(browserVC, animated: true)
        
        
        let strURL = "\(SERVER_URL)/save-search"
        
        let strParameters = String.init(format: "journey_id=%d&query=%@&title=%@&website=%@&description=%@&type=video&bing_id=%@&image=%@",appDelegate.ObjRandomNumber!,txtSearch.text!,dicVideo.value(forKey: "title") as! String,dicVideo.value(forKey: "website") as! String,dicVideo.value(forKey: "description") as! String,dicVideo.value(forKey: "id") as! String,dicVideo.value(forKey: "thumbnailUrl") as! String)
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "save-search", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: false)
        
    }
    
    @objc func clickOnVideoTrending(sender:UIButton)
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
        
        
        let indexPath = tblViewVideosTrending.indexPath(for: cell)
        
        let dicVideo = self.arrVideoTrending.object(at: indexPath!.row) as! NSDictionary
        
        let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        browserVC.hidesBottomBarWhenPushed = true
        browserVC.strURL = dicVideo.value(forKey: "website") as! String
        self.navigationController?.pushViewController(browserVC, animated: true)
        
        let strURL = "\(SERVER_URL)/save-search"
        
        let strParameters = String.init(format: "journey_id=%d&query=%@&title=%@&website=%@&description=%@&type=video&bing_id=%@&image=%@",appDelegate.ObjRandomNumber!,dicVideo.value(forKey: "title") as! String,dicVideo.value(forKey: "title") as! String,dicVideo.value(forKey: "website") as! String,dicVideo.value(forKey: "description") as! String,dicVideo.value(forKey: "id") as! String,dicVideo.value(forKey: "image") as! String)
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "save-search", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: false)
        
    }
    
    @objc func clickOnAll(_ sender: AnyObject)
    {
        UIView.animate(withDuration: 0.5) {
            self.selectedSearchIndex = 0
            
            let button = sender as? UIButton
            let cell = button?.superview?.superview as? searchCollectionCell
            
            if self.TrendingView.isHidden {
                
                cell!.btnAll.setTitleColor(UIColor.blue, for: .normal)
                cell!.btnNews.setTitleColor(UIColor.gray, for: .normal)
                cell!.btnImage.setTitleColor(UIColor.gray, for: .normal)
                cell!.btnVideo.setTitleColor(UIColor.gray, for: .normal)
                
                self.tblViewAll.isHidden = false
                self.tblViewNews.isHidden = true
                self.tblViewImage.isHidden = true
                self.tblViewVideos.isHidden = true
                
                self.arrAll.removeAllObjects()
                self.currentPageAll = 0
                self.searchAll(showProgress: false)
                
                self.currentPageAll = 0
                self.arrAll.removeAllObjects()
                self.arrAllSearchBussiness.removeAllObjects()
                self.arrAllSearchVideos.removeAllObjects()
                
                self.searchAllNewAPI(showProgress: false)
                self.tblViewAll.reloadData()
            }
            else{
                cell!.btnAll.setTitleColor(UIColor.blue, for: .normal)
                cell!.btnNews.setTitleColor(UIColor.gray, for: .normal)
                cell!.btnImage.setTitleColor(UIColor.gray, for: .normal)
                cell!.btnVideo.setTitleColor(UIColor.gray, for: .normal)
                
                self.tblViewAllTrending.isHidden = false
                self.tblViewNewsTrending.isHidden = true
                self.tblViewImageTreding.isHidden = true
                self.tblViewVideosTrending.isHidden = true
                
                if self.arrAllTrending.count == 0{
                    self.getAll(showProgress: false)
                }
            }
        }
        
    }
    
    @objc func clickOnNews(_ sender: AnyObject)
    {
        UIView.animate(withDuration: 0.5) {
            self.selectedSearchIndex = 1
            
            let button = sender as? UIButton
            let cell = button?.superview?.superview as? searchCollectionCell
            
            if self.TrendingView.isHidden
            {
                cell!.btnNews.setTitleColor(UIColor.blue, for: .normal)
                cell!.btnAll.setTitleColor(UIColor.gray, for: .normal)
                cell!.btnImage.setTitleColor(UIColor.gray, for: .normal)
                cell!.btnVideo.setTitleColor(UIColor.gray, for: .normal)
                
                self.tblViewAll.isHidden = true
                self.tblViewNews.isHidden = false
                self.tblViewImage.isHidden = true
                self.tblViewVideos.isHidden = true
                
                self.txtSearch.resignFirstResponder()
                
                self.arrNews.removeAllObjects()
                self.currentPageNews = 0
                self.searchNews(showProgress: false)
                
                self.tblViewNews.reloadData()
            }
            else{
                cell!.btnNews.setTitleColor(UIColor.blue, for: .normal)
                cell!.btnAll.setTitleColor(UIColor.gray, for: .normal)
                cell!.btnImage.setTitleColor(UIColor.gray, for: .normal)
                cell!.btnVideo.setTitleColor(UIColor.gray, for: .normal)
                
                self.tblViewAllTrending.isHidden = true
                self.tblViewNewsTrending.isHidden = false
                self.tblViewImageTreding.isHidden = true
                self.tblViewVideosTrending.isHidden = true
                
                self.txtSearch.resignFirstResponder()
                
                if self.arrNewsTrending.count == 0{
                    self.getAllNews(showProgress: false)
                }
            }
            
        }
        
    }
    
    @objc func clickOnImage(_ sender: AnyObject)
    {
        UIView.animate(withDuration: 0.5) {
            self.selectedSearchIndex = 3
            
            let button = sender as? UIButton
            let cell = button?.superview?.superview as? searchCollectionCell
            
            if self.TrendingView.isHidden
            {
                cell!.btnImage.setTitleColor(UIColor.blue, for: .normal)
                cell!.btnAll.setTitleColor(UIColor.gray, for: .normal)
                cell!.btnNews.setTitleColor(UIColor.gray, for: .normal)
                cell!.btnVideo.setTitleColor(UIColor.gray, for: .normal)
                
                
                self.tblViewAll.isHidden = true
                self.tblViewNews.isHidden = true
                self.tblViewImage.isHidden = false
                self.tblViewVideos.isHidden = true
                
                self.txtSearch.resignFirstResponder()
                
                self.arrImage.removeAllObjects()
                self.currentPageImage = 0
                self.searchImage(showProgress: false)
                
                self.tblViewImage.reloadData()
                
            }
            else{
                cell!.btnImage.setTitleColor(UIColor.blue, for: .normal)
                cell!.btnAll.setTitleColor(UIColor.gray, for: .normal)
                cell!.btnNews.setTitleColor(UIColor.gray, for: .normal)
                cell!.btnVideo.setTitleColor(UIColor.gray, for: .normal)
                
                self.tblViewAllTrending.isHidden = true
                self.tblViewNewsTrending.isHidden = true
                self.tblViewImageTreding.isHidden = false
                self.tblViewVideosTrending.isHidden = true
                
                self.txtSearch.resignFirstResponder()
                
                if self.arrImageTrending.count == 0{
                    self.getImages(showProgress: false)
                }
            }
        }
    }
    
    @objc func clickOnVideos(_ sender: AnyObject)
    {
        UIView.animate(withDuration: 0.5) {
            
            self.selectedSearchIndex = 2
            
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "searchCollectionCell", for: IndexPath.init(item: 2, section: 0))  as! searchCollectionCell
            
            if self.TrendingView.isHidden
            {
                cell.btnVideo.setTitleColor(UIColor.blue, for: .normal)
                cell.btnAll.setTitleColor(UIColor.gray, for: .normal)
                cell.btnNews.setTitleColor(UIColor.gray, for: .normal)
                cell.btnImage.setTitleColor(UIColor.gray, for: .normal)
                
                self.tblViewAll.isHidden = true
                self.tblViewNews.isHidden = true
                self.tblViewImage.isHidden = true
                self.tblViewVideos.isHidden = false
                
                self.txtSearch.resignFirstResponder()
                
                self.arrVideo.removeAllObjects()
                self.currentPageVideo = 0
                self.searchVideo(showProgress: false)
                
                self.collectionView.reloadData()
                self.tblViewVideos.reloadData()
            }
            else{
                cell.btnVideo.setTitleColor(UIColor.blue, for: .normal)
                cell.btnAll.setTitleColor(UIColor.gray, for: .normal)
                cell.btnNews.setTitleColor(UIColor.gray, for: .normal)
                cell.btnImage.setTitleColor(UIColor.gray, for: .normal)
                
                self.tblViewAllTrending.isHidden = true
                self.tblViewNewsTrending.isHidden = true
                self.tblViewImageTreding.isHidden = true
                self.tblViewVideosTrending.isHidden = false
                
                self.txtSearch.resignFirstResponder()
                
                if self.arrVideoTrending.count == 0{
                    self.getVideos(showProgress: false)
                }
                self.collectionView.reloadData()
            }
            
        }
    }
    
    @objc func clickOnMap(_ sender: AnyObject)
    {
        // if  (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!))
        //  {
        var strLocation = String.init(format: "http://maps.google.com/maps?q=%@",txtSearch.text!)
        strLocation = strLocation.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        let url = URL.init(string: strLocation)
        
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        // }
        
    }
    
    @objc func clickOnAmozon(_ sender: AnyObject)
    {
        let strLocation = String.init(format: "http://www.amazon.com/s?k=\(txtSearch.text!)")
        //    let url = URL.init(string: strLocation)
        //    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        
        
        let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        browserVC.hidesBottomBarWhenPushed = true
        browserVC.strURL = strLocation
        browserVC.objSearchTitle = txtSearch.text!
        self.navigationController?.pushViewController(browserVC, animated: true)
        
    }
    
    @objc func clickOnYoutube(_ sender: AnyObject)
    {
        let strLocation = String.init(format: "http://www.youtube.com/results?search_query=\(txtSearch.text!)")
        //let strLocation = String.init(format: "http://www.youtube.com")
        //    let url = URL.init(string: strLocation)
        //    U IApplication.shared.open(url!, options: [:], completionHandler: nil)
        
        
        let browserVC = self.storyboard?.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        browserVC.hidesBottomBarWhenPushed = true
        browserVC.strURL = strLocation
        browserVC.objSearchTitle = txtSearch.text!
        self.navigationController?.pushViewController(browserVC, animated: true)
        
    }
    
    @objc func clickOnGoogle(_ sender: AnyObject)
    {
        let strLocation = String.init(format: "http://www.google.com/search?q=\(txtSearch.text!)")
        //    let url = URL.init(string: strLocation)
        //    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        
        
        let browserVC = self.storyboard?.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
        browserVC.hidesBottomBarWhenPushed = true
        browserVC.strURL = strLocation
        browserVC.objSearchTitle = txtSearch.text!
        self.navigationController?.pushViewController(browserVC, animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        latitude = (location?.coordinate.latitude)!
        longitude = (location?.coordinate.longitude)!
        
     //   locationManager.stopUpdatingLocation()
        if UserDefaults.standard.object(forKey: "LoginDetail") != nil{
            self.setupAddress()
        }
    }
    
    func setupAddress()
    {
        self.getAddress(handler: { (strAddress) in
            
            let dic = NSMutableDictionary()
            dic.setValue(strAddress, forKey: "address")
            dic.setValue(self.strCity, forKey: "city")
            dic.setValue(self.strCountry, forKey: "country")
            dic.setValue(self.strZip, forKey: "zip")
            dic.setValue("\(self.latitude)", forKey: "latitude")
            dic.setValue("\(self.longitude)", forKey: "longitude")
            
            let strURL = "\(SERVER_URL)/update-location"
            
            WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST_RAWDATA, ServiceName: "update-location", bodyObject: dic as AnyObject, delegate: self, isShowProgress: false)
        })
    }
    
    func getAddress(handler: @escaping (String) -> Void)
    {
        var address: String = ""
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        //selectedLat and selectedLon are double values set by the app in a previous process
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark?
            placeMark = placemarks?[0]
            
            // Location name
            if let locationName = placeMark?.name {
                address += locationName + ", "
            }
            
            // City
            if let city = placeMark?.addressDictionary?["City"] as? String {
                address += city + ", "
                self.strCity = city
            }
            
            if let subLocality = placeMark?.subLocality {
                address += subLocality + ", "
            }
            
            if let state = placeMark?.administrativeArea {
                address += state + ", "
            }
            
            // Zip code
            if let zip = placeMark?.addressDictionary?["ZIP"] as? String {
                address += zip + ", "
                self.strZip = zip
            }
            
            // Country
            if let country = placeMark?.addressDictionary?["Country"] as? String {
                address += country
                self.strCountry = country
            }
            
            // Passing address back
            handler(address)
        })
    }
    
    @IBAction func clickOnInfo(sender:UIButton)
    {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        self.perform(#selector(self.gotoTrending), on: Thread.main, with: nil, waitUntilDone: true)
    }
    
    @objc func gotoTrending()
    {
        if txtSearch.text != "" {
            
            if (self.arrAll.count > 0 || self.arrImage.count > 0 || self.arrVideo.count > 0 || self.arrNews.count > 0)
            {
                var image : UIImage!
                var searchType : String = ""
                
                if !self.tblViewAll.isHidden{
                    searchType = "All"
                }
                else if !self.tblViewImage.isHidden{
                    searchType = "Image"
                }
                else if !self.tblViewVideos.isHidden{
                    searchType = "Video"
                }
                else{
                    searchType = "News"
                }
                
                image = self.mainView.takeScreenshot()
                
                var arrSaveSearch = NSMutableArray()
                
                if UserDefaults.standard.object(forKey: "SaveSearch") != nil{
                    
                    let arrObject = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "SaveSearch") as! Data) as! NSMutableArray
                    
                    arrSaveSearch = NSMutableArray.init(array: arrObject)
                    
                }
                
                if selectedIndexHistory != -1{
                    
                    var dicRecentSearch = arrSaveSearch.object(at: selectedIndexHistory) as! NSMutableDictionary
                    dicRecentSearch.setValue(image, forKey: "searchImage")
                    dicRecentSearch.setValue(self.txtSearch.text!, forKey: "searchText")
                    dicRecentSearch.setValue(searchType, forKey: "searchType")
                    
                    arrSaveSearch.replaceObject(at: selectedIndexHistory, with: dicRecentSearch)
                    
                }
                else{
                    
                    let predicate = NSPredicate.init(format: "Recent=%@","1")
                    let filteredArray = arrSaveSearch.filtered(using: predicate) as NSArray
                    
                    if filteredArray.count > 0{
                        arrSaveSearch.remove(filteredArray.object(at: 0))
                    }
                    
                    let dicRecentSearch = NSMutableDictionary()
                    dicRecentSearch.setValue(image, forKey: "searchImage")
                    dicRecentSearch.setValue(self.txtSearch.text!, forKey: "searchText")
                    dicRecentSearch.setValue(searchType, forKey: "searchType")
                    dicRecentSearch.setValue("1", forKey: "Recent")
                    
                    arrSaveSearch.insert(dicSaveSearch, at: 0)
                }
                
                let data = NSKeyedArchiver.archivedData(withRootObject: arrSaveSearch)
                UserDefaults.standard.setValue(data, forKey: "SaveSearch")
                UserDefaults.standard.synchronize()
                
                self.imgWindow.isHidden = false
                self.btnCount.isHidden = false
                self.btnCount.setTitle("\(arrSaveSearch.count)", for: UIControl.State.normal)
                
            }
            
            var arrSaveSearch = NSMutableArray()
            if UserDefaults.standard.object(forKey: "SaveSearch") != nil{
                
                let arrObject = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "SaveSearch") as! Data) as! NSMutableArray
                arrSaveSearch = NSMutableArray.init(array: arrObject)
            }
            
            for index in 0..<arrSaveSearch.count{
                let dic = arrSaveSearch.object(at: index) as! NSMutableDictionary
                dic.setValue("0", forKey: "Recent")
                arrSaveSearch.replaceObject(at: index, with: dic)
            }
            
            let data = NSKeyedArchiver.archivedData(withRootObject: arrSaveSearch)
            UserDefaults.standard.setValue(data, forKey: "SaveSearch")
            UserDefaults.standard.synchronize()
        }
        
        isStartSearch = false
        //   selectedSearchIndex = 0
        self.collectionView.reloadData()
        txtSearch.text = ""
        self.TrendingView.isHidden = false
        
        self.tblViewAll.isHidden = true
        self.tblViewImage.isHidden = true
        self.tblViewVideos.isHidden = true
        self.tblViewNews.isHidden = true
    }
    
    @IBAction func clickOnOpenSearchList(sender:UIButton)
    {
        self.perform(#selector(self.openSearchList), on: Thread.main, with: nil, waitUntilDone: true)
        
        let saveSearchVC = objHomeSB.instantiateViewController(withIdentifier: "SaveSearchViewcontroller") as! SaveSearchViewcontroller
        selectedIndexHistory = -1
        saveSearchVC.isFromSearch = true
        self.navigationController?.pushViewController(saveSearchVC, animated: true)
    }
    
    @objc func openSearchList()
    {
        if self.TrendingView.isHidden{
            
            if (self.arrAll.count > 0 || self.arrImage.count > 0 || self.arrVideo.count > 0 || self.arrNews.count > 0)
            {
                var image : UIImage!
                var searchType : String = ""
                
                if !self.tblViewAll.isHidden{
                    searchType = "All"
                }
                else if !self.tblViewImage.isHidden{
                    searchType = "Image"
                }
                else if !self.tblViewVideos.isHidden{
                    searchType = "Video"
                }
                else{
                    searchType = "News"
                }
                
                image = self.mainView.takeScreenshot()
                
                var arrSaveSearch = NSMutableArray()
                
                if UserDefaults.standard.object(forKey: "SaveSearch") != nil{
                    
                    let arrObject = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "SaveSearch") as! Data) as! NSMutableArray
                    
                    arrSaveSearch = NSMutableArray.init(array: arrObject)
                    
                }
                
                if self.selectedIndexHistory != -1{
                    
                    var dicRecentSearch = arrSaveSearch.object(at: self.selectedIndexHistory) as! NSMutableDictionary
                    dicRecentSearch.setValue(image, forKey: "searchImage")
                    dicRecentSearch.setValue(self.txtSearch.text!, forKey: "searchText")
                    dicRecentSearch.setValue(searchType, forKey: "searchType")
                    
                    arrSaveSearch.replaceObject(at: self.selectedIndexHistory, with: dicRecentSearch)
                    
                }
                else{
                    
                    let predicate = NSPredicate.init(format: "Recent=%@","1")
                    let filteredArray = arrSaveSearch.filtered(using: predicate) as NSArray
                    
                    if filteredArray.count > 0{
                        arrSaveSearch.remove(filteredArray.object(at: 0))
                    }
                    
                    let dicRecentSearch = NSMutableDictionary()
                    dicRecentSearch.setValue(image, forKey: "searchImage")
                    dicRecentSearch.setValue(self.txtSearch.text!, forKey: "searchText")
                    dicRecentSearch.setValue(searchType, forKey: "searchType")
                    dicRecentSearch.setValue("1", forKey: "Recent")
                    
                    arrSaveSearch.insert(dicRecentSearch, at: 0)
                }
                
                let data = NSKeyedArchiver.archivedData(withRootObject: arrSaveSearch)
                UserDefaults.standard.setValue(data, forKey: "SaveSearch")
                UserDefaults.standard.synchronize()
                
                self.imgWindow.isHidden = false
                self.btnCount.isHidden = false
                self.btnCount.setTitle("\(arrSaveSearch.count)", for: UIControl.State.normal)
            }
        }
    }
    
    @IBAction func clickOnClear(sender:UIButton){
        
        if selectedIndexHistory != -1{
            
            strSearchTerm = ""
            txtSearch.text = ""
            btnClear.isHidden = true
            isStartSearch = false
            
            self.TrendingView.isHidden = false
            self.tblViewAll.isHidden = true
            self.tblViewImage.isHidden = true
            self.tblViewVideos.isHidden = true
            self.tblViewNews.isHidden = true
            
            selectedSearchIndex = 0
            self.getAll(showProgress: false)
            self.collectionView.reloadData()
            
        }
        else{
            
            strSearchTerm = ""
            txtSearch.text = ""
            btnClear.isHidden = true
            TrendingView.isHidden = false
            self.collectionView.reloadData()
            self.perform(#selector(self.gotoTrending), on: Thread.main, with: nil, waitUntilDone: true)
        }
        
    }
    
    func searchImage(showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/search"
        
        let strParameters = String.init(format: "query=%@&type=image&offset=%d",txtSearch.text!,self.currentPageImage)
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "searchImage", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: showProgress)
    }
    
    func searchVideo(showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/search"
        
        let strParameters = String.init(format: "query=%@&type=video&offset=%d",txtSearch.text!,self.currentPageVideo)
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "searchVideo", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: showProgress)
    }
    
    func searchNews(showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/search"
        
        let strParameters = String.init(format: "query=%@&type=news&offset=%d",txtSearch.text!,self.currentPageNews)
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "searchNews", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: showProgress)
    }
    
    func searchAll(showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/search"
        
        let strParameters = String.init(format: "query=%@&type=text&offset=%d",txtSearch.text!,self.currentPageAll)
        
        print(strParameters)
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "searchAll", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: showProgress)
    }
    
    func searchAllNewAPI(showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/search/businesses?query=\(txtSearch.text!)&limit=5&page=0"
        
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "searchAllNewAPI", bodyObject: nil, delegate: self, isShowProgress: showProgress)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let str = textField.text?.appending(string)
        
        if str!.count > 0{
            
            btnClear.isHidden = false
        }
        else{
            
            btnClear.isHidden = true
        }
        
        return true
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text != "" {
            isSearchFrom = true
            
            if dicSaveSearch.count > 0{
                dicSaveSearch.setValue(txtSearch.text!, forKey: "searchText")
            }
            
            isStartSearch = true
            collectionView.reloadData()
            
            if !self.TrendingView.isHidden
            {
                TrendingView.isHidden = true
            }
            
            if selectedSearchIndex == 0{
                
                self.tblViewAll.isHidden = true
                self.tblViewVideos.isHidden = true
                self.tblViewNews.isHidden = true
                self.tblViewImage.isHidden = true
                
                self.currentPageAll = 0
                self.arrAll.removeAllObjects()
                self.arrAllSearchBussiness.removeAllObjects()
                self.arrAllSearchVideos.removeAllObjects()
                
                self.searchAllNewAPI(showProgress: false)
                self.searchAll(showProgress: false)
                
            }
            else if selectedSearchIndex == 1
            {
                
                self.tblViewAll.isHidden = true
                self.tblViewVideos.isHidden = true
                self.tblViewNews.isHidden = false
                self.tblViewImage.isHidden = true
                
                self.currentPageNews = 0
                self.arrNews.removeAllObjects()
                self.tblViewNews.reloadData()
                self.searchNews(showProgress: false)
                
            }
            else if selectedSearchIndex == 2
            {
                self.tblViewAll.isHidden = true
                self.tblViewVideos.isHidden = false
                self.tblViewNews.isHidden = true
                self.tblViewImage.isHidden = true
                
                self.currentPageVideo = 0
                self.arrVideo.removeAllObjects()
                self.tblViewVideos.reloadData()
                self.searchVideo(showProgress: false)
            }
            else{
                
                self.tblViewAll.isHidden = true
                self.tblViewVideos.isHidden = true
                self.tblViewNews.isHidden = true
                self.tblViewImage.isHidden = false
                
                self.currentPageImage = 0
                self.arrImage.removeAllObjects()
                self.tblViewImage.reloadData()
                self.searchImage(showProgress: false)
                
            }
            
        }
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func getAll(showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/search/trending"
        
        let strParameters = "type=all&offset=\(self.currentPageAllTrending)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "trendingAll", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: showProgress)
    }
    
    func getAllNews(showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/search/trending"
        
        let strParameters = "type=news&offset=\(self.currentPageNewsTrending)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "trendingNews", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: showProgress)
    }
    
    func getImages(showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/search/trending"
        
        let strParameters = "type=image&offset=\(self.currentPageImageTrending)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "trendingImage", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: showProgress)
    }
    
    func getVideos(showProgress:Bool)
    {
        let strURL = "\(SERVER_URL)/search/trending"
        
        let strParameters = "type=video&offset=\(self.currentPageVideoTrending)"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "trendingVideo", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: showProgress)
    }
    
    
    
    
}

extension UIView {
    
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0.5)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}

extension FloatingPoint {
    func rounded(to n: Int) -> Self {
        let n = Self(n)
        return (self / n).rounded() * n
        
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        
    }
}

extension String {
    
    var stripped: String {
        let okayChars = Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-=().!_")
        return self.filter {okayChars.contains($0) }
    }
}
extension UITableView {
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
    
    func scrollToTop(animated: Bool) {
//        let indexPath = IndexPath(row: 0, section: 0)
//        if self.hasRowAtIndexPath(indexPath: indexPath) {
//            self.scrollToRow(at: indexPath, at: .top, animated: animated)
//        }
        self.setContentOffset(.zero, animated:true)

    }
}
