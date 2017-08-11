//
//  ViewController.swift
//  DB-Sample-ios
//
//  Created by Suman HS on 10/08/17.
//  Copyright © 2017 Suman HS. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //  MARK:- Properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    
    var contactHeaders : [CONTACT_HEADER] = []
    fileprivate var tableViewSections: [String] = []
    fileprivate var tableViewDataSource : [String: [CONTACT_HEADER]] = [:]
    fileprivate var isFiltered: Bool = false
    fileprivate var searchResultsDataSource = [AnyObject]()
    var searchResultsTableViewSection: [String] = []
    var searchResultsTableViewDataSource : [String: [CONTACT_HEADER]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupUI()
        contactHeaders = Utility.getAllContactHeaders()
        self.sortContactHeader(contactHeaders: self.contactHeaders)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupUI() {
        self.navigationController?.navigationBar.barTintColor = UIColor.blue
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationItem.title = NSLocalizedString("Unvired DB Sample", comment: "")
        let menuIcon = UIImage(named: "actions")
        let menuButton = UIButton()
        menuButton.setImage(menuIcon?.withRenderingMode(.alwaysTemplate), for: .normal)
        menuButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        menuButton.tintColor = UIColor.white
        menuButton.addTarget(self, action: #selector(ViewController.menuButtonAction(_:)), for: .touchUpInside)
        
        let rightBarButton = UIBarButtonItem(customView: menuButton)
        rightBarButton.tintColor = UIColor.white
        self.navigationItem.rightBarButtonItem = rightBarButton
        
        self.tableView.keyboardDismissMode = .onDrag
        Utility.removeExtraLinesFromTableView(self.tableView)
        addButton.layer.cornerRadius = 0.5 * addButton!.bounds.size.width
        
        //Register nib
        let nib: UINib = UINib(nibName: "ContactDetailTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ContactDetailTableViewCell")
    }
    
    func sortContactHeader(contactHeaders: [CONTACT_HEADER]) {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map({ String($0) })
        var sectionArray : [String] = []
        var dataSorce: [String: [CONTACT_HEADER]] = [:]
        
        for letter in alphabet {
            let matches = contactHeaders.filter({ ($0.FIELD_ContactName?.uppercased().hasPrefix(letter))! })
            if !matches.isEmpty {
                dataSorce[letter] = []
                for word in matches {
                    if !sectionArray.contains(letter) {
                        sectionArray.append(letter)
                    }
                    
                    dataSorce[letter]?.append(word)
                }
            }
        }
        
        sectionArray = sectionArray.sorted(by: <)
        
        if isFiltered {
            searchResultsTableViewSection.removeAll()
            searchResultsTableViewDataSource.removeAll()
            
            searchResultsTableViewSection =  sectionArray
            searchResultsTableViewDataSource = dataSorce
        } else {
            tableViewSections.removeAll()
            tableViewDataSource.removeAll()
            
            tableViewSections = sectionArray
            tableViewDataSource = dataSorce
        }
        
    }
    
    
    // MARK:- Actions
    
    @IBAction func menuButtonAction(_ sender: AnyObject) {
        let alertController: UIAlertController = UIAlertController(title: nil, message: nil,
                                                                   preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let getPersonAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Get Contacts", comment: ""), style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in self.showGetContactsScreen()
        }
        
        let settingsAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: UIAlertActionStyle.default) { (action: UIAlertAction) -> Void in self.showFrameworkSettingsViewController()
        }
        
        
        let cancelAction: UIAlertAction = UIAlertAction(title:  NSLocalizedString("Cancel",  comment: ""), style: UIAlertActionStyle.cancel, handler: nil)
        
        alertController.addAction(getPersonAction)
        alertController.addAction(settingsAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {
            alertController.popoverPresentationController?.passthroughViews = nil
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad  {
            alertController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        }
    }
    
    func showFrameworkSettingsViewController() {
        let settingsViewController: FrameworkSettingsViewController = FrameworkSettingsViewController(style: UITableViewStyle.grouped)
        settingsViewController.delegate = self
        let navController: UINavigationController = UINavigationController(rootViewController: settingsViewController)
        navController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        navController.navigationBar.barTintColor = UIColor.blue
        navController.navigationBar.barStyle = UIBarStyle.black
        navController.navigationBar.tintColor = UIColor.white
        self.present(navController, animated: true, completion: nil)
    }
    
    func showGetContactsScreen() {
        let getContactsViewController: GetContactsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "getContactsViewController") as! GetContactsViewController
        getContactsViewController.delegate = self
        self.navigationController?.pushViewController(getContactsViewController, animated: true)
    }
    
    
    @IBAction func addButtonClicked(_ sender: Any) {
        let addContactsViewController: AddContactsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addContactsViewController") as! AddContactsViewController
        addContactsViewController.delegate = self
        self.navigationController?.pushViewController(addContactsViewController, animated: true)
    }
}

// MARK:- Framework Settings Delegate
extension ViewController : SettingsDelegate {
    func doneButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK:- TableView DataSource and Delegate methods
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltered {
            return searchResultsTableViewSection.count
        }
        
        return tableViewSections.count
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
        
        if isFiltered {
            sectionHeaderLabel.text =  searchResultsTableViewSection[section]
        }
        else {
            sectionHeaderLabel.text =  tableViewSections[section]
        }
        
        sectionHeaderView.backgroundColor = UIColor.groupTableViewBackground
        sectionHeaderView.addSubview(sectionHeaderLabel)
        return sectionHeaderView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int = Int()
        
        if isFiltered {
            
            let sectionType = searchResultsTableViewSection[section]
            let dataArray = searchResultsTableViewDataSource[sectionType]
            
            numberOfRows = dataArray!.count
            
            if let _ = dataArray {
                numberOfRows = dataArray!.count
            }
            
        } else {
            
            let sectionType = tableViewSections[section]
            let dataArray = tableViewDataSource[sectionType]
            
            numberOfRows = dataArray!.count
            
            if let _ = dataArray {
                numberOfRows = dataArray!.count
            }
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactDetailTableViewCell", for: indexPath) as! ContactDetailTableViewCell
        var contactHeader : CONTACT_HEADER = CONTACT_HEADER()
        
        if isFiltered {
            let sectionType = searchResultsTableViewSection[indexPath.section]
            let dataArray = searchResultsTableViewDataSource[sectionType]
            contactHeader = dataArray![indexPath.row]
        }
        else {
            let sectionType = tableViewSections[indexPath.section]
            let dataArray = tableViewDataSource[sectionType]
            contactHeader = dataArray![indexPath.row]
        }
        
        if let name = contactHeader.FIELD_ContactName {
            cell.nameLabel.text = name
        }
        
        if let number = contactHeader.FIELD_Phone {
            cell.contactNumberLabel.text = number
        }
        
        if let mail = contactHeader.FIELD_Email {
            cell.mailLabel.text = mail
        }
        
        return cell
    }
    
    
}

// MARK:- Search Bar Delegate methods
extension ViewController : UISearchBarDelegate, UISearchDisplayDelegate  {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        isFiltered = false
        self.searchBar.text = ""
        self.view.endEditing(true)
        tableView.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        
        if searchBar.text != nil && searchBar.text!.characters.count > 0 {
            searchBar.showsCancelButton = false
        }
        else {
            searchBar.showsCancelButton = false
            searchBar.resignFirstResponder()
        }
        return true
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if((searchBar.text?.characters.count)! > 0) {
            isFiltered = true
        }
        else {
            isFiltered = false
        }
        
        searchResultsDataSource.removeAll()
        var searchText = ""
        
        if (self.searchBar.text?.characters.count)! > 0 {
            searchText = self.searchBar.text!.lowercased()
        }
        else {
            Utility.runInMainThread({
                self.tableView.reloadData()
                self.view.endEditing(true)
            })
            return
        }
        
        searchResultsDataSource = contactHeaders.filter {($0.FIELD_ContactName?.lowercased() ?? "").contains(searchText)}
        
        if let filteredContactHeaders = searchResultsDataSource as? [CONTACT_HEADER] {
            sortContactHeader(contactHeaders: filteredContactHeaders)
            self.tableView.reloadData()
        }
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchBar.resignFirstResponder()
    }
    
}

extension ViewController: GetContactsDelegate {
    
    func didDownloadContacts() {
        contactHeaders = Utility.getAllContactHeaders()
        sortContactHeader(contactHeaders: contactHeaders)
        tableView.reloadData()
    }
}

