//
//  Utility.swift
//  DB-Sample-ios
//
//  Created by Suman HS on 10/08/17.
//  Copyright © 2017 Suman HS. All rights reserved.
//

import Foundation

struct Utility {
    
    static func removeExtraLinesFromTableView(_ tableView: UITableView) {
        // This will remove extra separators from tableview
        tableView.tableFooterView =  UIView(frame: CGRect.zero)
    }
    
    static func runInMainThread(_ block:@escaping ()->Void) {
        DispatchQueue.main.async(execute: block)
    }
    
    static func runInBackground(_ block:@escaping ()->Void) {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: block)
    }
    
    static func getCompleteInfoMessageStringFromInfoMessages(_ infoMessages: [AnyObject]) -> (String,Bool) {
        // Loop through Each of Info Messages and form one complete String.
        var completeInfoMessageString : String = ""
        var successInfoMessage: Bool = false
        for infoMessage in infoMessages {
            
            // Check Whether infoMessage is really the type of class |InfoMessage|
            if (infoMessage.isKind(of: InfoMessage.classForCoder())) {
                
                // Extract the Message
                let message: String! = infoMessage.getMessage()
                completeInfoMessageString = "\(completeInfoMessageString)" + message
                
                if let infoMessageStatus = infoMessage.getCategory() {
                    switch infoMessageStatus {
                    case INFO_MESSAGE_CATEGORY_SUCCESS,INFO_MESSAGE_CATEGORY_INFO:
                        successInfoMessage = true
                    case INFO_MESSAGE_CATEGORY_FAILURE:
                        successInfoMessage = false
                    default:
                        break
                    }
                }
            }
        }
        return (completeInfoMessageString, successInfoMessage)
    }
    
    static func displayAlertWithOKButton(_ title: String, message: String, viewController: UIViewController) {
        runInMainThread { () -> Void in
            let alertController: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            let alertAction: UIAlertAction = UIAlertAction(title:  NSLocalizedString("OK",  comment: ""), style: UIAlertAction.Style.default, handler: nil)
            alertController.addAction(alertAction)
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    static func insertOrReplaceHeadersInDatabase(_ dataStructures: [IDataStructure]) -> Bool {
        let dataManager: IDataManager = UnviredDBampleUtils.getApplicationDataManager()!
        
        for dataStructure:IDataStructure in dataStructures {
            do {
                try dataManager.replace(dataStructure)
            }
            catch let error as NSError {
                Utility.displayErrorInformation(error)
            }
        }
        return true
    }
    
    static func displayErrorInformation(_ error: NSError?) {
        if error != nil {
            let desc: String = error!.localizedDescription
            displayStringInAlertView(NSLocalizedString("Error",  comment: ""), desc: desc)
        }
    }
    
    static func displayStringInAlertView(_ title: String, desc: String) {
        runInMainThread { () -> Void in
            
            let errorAlertView: UIAlertView = UIAlertView(title:  title,
                                                          message: desc,
                                                          delegate: nil,
                                                          cancelButtonTitle:NSLocalizedString("OK",  comment: ""))
            errorAlertView.show()
        }
    }
    
    static func getAllContactHeaders() -> [CONTACT_HEADER] {
        let dataManager: IDataManager = UnviredDBampleUtils.getApplicationDataManager()!
        var contactHeaders : [CONTACT_HEADER] = []
        
        do {
            contactHeaders = try dataManager.get(CONTACT_HEADER.TABLE_NAME, whereClause: "", orderByFields: [CONTACT_HEADER.FIELD_ContactName]) as! [CONTACT_HEADER]
            
            if contactHeaders.count > 0 {
                return contactHeaders
            }
            
        } catch let error as NSError {
            if error != nil {
                Logger.logger(with: LEVEL.ERROR, className: String(describing: Utility()), method: #function , message: error.localizedDescription)
            }
        }
        
        return contactHeaders
    }
    
}
