import UIKit

//This class is part of the BE "CONTACT".
@objc(CONTACT_HEADER)
class CONTACT_HEADER: DataStructure {
    
    // Table Name
    static let TABLE_NAME = "CONTACT_HEADER";
    
    // Contact Id
    static let FIELD_ContactId = "ContactId";
    
    // Contact Name
    static let FIELD_ContactName = "ContactName";
    
    // Phone
    static let FIELD_Phone = "Phone";
    
    // Email
    static let FIELD_Email = "Email";
    
    // The Initializer
    override init() {
        super.init(CONTACT_HEADER.TABLE_NAME, isHeader: true)
    }
    
    var FIELD_ContactId: NSNumber? {
        get {
            return getField(CONTACT_HEADER.FIELD_ContactId) as? NSNumber
        }
        set (value) {
            setField(CONTACT_HEADER.FIELD_ContactId, value: value)
        }
    }
    
    
    var FIELD_ContactName: String? {
        get {
            return getField(CONTACT_HEADER.FIELD_ContactName) as? String
        }
        set (value) {
            setField(CONTACT_HEADER.FIELD_ContactName, value: value)
        }
    }
    
    var FIELD_Phone: String? {
        get {
            return getField(CONTACT_HEADER.FIELD_Phone) as? String
        }
        set (value) {
            setField(CONTACT_HEADER.FIELD_Phone, value: value)
        }
    }
    
    var FIELD_Email: String? {
        get {
            return getField(CONTACT_HEADER.FIELD_Email) as? String
        }
        set (value) {
            setField(CONTACT_HEADER.FIELD_Email, value: value)
        }
    }
    
    
}
