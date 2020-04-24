//
//  GetContactsViewController.swift
//  DB-Sample-ios
//
//  Created by Suman HS on 11/08/17.
//  Copyright © 2017 Suman HS. All rights reserved.
//

import Foundation

import UIKit

protocol GetContactsDelegate {
    func didDownloadContacts()
}

class GetContactsViewController: UIViewController {
    
    //  MARK:- Properties
    @IBOutlet weak var contactIdTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    var alertController: UIAlertController = UIAlertController()
    
    fileprivate var networkManger: NetworkCommunicationManager = NetworkCommunicationManager()
    var contactHeader : CONTACT_HEADER = CONTACT_HEADER()
    var downloadedContactHeaders: [CONTACT_HEADER] = []
    var didDownloadConatctHeaders = false
    var delegate: GetContactsDelegate?
    
    fileprivate var tableViewSections: [String] = []
    fileprivate var tableViewDataSource : [String: [CONTACT_HEADER]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        networkManger.delegate = self
        self.setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        self.navigationItem.title = NSLocalizedString("Get Contacts", comment: "")
        setupNavigationBarBackButton()
        self.didDownloadConatctHeaders = false
        self.tableView.isHidden = true
        self.tableView.layer.borderWidth = 1
        self.tableView.layer.borderColor = UIColor.white.cgColor
        self.tableView.layer.cornerRadius = 5
        
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GetContactsViewController.didTapOnView))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setupNavigationBarBackButton() {
        // Set the Back Button
        let backButton: UIButton = UIButton()
        backButton.setImage(UIImage(named: "backButton"), for: UIControl.State())
        backButton.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        backButton.setImage(backButton.imageView?.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: UIControl.State())
        backButton.addTarget(self, action: #selector(GetContactsViewController.backButtonAction(_:)), for: UIControl.Event.touchUpInside)
        let backBarButton: UIBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButton
    }
    
    @objc func didTapOnView() {
        /** Dismiss the Keyboard **/
        self.view.endEditing(true)
    }
    
    // MARK:- Button Action
    @objc func backButtonAction(_ sender:UIBarButtonItem) {
        
        if didDownloadConatctHeaders {
            let alertController = UIAlertController(title: nil, message:
                NSLocalizedString("Do you want to save results?", comment: "") , preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.default) { (action) -> Void in
                Utility.insertOrReplaceHeadersInDatabase(self.downloadedContactHeaders, view: self)
                self.delegate?.didDownloadContacts()
                self.navigationController?.popViewController(animated: true)
            })
            alertController.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel){ (action) -> Void in
                self.navigationController?.popViewController(animated: true)
            })
            
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func searchButtonClicked(_ sender: Any) {
        
        var contactID:String = ""
        var contactName: String = ""
        
        if let id = self.contactHeader.FIELD_ContactId {
            contactID = String(describing: id)
        }
        
        if let name = self.contactHeader.FIELD_ContactName {
            contactName = name
        }
        
        if(contactID.count > 0 || contactName.count > 0) {
            self.view.endEditing(true)
            self.downloadedContactHeaders = []
            self.tableViewSections = []
            self.tableViewDataSource = [:]
            showBusyIndicator()
            networkManger.sendDataToServer(MESSAGE_REQUEST_TYPE.PULL, PAFunctionName: AppConstants.PA_GET_CONTACT, header: self.contactHeader)
        }
        else {
            Utility.displayAlertWithOKButton("", message: "Plesae provide valid input.", viewController: self)
        }
    }
    
    func showBusyIndicator() {
        alertController = UIAlertController(title: nil, message: "Please wait\n\n", preferredStyle: .alert)
        
        let spinnerIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        self.present(alertController, animated: false, completion: nil)
    }
    
    func hideBusyIndicator() {
        alertController.dismiss(animated: true, completion: nil);
    }
    
    func sortContactHeader(contactHeaders: [CONTACT_HEADER]) {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map({ String($0) })
        
        for letter in alphabet {
            let matches = contactHeaders.filter({ ($0.FIELD_ContactName?.uppercased().hasPrefix(letter))! })
            if !matches.isEmpty {
                self.tableViewDataSource[letter] = []
                for word in matches {
                    if !self.tableViewSections.contains(letter) {
                        self.tableViewSections.append(letter)
                    }
                    
                    self.tableViewDataSource[letter]?.append(word)
                }
            }
        }
        
        self.tableViewSections = self.tableViewSections.sorted(by: <)
    }
    
}

