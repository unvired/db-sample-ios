//
//  AddContactsViewController.swift
//  DB-Sample-ios
//
//  Created by Suman HS on 11/08/17.
//  Copyright © 2017 Suman HS. All rights reserved.
//

import Foundation

import Foundation

import UIKit

class AddContactsViewController: UIViewController {
    
    //  MARK:- Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    var alertController: UIAlertController = UIAlertController()
    var contactHeader: CONTACT_HEADER = CONTACT_HEADER()
    fileprivate var networkManager: NetworkCommunicationManager = NetworkCommunicationManager()
    var delegate: GetContactsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        networkManager.delegate = self
        self.setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        self.navigationItem.title = NSLocalizedString("Add/Create Contacts", comment: "")
    }
    
    func showBusyIndicator() {
        alertController = UIAlertController(title: nil, message: "Please wait\n\n", preferredStyle: .alert)
        
        let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        self.present(alertController, animated: false, completion: nil)
    }
    
    func hideBusyIndicator() {
        alertController.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func createContact(_ sender: Any) {
        self.view.endEditing(true)
        
        if let name = contactHeader.FIELD_ContactName,(name.characters.count == 0 || name == "nil" || name == "") {
            Utility.displayStringInAlertView("", desc: "Enter name.")
            return
        }
        
        if let phone = contactHeader.FIELD_Phone,(phone.characters.count == 0 || phone == "nil" || phone == "") {
            Utility.displayStringInAlertView("", desc: "Enter Phone number.")
            return
        }
        
        if let email = contactHeader.FIELD_Email,(email.characters.count == 0 || email == "nil" || email == "") {
            Utility.displayStringInAlertView("", desc: "Enter Email.")
            return
        }
        
        self.networkManager.sendDataToServer(MESSAGE_REQUEST_TYPE(), PAFunctionName: AppConstants.PA_CREATE_CONTACT, header: contactHeader)
        self.showBusyIndicator()
    }
    
}

// MARK:- TextField Delegate Methods
extension AddContactsViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var txtAfterUpdate : String = textField.text!
        txtAfterUpdate = (txtAfterUpdate as NSString).replacingCharacters(in: range, with: string)
        txtAfterUpdate = txtAfterUpdate.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if(txtAfterUpdate.characters.count > 0 && txtAfterUpdate != " " || txtAfterUpdate != "") {
            if textField == nameTextField {
                contactHeader.FIELD_ContactName = txtAfterUpdate
                print("FIELD_ContactName: \(String(describing: contactHeader.FIELD_ContactName))")
            }
            else if textField == phoneTextField {
                contactHeader.FIELD_Phone = txtAfterUpdate
                print("contactHeader.FIELD_Phone: \(String(describing: contactHeader.FIELD_Phone))")
            }
            else {
                contactHeader.FIELD_Email = txtAfterUpdate
                 print("contactHeader.FIELD_Email: \(String(describing: contactHeader.FIELD_Email))")
            }
        }
        
        return true
    }
    
}

// MARK:- NetworkConnectionDelegate methods
extension AddContactsViewController: NetworkConnectionDelegate {
    
    func didGetResponseForPA(_ paFunctionName: String, infoMessage: String, responseHaeders: Dictionary<NSObject, AnyObject>) {
        hideBusyIndicator()
        Utility.displayStringInAlertView("", desc: "Contact Added.")
        let contactHeaders = getContactHeaders(responseHaeders)
        Utility.insertOrReplaceHeadersInDatabase(contactHeaders)
        delegate?.didDownloadContacts()
        self.navigationController?.popViewController(animated: true)
    }
    
    func didEncounterErrorForPA(_ paFunctionName: String, errorMessage: NSError) {
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


