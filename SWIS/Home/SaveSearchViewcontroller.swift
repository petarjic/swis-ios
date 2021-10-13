//
//  SaveSearchViewcontroller.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 28/02/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import CoreLocation

class SaveSearchViewcontroller: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,CLLocationManagerDelegate,responseDelegate {
    
    @IBOutlet var collectionView : UICollectionView!
    
    var arrSearch = NSMutableArray()
    var isFromSearch : Bool = false
    
    var locationManager = CLLocationManager()

    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var strCountry : String = ""
    var strCity : String = ""
    var strZip : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.arrSearch = NSKeyedUnarchiver.unarchiveObject(with: (UserDefaults.standard.object(forKey: "SaveSearch") as! NSData) as Data) as! NSMutableArray
      
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.isTranslucent = false
         self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationItem.title = "SWIS"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:UIFont.init(name: "FiraSans-Bold", size: 15),NSAttributedString.Key.foregroundColor:UIColor.black,NSAttributedString.Key.kern:2.0]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back-icon.png"), style: .plain, target: self, action: #selector(self.clickOnBack))
        
        let rightBarBtn = UIBarButtonItem.init(image: UIImage.init(named: "menu"), style: .plain, target: self, action: #selector(clickOnMenu))
        self.navigationItem.rightBarButtonItem = rightBarBtn
        
    }
    
    @objc func clickOnBack()
    {
       // self.navigationController?.popToRootViewController(animated: true)
        
     //   var arrSaveSearch = NSMutableArray()
        
//        if UserDefaults.standard.object(forKey: "SaveSearch") != nil{
//
//            let arrObject = NSKeyedUnarchiver.unarchiveObject(with: UserDefaults.standard.object(forKey: "SaveSearch") as! Data) as! NSMutableArray
//
//            arrSaveSearch = NSMutableArray.init(array: arrObject)
//        }
//
//        for index in 0..<arrSaveSearch.count{
//            let dic = arrSaveSearch.object(at: index) as! NSMutableDictionary
//            dic.setValue("0", forKey: "Recent")
//            arrSaveSearch.replaceObject(at: index, with: dic)
//        }
//
//        let data = NSKeyedArchiver.archivedData(withRootObject: arrSaveSearch)
//        UserDefaults.standard.setValue(data, forKey: "SaveSearch")
//        UserDefaults.standard.synchronize()
        
        self.navigationController?.popViewController(animated: true)
     
    }
    
    @objc func clickOnMenu(){
        
        let homeMenuVC = objMainSB.instantiateViewController(withIdentifier: "HomeMainMenuVC") as! HomeMainMenuVC
        
        self.navigationController?.pushViewController(homeMenuVC, animated: true)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return  self.arrSearch.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        let imgView = cell.viewWithTag(1001) as!UIImageView
        let lblTitle = cell.viewWithTag(1002) as! UILabel
        let btnDelete = cell.viewWithTag(1003) as! UIButton
        
        let dicSearch = self.arrSearch.object(at: indexPath.item) as! NSMutableDictionary
        
        imgView.image = dicSearch.value(forKey: "searchImage") as? UIImage
        var strTitle = dicSearch.value(forKey: "searchText") as? String
        strTitle = strTitle?.replacingOccurrences(of: "https://", with: "")
        strTitle = strTitle?.replacingOccurrences(of: "http://", with: "")

        lblTitle.text = strTitle
        
        btnDelete.addTarget(self, action: #selector(self.clickOnDelete(sender:)), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize.init(width: UIScreen.main.bounds.size.width/2, height: (UIScreen.main.bounds.size.width/2)+50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let strText = (self.arrSearch.object(at: indexPath.item) as! NSDictionary).value(forKey: "searchText") as! NSString
        
        if strText.range(of: "http").location != NSNotFound
        {
            let dic = self.arrSearch.object(at: indexPath.item) as! NSDictionary
            
            let browserVC = objHomeSB.instantiateViewController(withIdentifier: "BrowserViewController") as! BrowserViewController
            browserVC.hidesBottomBarWhenPushed = true
            browserVC.strURL = dic.value(forKey: "searchText") as! String
            browserVC.selectedIndexHistory = indexPath.item
            browserVC.searchType = dic.value(forKey: "searchType") as? String
            self.navigationController?.pushViewController(browserVC, animated: true)
        }
        else{
            
            let searchVC = objHomeSB.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
            self.navigationItem.title = ""
            searchVC.dicSaveSearch = (self.arrSearch.object(at: indexPath.item) as! NSDictionary).mutableCopy() as! NSMutableDictionary
            searchVC.selectedIndexHistory = indexPath.item
            self.navigationController?.pushViewController(searchVC, animated: true)
        }
      
    }
    
    @objc func clickOnDelete(sender:UIButton)
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
        
        self.arrSearch.removeObject(at: (indexPath?.item)!)
        self.collectionView.reloadData()
        
        let data = NSKeyedArchiver.archivedData(withRootObject: self.arrSearch)
        UserDefaults.standard.set(data, forKey: "SaveSearch")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func clickOnClearAll(sender:UIButton)
    {
        self.arrSearch.removeAllObjects()
        
        self.collectionView.reloadData()
        
        let data = NSKeyedArchiver.archivedData(withRootObject: self.arrSearch)
        UserDefaults.standard.set(data, forKey: "SaveSearch")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func clickOnAdd(sender:UIButton)
    {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        
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
        
        if self.isFromSearch
        {
            self.navigationController?.popToRootViewController(animated: true)
        }
        else{
            let searchVC = objHomeSB.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
            self.navigationController?.pushViewController(searchVC, animated: true)
        }
        
    }
    
    @IBAction func clickOnDone(sender:UIButton)
    {
        self.navigationController?.popViewController(animated: true)
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
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            if ServiceName == "update-location"{
                
                appDelegate.dicLoginDetail = Response.object(forKey: "user") as? NSDictionary
                
                let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
                
                UserDefaults.standard.set(data, forKey: "LoginDetail")
                UserDefaults.standard.synchronize()
                
            }
            
            
        }
      
        
    }
}
