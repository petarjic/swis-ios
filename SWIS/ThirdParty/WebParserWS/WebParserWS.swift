
//
//  WebParserWS.swift
//  MyPetCredential
//
//  Created by Gong on 1/1/16.
//  Copyright © 2016 Gong. All rights reserved.
//

import UIKit

enum ServiceType : String
{
    case TYPE_GET = "TYPE_GET",TYPE_POST = "TYPE_POST",TYPE_POST_KEY = "TYPE_POST_KEY",TYPE_DELETE = "TYPE_DELETE",TYPE_POST_RAWDATA = "TYPE_POST_RAWDATA",TYPE_PUT = "TYPE_PUT"
}

protocol responseDelegate
{
    func didFinishWithSuccess(ServiceName:String,Response:AnyObject)
}

var Delegate: responseDelegate?

class WebParserWS: NSObject
{
    
    class func fetchDataWithURL(url:NSString,type:ServiceType,ServiceName:String,bodyObject:AnyObject?,delegate:responseDelegate,isShowProgress:Bool)
    {
        let sessionConfig = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

        var strUrl = NSString(format:"%@",url)
        strUrl = strUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) as! NSString
        
        let URL = NSURL(string:strUrl as String)
        
        let request = NSMutableURLRequest(url: URL! as URL)

        if  UserDefaults.standard.value(forKey: "api_token") != nil{
            
            request.setValue("Bearer \(UserDefaults.standard.value(forKey: "api_token") as! String)", forHTTPHeaderField: "Authorization")
        }
        
       // NSLog("URL: %@", url)
       
        if(GlobalFunction.iSinternetConnection())
        {
            if(isShowProgress)
            {
               SVProgressHUD.show()
            }
            else{
                SVProgressHUD.dismiss()
            }
            
            if(type == ServiceType.TYPE_POST)
            {
                if bodyObject != nil{
                  
                    NSLog("Parameters:%@",bodyObject! as! String)
               
                    request.httpMethod = "POST"
                    
                    do
                    {
                        request.httpBody = bodyObject!.data(using: String.Encoding.utf8.rawValue)
                    }
                    catch
                    {
                        print("Error is \(error)")
                        
                    }
                
                }
            }
            if(type == ServiceType.TYPE_PUT)
            {
                NSLog("Parameters:%@",bodyObject! as! String)
                
                request.httpMethod = "PUT"
                
                do
                {
                    request.httpBody = bodyObject!.data(using: String.Encoding.utf8.rawValue)
                }
                catch
                {
                    print("Error is \(error)")
                    
                }
                
            }
            else if(type == ServiceType.TYPE_POST_RAWDATA)
            {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
               
                if ServiceName == "update-location" || ServiceName == "approve-request"
                {
                    request.httpMethod = "PUT"
                }
                else if ServiceName == "unfollow" || ServiceName == "decline-request" || ServiceName == "delete_post"
                {
                    request.httpMethod = "DELETE"
                }
                else{
                    request.httpMethod = "POST"
                }
                
                if bodyObject != nil{
                
                do
                {
                    
                    let data = try JSONSerialization.data(withJSONObject: bodyObject, options: JSONSerialization.WritingOptions(rawValue: UInt(0)))
                    
                    request.httpBody = data
                    
                }
                catch
                {
                    print("Error is \(error)")
                    
                }
                }
                
            }
            else if(type == ServiceType.TYPE_POST_KEY)
            {
                request.httpMethod = "POST"
                
                request.httpBody = (strUrl.data(using: String.Encoding.utf8.rawValue)! as NSData) as Data
            }
            else if (type == ServiceType.TYPE_GET)
            {
                request.httpMethod = "GET"
            }
            else if(type == ServiceType.TYPE_DELETE)
            {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                request.httpMethod = "DELETE"
                
                if bodyObject != nil{
                    
                    do
                    {
                        
                        let data = try JSONSerialization.data(withJSONObject: bodyObject, options: JSONSerialization.WritingOptions(rawValue: UInt(0)))
                        
                        request.httpBody = data
                        
                    }
                    catch
                    {
                        print("Error is \(error)")
                        
                    }
                }
            }
            
            let task =  session.dataTask(with: request as URLRequest, completionHandler: {(data,response, error) -> Void in
              
                DispatchQueue.main.sync()
                {
                    self.hideProgressHud()
                }
                
                if (error == nil) {
                    
                    let responseString = String(data: data!, encoding: String.Encoding.utf8)
                    
                    NSLog("%@",responseString!)
            
                    do
                    {
                        let dicResonseData = try JSONSerialization.jsonObject(with: data!,
                                                                                      options:JSONSerialization.ReadingOptions.mutableContainers) as! AnyObject
                         delegate.didFinishWithSuccess(ServiceName: ServiceName,Response:dicResonseData)
                    }
                    catch
                    {
                        print("Error is \(error)")
                        
                       // SVProgressHUD.dismiss()
                    }
                    
                }
                else {
                    
                    print("URL Session Task Failed: %@", error!.localizedDescription);
                    
                  //  SVProgressHUD.dismiss()
                }
            })
            task.resume()

            
        }
        else
        {
            GlobalFunction.showAlertMessage("Please check your Internet connection")
        }
        
    }
    
    class func hideProgressHud()
    {
        SVProgressHUD.dismiss()
    }
    
}


