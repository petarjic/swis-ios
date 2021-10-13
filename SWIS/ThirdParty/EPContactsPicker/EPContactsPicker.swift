//
//  EPContactsPicker.swift
//  EPContacts
//
//  Created by Prabaharan Elangovan on 12/10/15.
//  Copyright © 2015 Prabaharan Elangovan. All rights reserved.
//

import UIKit
import Contacts
import MessageUI


public protocol EPPickerDelegate: class {
    func epContactPicker(_: EPContactsPicker, didContactFetchFailed error: NSError)
    func epContactPicker(_: EPContactsPicker, didCancel error: NSError)
    func epContactPicker(_: EPContactsPicker, didSelectContact contact: EPContact)
    func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact])
}

public extension EPPickerDelegate {
    func epContactPicker(_: EPContactsPicker, didContactFetchFailed error: NSError) { }
    func epContactPicker(_: EPContactsPicker, didCancel error: NSError) { }
    func epContactPicker(_: EPContactsPicker, didSelectContact contact: EPContact) { }
    func epContactPicker(_: EPContactsPicker, didSelectMultipleContacts contacts: [EPContact]) { }
}

typealias ContactsHandler = (_ contacts : [CNContact] , _ error : NSError?) -> Void

public enum SubtitleCellValue{
    case phoneNumber
    case email
    case birthday
    case organization
}

open class EPContactsPicker: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate,MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate {
    
    // MARK: - Properties
    
    open weak var contactDelegate: EPPickerDelegate?
    var contactsStore: CNContactStore?
    var resultSearchController = UISearchController()
    var orderedContacts = [String: [CNContact]]() //Contacts ordered in dicitonary alphabetically
    var sortedContactKeys = [String]()
    
    var selectedContacts = [EPContact]()
    var filteredContacts = [CNContact]()
    
