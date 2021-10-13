//
//  ChangeBackgroundVC.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 27/02/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import SDWebImage

class ChangeBackgroundVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PECropViewControllerDelegate {
    
    @IBOutlet var imgView : UIImageView!
    @IBOutlet var btnUpdate : UIButton!
    @IBOutlet var btnBackground : UIButton!
    @IBOutlet var scrollView : UIScrollView!

    @IBOutlet weak var cropPickerView: CropPickerView!
    
    var imageData:Data?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        var strBackgroundImg = appDelegate.dicLoginDetail.value(forKey: "background_url") as? String
        strBackgroundImg = strBackgroundImg?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        self.imgView.sd_setImage(with: URL.init(string: strBackgroundImg!), placeholderImage: nil, options: .refreshCached) { (image,error,cacheType,url) in
            
            self.imgView.translatesAutoresizingMaskIntoConstraints = true
            
            let ratio = image!.size.width / image!.size.height
            if self.imgView.frame.size.width > self.imgView.frame.size.height {
                let newHeight = self.imgView.frame.size.width / ratio
                self.imgView.frame.size = CGSize(width: self.imgView.frame.width, height: newHeight)
            }
            else{
                let newWidth = self.imgView.frame.size.height * ratio
                self.imgView.frame.size = CGSize(width: newWidth, height: self.imgView.frame.size.height)
            }
            
            self.imgView.image  = image
            
            var X = self.view.frame.size.width - self.imgView.frame.size.width
            
            if X > 0{
                
                var frame = CGRect()
                frame  = self.imgView.frame
                frame.origin.x = X/2
                self.imgView.frame = frame
            }
            else{
                
                var frame = CGRect()
                frame  = self.imgView.frame
                frame.origin.x = 10
                frame.size.width = self.view.frame.size.width - 20
                self.imgView.frame = frame
            }
        }
        
        // self.downloadBackgroundImage(from: URL.init(string: strBackgroundImg!)!)
        
        btnUpdate.layer.cornerRadius = btnUpdate.frame.size.height/2
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back-icon.png"), style: .plain, target: self, action: #selector(self.clickOnBack))
        
        self.navigationController?.navigationBar.isTranslucent = false
   
