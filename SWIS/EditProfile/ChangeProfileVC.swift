//
//  ChangeProfileVC.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 27/02/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit
import SDWebImage

class ChangeProfileVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PECropViewControllerDelegate {

    @IBOutlet var imgView : UIImageView!
    @IBOutlet var btnUpdate : UIButton!
    
    var imageData:Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.btnUpdate.isEnabled = false
        
        var strUserImg = appDelegate.dicLoginDetail.value(forKey: "avatar") as? String
        strUserImg = strUserImg?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        self.imgView.sd_setImage(with: URL.init(string: strUserImg!), placeholderImage: nil, options: .refreshCached, completed: nil)
        
       // self.downloadBackgroundImage(from: URL.init(string: strUserImg!)!)
        
        btnUpdate.layer.cornerRadius = btnUpdate.frame.size.height/2
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "back-icon.png"), style: .plain, target: self, action: #selector(self.clickOnBack))
        
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickOnChangeBackgroundImage(sender:UIButton)
    {
        let alertController = UIAlertController.init(title: "Upload Photo", message: nil, preferredStyle: .actionSheet)
        
        
        let actionPhoto = UIAlertAction.init(title: "Photo Library", style: .default) { (action) in
            
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        alertController.addAction(actionPhoto)
        
        let actionCamera = UIAlertAction.init(title: "Camera", style: .default) { (action) in
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        alertController.addAction(actionCamera)
       
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(actionCancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        self.imgView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        picker.dismiss(animated: true) {
            self.openEditor()
        }
        
        picker.dismiss(animated: true, completion: nil)
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
        
        self.imgView.image = croppedImage
        self.btnUpdate.isEnabled = true

        imageData = self.imgView.image!.jpegData(compressionQuality: 0.5)! as Data
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
        var strUserImg = appDelegate.dicLoginDetail.value(forKey: "avatar") as? String
        strUserImg = strUserImg?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        SDImageCache.shared.removeImage(forKey: strUserImg, withCompletion: nil)
        
        SVProgressHUD.show()
        
        let strURL = "\(SERVER_URL)/update/avatar"
        
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
                    
                    if json!.value(forKey: "responseCode") as! Int == 200
                    {
                        let alertController = UIAlertController.init(title: "SWIS", message: json?.value(forKey: "responseMessage") as? String, preferredStyle: .alert)
                        
                        let actionOk = UIAlertAction.init(title: "OK", style: .default) { (action) in
                            
                            var strUserImg = appDelegate.dicLoginDetail.value(forKey: "avatar") as? String
                            strUserImg = strUserImg?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                            
                            SDImageCache.shared.removeImage(forKey: strUserImg, fromDisk: true, withCompletion: nil)

                            appDelegate.dicLoginDetail = json?.object(forKey: "user") as? NSDictionary
                            
                            var strProfile = appDelegate.dicLoginDetail.value(forKey: "avatar") as! String
                            strProfile = strProfile.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                            
                            appDelegate.downloadImage(from: URL.init(string: strProfile)!)
                            
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
        body.append("Content-Disposition: form-data; name=avatar; filename=\"\(filename)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(imageData as! Data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)
        
        return body
    }


}
