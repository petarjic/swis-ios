//
//  AppDelegate.swift
//  SWIS
//
//  Created by Dharmesh Sonani on
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseMessaging
import Firebase
import FirebaseInstanceID
import UserNotifications
import Fabric
import Crashlytics
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UITabBarControllerDelegate,UNUserNotificationCenterDelegate,MessagingDelegate,responseDelegate,CLLocationManagerDelegate {
    
    var window: UIWindow?
    
    var ObjRandomNumber: Int?
    var dicLoginDetail : NSDictionary!
    var bottomView : UIView!
    var strDeviceToken : String = ""
    
    var strPrivacy = NSString()
    var strAbout = NSString()
    var strFaq = NSString()
    var strTerm = NSString()
    
    var locationManager = CLLocationManager()
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    var strCountry : String = ""
    var strCity : String = ""
    var strZip : String = ""
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        Fabric.with([Crashlytics.self])
        
        for family in UIFont.familyNames {
            print("\(family)")
            
            for name in UIFont.fontNames(forFamilyName: family) {
                print("   \(name)")
            }
        }
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        IQKeyboardManager.shared.enable = true
        
        
        if UserDefaults.standard.object(forKey: "LoginDetail") != nil{
            
           // self.setupAddress()
            
            let data = UserDefaults.standard.object(forKey: "LoginDetail") as! Data
            
            self.dicLoginDetail = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSDictionary
            
            
            if appDelegate.dicLoginDetail.value(forKey: "phone") as? String == nil
            {
                
                let vc = objAuthenticationSB.instantiateViewController(withIdentifier: "EnterPhoneNumberVC") as! EnterPhoneNumberVC
                
                let navigation = UINavigationController.init(rootViewController: vc)
                navigation.navigationBar.isHidden = true
                
                self.window?.rootViewController = navigation
                
                self.window?.makeKeyAndVisible()
            }
            else if appDelegate.dicLoginDetail.value(forKey: "bio") as? String == nil
            {
                
                let vc = objAuthenticationSB.instantiateViewController(withIdentifier: "ProfileBioVC") as! ProfileBioVC
                
                let navigation = UINavigationController.init(rootViewController: vc)
                navigation.navigationBar.isHidden = true
                
                self.window?.rootViewController = navigation
                
                self.window?.makeKeyAndVisible()
            }
            else{
                self.setupTabbarcontroller(selectedIndex: 0)
            }
            
        }
        
        FirebaseApp.configure()
        
        self.perform(#selector(self.setupNotification), with: application, afterDelay: 1.0)
        
        self.ConnectToFCM()
        
        self.getPrivacy()
        self.getFaq()
        self.getTerm()
        self.getAbout()
        
     
        return true
    }
    
    @objc func setupNotification(application:UIApplication)
    {
        
        if #available(iOS 10.0, *) {
            
            let center = UNUserNotificationCenter.current()
            center.delegate  = self
            center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
                if (granted)
                {
                    DispatchQueue.main.async {
                        application.registerForRemoteNotifications()
                    }
                    
                }
            }
        }
        else{
            
            let settings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        
        latitude = (location?.coordinate.latitude)!
        longitude = (location?.coordinate.longitude)!
        
        locationManager.stopUpdatingLocation()
         if UserDefaults.standard.object(forKey: "LoginDetail") != nil{
           self.setupAddress()
        }
    }
    
    
    
    func getPrivacy() {
        
        let strURL = "\(SERVER_URL)/settings/privacy"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "privacy", bodyObject: nil, delegate: self, isShowProgress: false)
        
    }
    
    func getTerm(){
        
        let strURL = "\(SERVER_URL)/settings/term"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "term", bodyObject: nil, delegate: self, isShowProgress: false)
        
    }
    
    func getFaq(){
        
        let strURL = "\(SERVER_URL)/settings/faq"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "faq", bodyObject: nil, delegate: self, isShowProgress: false)
        
    }
    
    func getAbout(){
        
        let strURL = "\(SERVER_URL)/settings/about"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_GET, ServiceName: "about", bodyObject: nil, delegate: self, isShowProgress: false)
        
    }
    
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        DispatchQueue.main.async {
            
            if ServiceName == "privacy"{
                
                self.strPrivacy = Response.object(forKey: "data") as! NSString
                
            }else if ServiceName == "faq"{
                
                self.strFaq = Response.object(forKey: "data") as! NSString
                
            }else if ServiceName == "about"{
                
                self.strAbout = Response.object(forKey: "data") as! NSString
                
            }
            else if ServiceName == "update-location"{
                
                appDelegate.dicLoginDetail = Response.object(forKey: "user") as? NSDictionary
                
                let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
                
                UserDefaults.standard.set(data, forKey: "LoginDetail")
                UserDefaults.standard.synchronize()
                
            }
            else{
                
                self.strTerm = Response.object(forKey: "data") as! NSString
            }
            
        }
    }
    
    
    func ConnectToFCM() {
        
        Messaging.messaging().shouldEstablishDirectChannel = true
        Messaging.messaging().delegate = self
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                self.strDeviceToken = result.token
                
                //--
                UserDefaults.standard.set(self.strDeviceToken, forKey: "DeviceToken")
                UserDefaults.standard.synchronize()
            }
        }
        
    }
    
    func setupTabbarcontroller(selectedIndex:NSInteger)
    {
        let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        let tabBarcontroller = storyBoard.instantiateViewController(withIdentifier: "tabBarcontroller") as! UITabBarController
        
        tabBarcontroller.delegate = self
        
        bottomView = UIView()
        bottomView.frame = CGRect.init(x: ((CGFloat)(selectedIndex) * (UIScreen.main.bounds.size.width/5)) , y: tabBarcontroller.tabBar.frame.size.height - 5, width: UIScreen.main.bounds.size.width/5, height: 5)
        
        tabBarcontroller.tabBar.addSubview(bottomView)
        
        let lblLine = UILabel()
        lblLine.backgroundColor = UIColor.init(red: 0.0/255.0, green: 164.0/255.0, blue: 229.0/255.0, alpha: 1.0)
        
        if UIScreen.main.sizeType == .iPhnoe11 || UIScreen.main.sizeType == .iPhone11Pro || UIScreen.main.sizeType == .iPhopne11ProMax {
            lblLine.frame = CGRect.init(x: 10, y: 3, width: bottomView.frame.size.width - 20, height: 5)
        } else {
            lblLine.frame = CGRect.init(x: 10, y: 0, width: bottomView.frame.size.width - 20, height: 5)
        }
        
        lblLine.layer.cornerRadius = lblLine.frame.size.height/2
        bottomView.addSubview(lblLine)
        
        
        for navigation in tabBarcontroller.viewControllers!
        {
            let nav = navigation as! UINavigationController
            nav.navigationBar.barTintColor = navigationColor
            nav.navigationBar.tintColor = UIColor.black
            nav.navigationBar.isHidden = false
            nav.navigationBar.isTranslucent  = false
            let controller = nav.viewControllers[0]
            
            var strImg : String = ""
            var strSelectedImg : String = ""
            
            if controller.isKind(of: HomeViewController.self)
            {
                strImg = "home.png"
                strSelectedImg = "home-select.png"
            }
            else if controller.isKind(of: TrendingViewController.self)
            //else if controller.isKind(of: SearchViewController.self)
            {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
                
                strImg = "search.png"
                strSelectedImg = "search-select.png"
            }
            else if controller.isKind(of: LocationSearchVC.self){
                
                
                strImg = "location.png"
                strSelectedImg = "location-select.png"
            }
            else if controller.isKind(of: FriendsVC.self){
                
                strImg = "friend.png"
                strSelectedImg = "friend-select.png"
            }
            else {
                strImg = "fullname"
                strSelectedImg = "fullname"
            }
            
            let image = UIImage.init(named: strImg)
        //    image = image?.withRenderingMode(.alwaysOriginal)
            
            var selectedImg = UIImage.init(named: strSelectedImg)
            selectedImg = selectedImg?.withRenderingMode(.alwaysOriginal)
            
            navigation.tabBarItem.image = image
            navigation.tabBarItem.selectedImage = selectedImg
            navigation.tabBarItem.title = ""
            
            navigation.tabBarItem.imageInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: -3, right: 0)
        }
        
        tabBarcontroller.tabBar.barTintColor = navigationColor
        tabBarcontroller.tabBar.isTranslucent = false
        tabBarcontroller.selectedIndex = selectedIndex
        
        
        self.window?.rootViewController = tabBarcontroller
        self.window?.makeKeyAndVisible()
        
        var strProfile = self.dicLoginDetail.value(forKey: "avatar") as! String
        strProfile = strProfile.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        self.downloadImage(from: URL.init(string: strProfile)!)
    }
    
    func downloadImage(from url: URL) {
        print("Download Started")
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                
                if (appDelegate.window?.rootViewController?.isKind(of: UITabBarController.self))!{
                    
                    let tabBarController = appDelegate.window?.rootViewController as! UITabBarController
                    let img = UIImage(data: data)
                    var image = img?.circularImage(size: CGSize.init(width: 30, height: 30))
                    image = image?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                    tabBarController.tabBar.items![4].image = image
                    tabBarController.tabBar.items![4].selectedImage = image
                }
            }
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let index = tabBarController.viewControllers?.lastIndex(of: viewController)
        
        UIView.animate(withDuration: 0.5) {
            
            var frame = self.bottomView.frame
            frame.origin.x = (CGFloat)(index!) * (tabBarController.tabBar.frame.size.width/5)
            self.bottomView.frame  = frame
        }
        
        let navigationController = viewController as? UINavigationController
        
        if index == 2 {
            let randomIntFrom0To50 = Int.random(in: 1000 ..< 50000)
            appDelegate.ObjRandomNumber = randomIntFrom0To50
        }
        
        if index == 4{
            
            let profileVC = navigationController?.viewControllers[0] as! ProfileViewController
            profileVC.dicUserDetail = NSDictionary()
        }
        
        navigationController?.popToRootViewController(animated: true)
        
    }
    
    func setHome()
    {
        let tabBarController = self.window?.rootViewController as! UITabBarController
        
        UIView.animate(withDuration: 0.5) {
            
            var frame = self.bottomView.frame
            frame.origin.x = (CGFloat)(0.0) * (tabBarController.tabBar.frame.size.width/5)
            self.bottomView.frame  = frame
        }
        
        let navigationController = tabBarController.viewControllers![0] as? UINavigationController
        navigationController?.popToRootViewController(animated: true)
        
        tabBarController.selectedIndex = 0
    }
    
    func setupRootVC()
    {
        
        let vc = objAuthenticationSB.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        let navigation = UINavigationController.init(rootViewController: vc)
        navigation.navigationBar.isHidden = true
        
        self.window?.rootViewController = navigation
        
        self.window?.makeKeyAndVisible()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)
        
        let dict = userInfo
        
        //let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        if dict["gcm.notification.type"] as! String == "4"{
            
            let tabBarController = self.window?.rootViewController as! UITabBarController
            
            let navigation = tabBarController.selectedViewController as! UINavigationController
            
            let followers = objHomeSB.instantiateViewController(withIdentifier: "FollowersScreeenVC") as! FollowersScreeenVC
            
            navigation.pushViewController(followers, animated: true)
            
        }
        else if dict["gcm.notification.type"] as! String == "5"{
            
            let tabBarController = self.window?.rootViewController as! UITabBarController
            
            let navigation = tabBarController.selectedViewController as! UINavigationController
            
            let profileViewController = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            profileViewController.isFromNitification = true
           profileViewController.objNotificationID = dict["gcm.notification.id"] as! String
            navigation.pushViewController(profileViewController, animated: true)
            
        }
        else if dict["gcm.notification.type"] as! String == "3"{
            
            let tabBarController = self.window?.rootViewController as! UITabBarController
            
            let navigation = tabBarController.selectedViewController as! UINavigationController
            
            let followRequestVC = objHomeSB.instantiateViewController(withIdentifier: "FollowRequestScreenVC") as! FollowRequestScreenVC
            
            navigation.pushViewController(followRequestVC, animated: true)
            
        }
        else if dict["gcm.notification.type"] as! String == "2"{
            
            let tabBarController = self.window?.rootViewController as! UITabBarController
            
            let navigation = tabBarController.selectedViewController as! UINavigationController
            
            let commentVC = objHomeSB.instantiateViewController(withIdentifier: "CommnetViewController") as! CommnetViewController
            commentVC.strPostId = dict["gcm.notification.main_post_id"] as! String
            commentVC.strCommentId = dict["gcm.notification.id"] as! String
            commentVC.hidesBottomBarWhenPushed = true
            navigation.pushViewController(commentVC, animated: true)
            
        }
        else if dict["gcm.notification.type"] as! String == "1"{
            
            let tabBarController = self.window?.rootViewController as! UITabBarController
            
            let navigation = tabBarController.selectedViewController as! UINavigationController
            
            let likeVC = objHomeSB.instantiateViewController(withIdentifier: "LikeViewController") as! LikeViewController
            likeVC.strPostId = dict["gcm.notification.id"] as! String
            
            navigation.pushViewController(likeVC, animated: true)
            
        }
        
        completionHandler(.newData)
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        print("Firebase registration token: \(fcmToken)")
        //--
        self.strDeviceToken = fcmToken
        UserDefaults.standard.set(self.strDeviceToken, forKey: "DeviceToken")
        UserDefaults.standard.synchronize()
    }
    
   
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print(response.notification.request.content.userInfo)
        
        let dict = response.notification.request.content.userInfo
        
        //let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)
        
        if dict["gcm.notification.type"] as! String == "4"{
            
            let tabBarController = self.window?.rootViewController as! UITabBarController

            let navigation = tabBarController.selectedViewController as! UINavigationController
            
            let followers = objHomeSB.instantiateViewController(withIdentifier: "FollowersScreeenVC") as! FollowersScreeenVC
            followers.dicUserDetail = self.dicLoginDetail
            navigation.pushViewController(followers, animated: true)

        }
        else if dict["gcm.notification.type"] as! String == "5"{
            
            let tabBarController = self.window?.rootViewController as! UITabBarController
            
            let navigation = tabBarController.selectedViewController as! UINavigationController
            
            let profileViewController = objMainSB.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            profileViewController.isFromNitification = true
            profileViewController.objNotificationID = dict["gcm.notification.id"] as! String
            navigation.pushViewController(profileViewController, animated: true)
            
        }
        else if dict["gcm.notification.type"] as! String == "3"{
            
            let tabBarController = self.window?.rootViewController as! UITabBarController
            
            let navigation = tabBarController.selectedViewController as! UINavigationController
            
            let followRequestVC = objHomeSB.instantiateViewController(withIdentifier: "FollowRequestScreenVC") as! FollowRequestScreenVC
            
            navigation.pushViewController(followRequestVC, animated: true)
            
        }
        else if dict["gcm.notification.type"] as! String == "2"{
            
            let tabBarController = self.window?.rootViewController as! UITabBarController
            
            let navigation = tabBarController.selectedViewController as! UINavigationController
            
            let commentVC = objHomeSB.instantiateViewController(withIdentifier: "CommnetViewController") as! CommnetViewController
            commentVC.strPostId = dict["gcm.notification.main_post_id"] as! String
            commentVC.strCommentId = dict["gcm.notification.id"] as! String
            commentVC.hidesBottomBarWhenPushed = true
            navigation.pushViewController(commentVC, animated: true)
            
        }
        else if dict["gcm.notification.type"] as! String == "1"{
            
            let tabBarController = self.window?.rootViewController as! UITabBarController
            
            let navigation = tabBarController.selectedViewController as! UINavigationController
            
            let likeVC = objHomeSB.instantiateViewController(withIdentifier: "LikeViewController") as! LikeViewController
            likeVC.strPostId = dict["gcm.notification.id"] as! String
            
            navigation.pushViewController(likeVC, animated: true)
            
        }
        
        completionHandler()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler(.alert)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
        print("%@", remoteMessage.appData)
        
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
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
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        self.ConnectToFCM()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

extension UIScreen {

    enum SizeType: CGFloat {
        case Unknown = 0.0
        case iPhone4 = 960.0
        case iPhone5 = 1136.0
        case iPhone6 = 1334.0
        case iPhone6Plus = 1920.0
        case iPhnoe11 = 1792.0
        case iPhone11Pro = 2436.0
        case iPhopne11ProMax = 2688.0
        
    }

    var sizeType: SizeType {
        let height = nativeBounds.height
        guard let sizeType = SizeType(rawValue: height) else { return .Unknown }
        return sizeType
    }
}