    var subtitleCellValue = SubtitleCellValue.phoneNumber
    var multiSelectEnabled: Bool = false //Default is single selection contact
    var isSMS : Bool = false
   // var lblTotlaSend : UILabel!
    // MARK: - Lifecycle Methods
    let controller = UISearchController(searchResultsController: nil)
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = EPGlobalConstants.Strings.contactsTitle
        registerContactCell()
        inititlizeBarButtons()
        initializeSearchBar()
        reloadContacts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupSearch), name: NSNotification.Name(rawValue: "reloadSearch"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.sendEmail), name: NSNotification.Name(rawValue: "sendEmail"), object: nil)

    }
    
    @objc func setupSearch()
    {
        self.controller.dismiss(animated: true, completion: nil)
    }
    
    override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    func initializeSearchBar() {
        
        self.resultSearchController = ( {
            
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.hidesNavigationBarDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchBar.delegate = self
            controller.searchBar.searchBarStyle = .prominent
            
            self.tableView.tableFooterView = UIView()
            
            var headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 90))
            
            if self.isSMS{
                
                headerView.frame = CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 80)
            }
            else{
                let lblLine = UILabel.init(frame: CGRect.init(x: 0, y: 70, width: UIScreen.main.bounds.size.width, height: 1))
                lblLine.backgroundColor = UIColor.lightGray
                headerView.addSubview(lblLine)
                
//                lblTotlaSend = UILabel.init()
//                lblTotlaSend.frame = CGRect.init(x: 0, y: 5, width: UIScreen.main.bounds.size.width-10, height: 21)
//                lblTotlaSend.isUserInteractionEnabled = true
//                lblTotlaSend.textAlignment = .right
//                lblTotlaSend.text = "Send (0)"
//                lblTotlaSend.font = UIFont.init(name: "FiraSans-Book", size: 13)
//                lblTotlaSend.textColor = UIColor.init(red: 36.0/255.0, green: 169.0/255.0, blue: 237.0/255.0, alpha: 1.0)
//                self.view.addSubview(lblTotlaSend)
                
              //  let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapOnEmail(gesture:)))
                
               // lblTotlaSend.addGestureRecognizer(tapGesture)
            }
            
            headerView.addSubview(controller.searchBar)
            
            self.tableView.tableHeaderView = headerView
            
            return controller
        })()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        
        self.controller.dismiss(animated: false, completion: nil)
    }
    
    func inititlizeBarButtons() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(onTouchCancelButton))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        if multiSelectEnabled {
            let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(onTouchDoneButton))
            self.navigationItem.rightBarButtonItem = doneButton
            
        }
    }
    
    fileprivate func registerContactCell() {
        
        let podBundle = Bundle(for: self.classForCoder)
        if let bundleURL = podBundle.url(forResource: EPGlobalConstants.Strings.bundleIdentifier, withExtension: "bundle") {
            
            if let bundle = Bundle(url: bundleURL) {
                
                let cellNib = UINib(nibName: EPGlobalConstants.Strings.cellNibIdentifier, bundle: bundle)
                tableView.register(cellNib, forCellReuseIdentifier: "Cell")
            }
            else {
                assertionFailure("Could not load bundle")
            }
        }
        else {
            
            let cellNib = UINib(nibName: EPGlobalConstants.Strings.cellNibIdentifier, bundle: nil)
            tableView.register(cellNib, forCellReuseIdentifier: "Cell")
        }
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Initializers
    
    convenience public init(delegate: EPPickerDelegate?) {
        self.init(delegate: delegate, multiSelection: false)
    }
    
    convenience public init(delegate: EPPickerDelegate?, multiSelection : Bool) {
        self.init(style: .plain)
        self.multiSelectEnabled = multiSelection
        contactDelegate = delegate
    }
    
    convenience public init(delegate: EPPickerDelegate?, multiSelection : Bool, subtitleCellType: SubtitleCellValue) {
        self.init(style: .plain)
        self.multiSelectEnabled = multiSelection
        contactDelegate = delegate
        subtitleCellValue = subtitleCellType
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Contact Operations
    
    open func reloadContacts() {
        getContacts( {(contacts, error) in
            if (error == nil) {
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        })
    }
    
    func getContacts(_ completion:  @escaping ContactsHandler) {
        if contactsStore == nil {
            //ContactStore is control for accessing the Contacts
            contactsStore = CNContactStore()
        }
        let error = NSError(domain: "EPContactPickerErrorDomain", code: 1, userInfo: [NSLocalizedDescriptionKey: "No Contacts Access"])
        
        switch CNContactStore.authorizationStatus(for: CNEntityType.contacts) {
        case CNAuthorizationStatus.denied, CNAuthorizationStatus.restricted:
            //User has denied the current app to access the contacts.
            
            let productName = Bundle.main.infoDictionary!["CFBundleName"]!
            
            let alert = UIAlertController(title: "Unable to access contacts", message: "\(productName) does not have access to contacts. Kindly enable it in privacy settings ", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {  action in
                completion([], error)
                self.dismiss(animated: true, completion: {
                    self.contactDelegate?.epContactPicker(self, didContactFetchFailed: error)
                })
            })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
        case CNAuthorizationStatus.notDetermined:
            //This case means the user is prompted for the first time for allowing contacts
            contactsStore?.requestAccess(for: CNEntityType.contacts, completionHandler: { (granted, error) -> Void in
                //At this point an alert is provided to the user to provide access to contacts. This will get invoked if a user responds to the alert
                if  (!granted ){
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion([], error! as NSError?)
                    })
                }
                else{
                    self.getContacts(completion)
                }
            })
            
        case  CNAuthorizationStatus.authorized:
            //Authorization granted by user for this app.
            var contactsArray = [CNContact]()
            
            let contactFetchRequest = CNContactFetchRequest(keysToFetch: allowedContactKeys())
            
            do {
                try contactsStore?.enumerateContacts(with: contactFetchRequest, usingBlock: { (contact, stop) -> Void in
                    //Ordering contacts based on alphabets in firstname
                    if self.isSMS{
                        contactsArray.append(contact)
                        var key: String = "#"
                        //If ordering has to be happening via family name change it here.
                        if let firstLetter = contact.givenName[0..<1] , firstLetter.containsAlphabets() {
                            key = firstLetter.uppercased()
                        }
                        var contacts = [CNContact]()
                        
                        if let segregatedContact = self.orderedContacts[key] {
                            contacts = segregatedContact
                        }
                        contacts.append(contact)
                        self.orderedContacts[key] = contacts
                    }
                    else{
                        
                        if contact.emailAddresses.count > 0{
                            
                            contactsArray.append(contact)
                            var key: String = "#"
                            //If ordering has to be happening via family name change it here.
                            if let firstLetter = contact.givenName[0..<1] , firstLetter.containsAlphabets() {
                                key = firstLetter.uppercased()
                            }
                            var contacts = [CNContact]()
                            
                            if let segregatedContact = self.orderedContacts[key] {
                                contacts = segregatedContact
                            }
                            contacts.append(contact)
                            self.orderedContacts[key] = contacts
                        }
                    }
                    
                })
                self.sortedContactKeys = Array(self.orderedContacts.keys).sorted(by: <)
                if self.sortedContactKeys.first == "#" {
                    self.sortedContactKeys.removeFirst()
                    self.sortedContactKeys.append("#")
                }
                completion(contactsArray, nil)
                
            }
                //Catching exception as enumerateContactsWithFetchRequest can throw errors
            catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
    }
    
    func allowedContactKeys() -> [CNKeyDescriptor]{
        //We have to provide only the keys which we have to access. We should avoid unnecessary keys when fetching the contact. Reducing the keys means faster the access.
        return [CNContactNamePrefixKey as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactOrganizationNameKey as CNKeyDescriptor,
                CNContactBirthdayKey as CNKeyDescriptor,
                CNContactImageDataKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor,
                CNContactImageDataAvailableKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor,
        ]
    }
    
    // MARK: - Table View DataSource
    
    override open func numberOfSections(in tableView: UITableView) -> Int {
        if resultSearchController.isActive { return 1 }
        return sortedContactKeys.count
    }
    
    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.isActive { return filteredContacts.count }
        if let contactsForSection = orderedContacts[sortedContactKeys[section]] {
            return contactsForSection.count
        }
        return 0
    }
    
    // MARK: - Table View Delegates
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EPContactCell
        //Convert CNContact to EPContact
        let contact: EPContact
        
        if resultSearchController.isActive {
            contact = EPContact(contact: filteredContacts[(indexPath as NSIndexPath).row])
        } else {
            guard let contactsForSection = orderedContacts[sortedContactKeys[(indexPath as NSIndexPath).section]] else {
                assertionFailure()
                return UITableViewCell()
            }
            if indexPath.row < contactsForSection.count
            {
                contact = EPContact(contact: contactsForSection[(indexPath as NSIndexPath).row])

            }
            else{
                contact = EPContact(contact: CNContact.init())

            }
        }
        
        if multiSelectEnabled  && selectedContacts.contains(where: { $0.contactId == contact.contactId }) {
            
            if !self.isSMS{
                cell.imgCheck?.image = UIImage.init(named: "checked.png")
            }
            
        }
        else{
            cell.imgCheck?.image = UIImage.init(named: "uncheck.png")
        }
        
        if self.isSMS{
            cell.imgCheck.isHidden = true
            cell.imgSend.isHidden = false
            
            cell.imgSend.isUserInteractionEnabled = true
            
            cell.btnSend.addTarget(self, action: #selector(self.clickOnSendSMS(sender:)), for: UIControl.Event.touchUpInside)
            
        }
        else{
            cell.imgCheck.isHidden = false
            cell.imgSend.isHidden = true
           
            cell.imgCheck.isUserInteractionEnabled = true
           
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.tapOnCheck(gesture:)))
            
            cell.imgCheck.addGestureRecognizer(tapGesture)
        }
        
        cell.updateContactsinUI(contact, indexPath: indexPath, subtitleType: subtitleCellValue)
        return cell
    }
    
    override open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.isSMS{
            let cell = tableView.cellForRow(at: indexPath) as! EPContactCell
            let selectedContact =  cell.contact!
            if multiSelectEnabled {
                //Keeps track of enable=ing and disabling contacts
                if cell.imgCheck.image == UIImage.init(named: "checked.png") {
                    cell.imgCheck.image = UIImage.init(named: "uncheck.png")
                    selectedContacts = selectedContacts.filter(){
                        return selectedContact.contactId != $0.contactId
                    }
                }
                else {
                    cell.imgCheck.image = UIImage.init(named: "checked.png")
                    self.selectedContacts.append(selectedContact)
                }
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SendCount"), object: "Send (\(selectedContacts.count))", userInfo: nil)
                
            }
            else {
                //Single selection code
                resultSearchController.isActive = false
                self.dismiss(animated: true, completion: {
                    DispatchQueue.main.async {
                        self.contactDelegate?.epContactPicker(self, didSelectContact: selectedContact)
                    }
                })
            }
        }
    }
    
    @objc func tapOnCheck(gesture:UITapGestureRecognizer)
    {
        var tempView = gesture.view as! UIView
        var cell : EPContactCell!
        
        while true {
            
            if tempView.isKind(of: EPContactCell.self)
            {
                cell = (tempView as! EPContactCell)
                break
            }
            else{
                tempView = tempView.superview!
            }
        }
        
        if !self.isSMS{
            let selectedContact =  cell.contact!
            if multiSelectEnabled {
                //Keeps track of enable=ing and disabling contacts
                if cell.imgCheck.image == UIImage.init(named: "checked.png") {
                    cell.imgCheck.image = UIImage.init(named: "uncheck.png")
                    selectedContacts = selectedContacts.filter(){
                        return selectedContact.contactId != $0.contactId
                    }
                }
                else {
                    cell.imgCheck.image = UIImage.init(named: "checked.png")
                    selectedContacts.append(selectedContact)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "SendCount"), object: "Send (\(selectedContacts.count))", userInfo: nil)

               // lblTotlaSend.text = "Send (\(selectedContacts.count))"
            }
            else {
                //Single selection code
                resultSearchController.isActive = false
                self.dismiss(animated: true, completion: {
                    DispatchQueue.main.async {
                        self.contactDelegate?.epContactPicker(self, didSelectContact: selectedContact)
                    }
                })
            }
        }
    }
    
    override open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if resultSearchController.isActive { return 0 }
        tableView.scrollToRow(at: IndexPath(row: 0, section: index), at: UITableView.ScrollPosition.top , animated: false)
        return sortedContactKeys.index(of: title)!
    }
    
    override  open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if resultSearchController.isActive { return nil }
        return sortedContactKeys
    }
    
    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if resultSearchController.isActive { return nil }
        return sortedContactKeys[section]
    }
    
    // MARK: - Button Actions
    
    @objc func onTouchCancelButton() {
        dismiss(animated: true, completion: {
            self.contactDelegate?.epContactPicker(self, didCancel: NSError(domain: "EPContactPickerErrorDomain", code: 2, userInfo: [ NSLocalizedDescriptionKey: "User Canceled Selection"]))
        })
    }
    
    @objc func onTouchDoneButton() {
        dismiss(animated: true, completion: {
            self.contactDelegate?.epContactPicker(self, didSelectMultipleContacts: self.selectedContacts)
        })
    }
    
    // MARK: - Search Actions
    
    open func updateSearchResults(for searchController: UISearchController)
    {
        if let searchText = resultSearchController.searchBar.text , searchController.isActive {
            
            let predicate: NSPredicate
            if searchText.characters.count > 0 {
                predicate = CNContact.predicateForContacts(matchingName: searchText)
            } else {
                predicate = CNContact.predicateForContactsInContainer(withIdentifier: contactsStore!.defaultContainerIdentifier())
            }
            
            let store = CNContactStore()
            do {
                filteredContacts = try store.unifiedContacts(matching: predicate,
                                                             keysToFetch: allowedContactKeys())
                //print("\(filteredContacts.count) count")
                
                self.tableView.reloadData()
                
            }
            catch {
                print("Error!")
            }
        }
    }
    
    open func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    @objc func sendEmail()
    {
        
        let strMessage = "Please join me on SWIS App to See What I Search. https://swis.app\n\nSincerely,\n\n\(appDelegate.dicLoginDetail.value(forKey: "name") as! String)"
      
        var arrEmail : [String] = []
        
        for index in 0..<selectedContacts.count{
            
            let contact = selectedContacts[index]
            
            arrEmail.append("\(contact.emails[0].email)")
        }
        
        if arrEmail.count > 0{
            
            if MFMailComposeViewController.canSendMail(){
                
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                
                composeVC.setToRecipients(arrEmail)
                composeVC.setSubject("You've been invited to join swis")
                composeVC.setMessageBody(strMessage, isHTML: false)
                
                controller.dismiss(animated: true, completion: nil)
                
                self.present(composeVC, animated: true, completion: nil)
                
            }
        }
      
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
     {
        controller.dismiss(animated: true, completion: nil)
    }
  
    
    @objc func clickOnSendSMS(sender:UIButton)
    {
        var tempView = sender as! UIView
        var cell : EPContactCell!
        
        while true {
            
            if tempView.isKind(of: EPContactCell.self)
            {
                cell = (tempView as! EPContactCell)
                break
            }
            else{
                tempView = tempView.superview!
            }
        }
        
        
        let indexPath = self.tableView.indexPath(for: cell)
        
        let contact: EPContact
        
        if resultSearchController.isActive || resultSearchController.searchBar.text != "" {
            contact = EPContact(contact: filteredContacts[(indexPath! as NSIndexPath).row])
        } else {
            let contactsForSection = orderedContacts[sortedContactKeys[(indexPath! as NSIndexPath).section]]
            contact = EPContact(contact: contactsForSection![(indexPath! as NSIndexPath).row])
        }
        
        let strPhoneNumber = contact.phoneNumbers[0].phoneNumber
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        composeVC.recipients = [strPhoneNumber]
        composeVC.subject = "You've been invited to join swis"
        composeVC.body = "Join me on SWIS to See What I Search.  You can download SWIS by going to https://swis.app"
        
        controller.dismiss(animated: true, completion: nil)
        
        self.present(composeVC, animated: true, completion: nil)
        
    }
    
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result.rawValue) {
        case MessageComposeResult.cancelled.rawValue:
            print("Message was cancelled")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.failed.rawValue:
            print("Message failed")
            self.dismiss(animated: true, completion: nil)
        case MessageComposeResult.sent.rawValue:
            print("Message was sent")
            self.dismiss(animated: true, completion: nil)
        default:
            break;
        }
    }
}