// MARK:- TextField Delegate Methods
extension GetContactsViewController : UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        
        var someText = textField.text!
        someText = (someText as NSString).replacingCharacters(in: range, with: string)
        someText = someText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (textField == self.contactIdTextField) {
            if let number = Int(someText) {
                self.contactHeader.FIELD_ContactId = NSNumber(value:number)
                print("Contact Id : \(String(describing: contactHeader.FIELD_ContactId))")
            }
        }
        
        if (textField == self.nameTextField) {
            self.contactHeader.FIELD_ContactName = someText
            print("Contact Name : \(String(describing: contactHeader.FIELD_ContactName))")
        }
        
        return true
    }
    
    
}

// MARK:- NetworkConnectionDelegate methods
extension GetContactsViewController: NetworkConnectionDelegate {
    
    func didGetResponseForPA(_ paFunctionName: String, infoMessage: String, responseHaeders: Dictionary<NSObject, AnyObject>) {
        hideBusyIndicator()
        Utility.displayAlertWithOKButton("", message:  "Contacts Downloaded.", viewController: self)
        self.downloadedContactHeaders = self.getContactHeaders(responseHaeders)
        self.sortContactHeader(contactHeaders: self.downloadedContactHeaders)
        self.didDownloadConatctHeaders = true
        self.tableView.isHidden = false
        self.tableView.reloadData()
    }
    
    func didEncounterErrorForPA(_ paFunctionName: String, errorMessage: NSError) {
        self.tableView.isHidden = true
        hideBusyIndicator()
        Utility.displayAlertWithOKButton("", message: errorMessage.localizedDescription, viewController: self)
    }
    
    func getContactHeaders(_ dataBEs: Dictionary<NSObject, AnyObject>) -> [CONTACT_HEADER] {
        var contactHeaders: [CONTACT_HEADER] = []
        var headers:Dictionary<NSObject, AnyObject>?
        
        for (key, values) in dataBEs {
            if key as! String == "CONTACT" {
                headers = values as? Dictionary<NSObject, AnyObject>
            }
        }
        
        if let headers = headers {
            for (header, _) in headers {
                contactHeaders.append(header as! CONTACT_HEADER)
            }
        }
        return contactHeaders
    }
}


// MARK:- TableView DataSource and Delegate methods
extension GetContactsViewController: UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewSections.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let tableViewActualHeight = tableView.contentSize.height
        tableViewHeightConstraint.constant = tableViewActualHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let sectionHeaderView = UIView()
        sectionHeaderView.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 35)
        
        let sectionHeaderLabel = UILabel()
        sectionHeaderLabel.frame = CGRect(x: self.view.frame.origin.x+20, y: 5, width: 100, height: 30)
        sectionHeaderLabel.textAlignment = .left
        sectionHeaderLabel.font = UIFont.boldSystemFont(ofSize: 17.0)
        sectionHeaderLabel.text =  tableViewSections[section]
        sectionHeaderLabel.textColor = UIColor.blue
        
        sectionHeaderView.backgroundColor = UIColor.white
        sectionHeaderView.addSubview(sectionHeaderLabel)
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = Int()
        
        let sectionType = tableViewSections[section]
        let dataArray = tableViewDataSource[sectionType]
        
        numberOfRows = dataArray!.count
        
        if let _ = dataArray {
            numberOfRows = dataArray!.count
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style:UITableViewCell.CellStyle.subtitle, reuseIdentifier:"cell")
        var contactHeader : CONTACT_HEADER = CONTACT_HEADER()
        
        let sectionType = tableViewSections[indexPath.section]
        let dataArray = tableViewDataSource[sectionType]
        contactHeader = dataArray![indexPath.row]
        
        if let name = contactHeader.FIELD_ContactName {
            cell.textLabel?.text = name
        }
        
        if let id = contactHeader.FIELD_ContactId {
            cell.detailTextLabel?.text = String(describing: id)
        }
        
        cell.textLabel?.textColor = UIColor.darkText
        cell.detailTextLabel?.textColor = UIColor.gray
        
        cell.accessoryType = UITableViewCell.AccessoryType.none
        return cell
    }
    
}

