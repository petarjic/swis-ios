//
//  ShareProfileVC.swift
//  SWIS
//
//  Created by Dharmesh Sonani on 12/01/19.
//  Copyright © 2019 Dharmesh Sonani. All rights reserved.
//

import UIKit

class ProfileBioVC: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,responseDelegate,PECropViewControllerDelegate,UITextViewDelegate {
    
    @IBOutlet var txtBio : UITextView!
    @IBOutlet var btnContinue : UIButton!
    @IBOutlet var lblChoose : UILabel!
    @IBOutlet var lblName : UILabel!
    @IBOutlet var lblUsername : UILabel!
    @IBOutlet weak var viewImgUser: UIView!
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var lblUploadImg: UILabel!
    @IBOutlet weak var lblLine: UILabel!
    @IBOutlet weak var txtHeight: NSLayoutConstraint!

    typealias CompletionHandler = (_ imageData:NSString) -> Void
    var imageBase64 = NSString()
    var imageData:Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        btnContinue.layer.cornerRadius = btnContinue.frame.size.height/2
        
        lblChoose.attributedText = NSAttributedString.init(string: lblChoose.text!, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.kern:2.0])
        
        self.setupTextView(textView: txtBio)
        
        self.lblName.text = appDelegate.dicLoginDetail.value(forKey: "name") as? String
        self.lblUsername.text = "@\(appDelegate.dicLoginDetail.value(forKey: "username") as! String)"
        
        let tapgesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnOnUploadImage))
        viewImgUser.addGestureRecognizer(tapgesture)

    }
    
    func setupTextView(textView:UITextView)
    {
        textView.placeholder = "Write a bio about yourself!"
        textView.placeholderColor = UIColor.white
    }
    
    @IBAction func clickOnContinue(sender:UIButton)
    {
        if self.txtBio.text == ""
        {
            self.view.makeToast("Please enter bio")
        }
        else{
            if self.imageData != nil{
                self.uploadProfile()
            }
            else{
                self.updateProfile()
            }
            
        }
        
        
    }
    
    @objc func updateProfile()
    {
        let strParameters = String.init(format: "name=%@&bio=%@",self.lblName.text!,self.txtBio.text!)
        
        let strURL = "\(SERVER_URL)/update/profile"
        
        WebParserWS.fetchDataWithURL(url: strURL as NSString, type: .TYPE_POST, ServiceName: "profile", bodyObject: strParameters as AnyObject, delegate: self, isShowProgress: true)
    }
    
    
    func didFinishWithSuccess(ServiceName: String, Response: AnyObject) {
        
        print(Response)
        
        if Response.value(forKey: "responseCode") as! Int == 200
        {
            DispatchQueue.main.async {
                
                appDelegate.dicLoginDetail = Response.object(forKey: "user") as? NSDictionary
                
                let data = NSKeyedArchiver.archivedData(withRootObject: appDelegate.dicLoginDetail)
                
                UserDefaults.standard.set(data, forKey: "LoginDetail")
                UserDefaults.standard.synchronize()
                
                let findFreindVC = objAuthenticationSB.instantiateViewController(withIdentifier: "FindFreindsVC") as! FindFreindsVC
                
                self.navigationController?.pushViewController(findFreindVC, animated: true)
            }
           
        }
    }
    
    @objc func tapOnOnUploadImage()
    {
        
        let alertController = UIAlertController.init(title: "Upload Photo", message: nil, preferredStyle: .actionSheet)
        
        let actionCamera = UIAlertAction.init(title: "Camera", style: .default) { (action) in
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            
            self.present(imagePickerController, animated: true, completion: nil)
        }
        
        alertController.addAction(actionCamera)
        
        let actionPhoto = UIAlertAction.init(title: "Photo Library", style: .default) { (action) in
            
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .photoLibrary
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            
            self.lblUploadImg.isHidden = true
            
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
        
        self.imgUser.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        
        picker.dismiss(animated: true) {
            self.openEditor()
        }
        
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        self.lblUploadImg.isHidden = false
        
        picker.dismiss(animated: true, completion: nil)


    }
    
    func openEditor()
    {
        let controller = PECropViewController()
        controller.delegate = self
        controller.image = self.imgUser.image
        controller.keepingCropAspectRatio = true
        
        let width = self.imgUser.image?.size.width
       let height = self.imgUser.image?.size.height
        
       let length = min(width!, height!)
        
        controller.imageCropRect = CGRect.init(x: (width!-length)/2, y: (height!-length)/2, width: length, height: length)
        
        let navigation = UINavigationController.init(rootViewController: controller)
        navigation.navigationBar.tintColor = UIColor.black
        self.present(navigation, animated: true, completion: nil)
    }
    
    func cropViewController(_ controller: PECropViewController!, didFinishCroppingImage croppedImage: UIImage!) {
        
        controller.dismiss(animated: true, completion: nil)
        
        self.lblUploadImg.isHidden = true
        self.imgUser.image = croppedImage
        
        imageData = self.imgUser.image!.pngData()
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
    
    func uploadProfile()
    {
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
                        self.updateProfile()
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
    
    func textViewDidChange(_ textView: UITextView) {
        
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
        
        txtHeight.constant = newFrame.size.height
        
        lblLine.frame = CGRect.init(x: 25, y: textView.frame.size.height+textView.frame.origin.y, width: UIScreen.main.bounds.size.width-50, height: 1)
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView.text.count > 160{
            
            if text == ""
            {
                return true
            }
            
            return false
        }
        else{
            return true
        }
    }
}