        self.btnUpdate.isEnabled = false
    
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadBackgroundImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() {
                
                let img = UIImage(data: data)
                self.imgView.image = img
            }
        }
    }
    
    @objc func clickOnBack()
    {
        if self.cropPickerView.isHidden{
            self.navigationController?.popViewController(animated: true)
        }
        else{
            self.cropPickerView.isHidden = true
            
            var strBackgroundImg = appDelegate.dicLoginDetail.value(forKey: "background_url") as? String
            strBackgroundImg = strBackgroundImg?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            self.imgView.sd_setImage(with: URL.init(string: strBackgroundImg!), placeholderImage: nil, options: .refreshCached, context: nil)
        }
        
    }
    
    @IBAction func clickOnChangeBackgroundImage(sender:UIButton)
    {
        let alertController = UIAlertController.init(title: "Upload Photo", message: nil, preferredStyle: .actionSheet)
        
        let actionCamera = UIAlertAction.init(title: "Camera", style: .default) { (action) in
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = false
            imagePickerController.delegate = self
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        alertController.addAction(actionCamera)
        
        let actionPhoto = UIAlertAction.init(title: "Photo Library", style: .default) { (action) in
            
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = false
            imagePickerController.delegate = self
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        alertController.addAction(actionPhoto)
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(actionCancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        let newImage = self.fixOrientation(img: image!)
        
        self.imgView.image = newImage
        self.btnUpdate.isEnabled = true
        
        picker.dismiss(animated: true) {
          
            self.cropPickerView.isHidden = false
            
            self.cropPickerView.image = newImage
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "crop", style: .plain, target: self, action: #selector(self.clickOnCrop))
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func fixOrientation(img: UIImage) -> UIImage {
        if (img.imageOrientation == .up) {
            return img
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)
        
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    @objc func clickOnCrop()
    {
        
        self.cropPickerView.crop { (error, image) in
            
            self.navigationItem.rightBarButtonItem = nil
            
            self.imgView.translatesAutoresizingMaskIntoConstraints = true

            let ratio = image!.size.width / image!.size.height
            if self.imgView.frame.size.width > self.imgView.frame.size.height {
                let newHeight = self.imgView.frame.size.width / ratio
                self.imgView.frame.size = CGSize(width: self.imgView.frame.width, height: newHeight)
            }
            else{
                let newWidth = self.imgView.frame.size.height * ratio
                self.imgView.frame.size = CGSize(width: newWidth, height: self.imgView.frame.size.height)
            }
            
            self.imgView.image  = image
           
            var X = self.view.frame.size.width - self.imgView.frame.size.width

            if X > 0{
                
                var frame = CGRect()
                frame  = self.imgView.frame
                frame.origin.x = X/2
                self.imgView.frame = frame
            }
            else{
                
                var frame = CGRect()
                frame  = self.imgView.frame
                frame.origin.x = 10
                frame.size.width = self.view.frame.size.width - 20
                self.imgView.frame = frame
            }
            
            self.btnUpdate.translatesAutoresizingMaskIntoConstraints = true
            self.btnBackground.translatesAutoresizingMaskIntoConstraints = true

            let mainView = self.view.viewWithTag(10) as UIView?
            mainView!.translatesAutoresizingMaskIntoConstraints = true

            var frame = CGRect()
            
            frame  = self.btnBackground!.frame
            frame.origin.y = self.imgView.frame.origin.y + self.imgView.frame.size.height + 15
            self.btnBackground!.frame = frame
            
            frame  = self.btnUpdate!.frame
            frame.origin.y = self.btnBackground.frame.origin.y + self.btnBackground.frame.size.height + 10
            self.btnUpdate!.frame = frame
            
            frame  = mainView!.frame
            frame.size.height = self.btnUpdate.frame.origin.y + self.btnUpdate.frame.size.height
            mainView!.frame = frame
            
            self.scrollView.translatesAutoresizingMaskIntoConstraints = true
            
            self.scrollView.contentSize = CGSize.init(width: self.view.frame.size.width, height: (mainView?.frame.size.height)! + 20)
            
            let uploadImg =  self.ResizeImage(image: self.imgView.image!, targetSize: CGSize.init(width: UIScreen.main.bounds.size.width, height: (image?.size.height)!))
            
            self.imageData = uploadImg.pngData()
            self.cropPickerView.isHidden = true
            
        }
    }
    
    func openEditor()
    {
        let controller = PECropViewController()
        controller.delegate = self
        controller.image = self.imgView.image
        controller.keepingCropAspectRatio = true
        
        let width = self.imgView.image?.size.width
        let height = self.imgView.image?.size.height
        
        let length = min(width!, height!)
        
        controller.imageCropRect = CGRect.init(x: (width!-length)/2, y: (height!-length)/2, width: length, height: length)
        
        let navigation = UINavigationController.init(rootViewController: controller)
        navigation.navigationBar.tintColor = UIColor.black
        self.present(navigation, animated: true, completion: nil)
    }
    
    func cropViewController(_ controller: PECropViewController!, didFinishCroppingImage croppedImage: UIImage!) {
        
        controller.dismiss(animated: true, completion: nil)
        
        self.imgView.image = self.ResizeImage(image: self.imgView.image!, targetSize: CGSize.init(width: 280, height: 200))
        
        imageData = self.imgView.image!.pngData()
    }
    
    func cropViewControllerDidCancel(_ controller: PECropViewController!) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func ResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize.init(width: size.width * heightRatio, height: size.height * heightRatio)
            
        } else {
            newSize = CGSize.init(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    
    @IBAction func clickOnUpdate(sender:UIButton)
    {
        self.uploadBackgroundImage()
    }
    
    func uploadBackgroundImage()
    {
      

        SVProgressHUD.show()
        
        let strURL = "\(SERVER_URL)/update/background"
        
        let request = NSMutableURLRequest(url:URL.init(string: strURL) as! URL);
        request.httpMethod = "POST";
        
        let boundary = generateBoundaryString()
        
        request.setValue("Bearer \(UserDefaults.standard.value(forKey: "api_token") as! String)", forHTTPHeaderField: "Authorization")
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if(imageData==nil)  { return; }
        
        request.httpBody = createBodyWithParameters(parameters: nil, filePathKey: "avatar", boundary: boundary) as Data
        
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        {
            data, response, error in
            
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            
            
            if error != nil
            {
                print("******** error=\(error)")
                return
            }
            
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("\(responseString!)")
            
            
            DispatchQueue.main.async {
                
                do
                {
                    let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    print(json!)
                    
                    if json!.value(forKey: "responseCode") as? Int == 200
                    {
                        let alertController = UIAlertController.init(title: "SWIS", message: json?.value(forKey: "responseMessage") as? String, preferredStyle: .alert)
                        
                        let actionOk = UIAlertAction.init(title: "OK", style: .default) { (action) in
                            
                            var strBackgroundImg = appDelegate.dicLoginDetail.value(forKey: "background_url") as? String
                            
                            strBackgroundImg = strBackgroundImg?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                            
                            SDImageCache.shared.removeImage(forKey: strBackgroundImg, fromDisk: true, withCompletion: nil)
                            
                            appDelegate.dicLoginDetail = json?.object(forKey: "user") as? NSDictionary
                            
                            let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
                            
                            UserDefaults.standard.set(data, forKey: "LoginDetail")
                            UserDefaults.standard.synchronize()
                            
                            alertController.dismiss(animated: true, completion: nil)
                            
                        }
                        
                        alertController.addAction(actionOk)
                        
                        self.present(alertController, animated: true, completion: nil)
                        
                    }
                    
                }
                catch
                {
                    print("\n\n*************ERROR******** => \(error)\n\n")
                }
            }
            
            
        }
        
        task.resume()
        
    }
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String!, boundary: String) -> NSData {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: String.Encoding.utf8)!)
                body.append("\(value)\r\n".data(using: String.Encoding.utf8)!)
                
            }
        }
        
        let filename = "Profile.png"
        let mimetype = "image/png"
        
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=background; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageData as! Data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        return body
    }
    
    
}
extension UIImage {
    
    func resize(maxWidthHeight : Double)-> UIImage? {
        
        let actualHeight = Double(size.height)
        let actualWidth = Double(size.width)
        var maxWidth = 0.0
        var maxHeight = 0.0
        
        if actualWidth > actualHeight {
            maxWidth = maxWidthHeight
            let per = (100.0 * maxWidthHeight / actualWidth)
            maxHeight = (actualHeight * per) / 100.0
        }else{
            maxHeight = maxWidthHeight
            let per = (100.0 * maxWidthHeight / actualHeight)
            maxWidth = (actualWidth * per) / 100.0
        }
        
        let hasAlpha = true
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: maxWidth, height: maxHeight), !hasAlpha, scale)
        self.draw(in: CGRect(origin: .zero, size: CGSize(width: maxWidth, height: maxHeight)))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
}
