import UIKit

class UnviredDBampleUtils: NSObject {
    
    /**
     Truncates the number of decimal digits to 2.
     
     Example:
     For an input of value 1.34000, Returns 1.34
     
     @param value decimal value in String format
     @return Truncated decimal value in String format
     */
    static func truncateDecimal(value: String) -> String? {
        let valueToNumber: NSNumber = NSNumber(value: (value as NSString).floatValue)
        let numFormat: NumberFormatter = NumberFormatter()
        numFormat.positiveFormat = "#.00"
        let returnValue: String? = numFormat.string(from: valueToNumber)
        return returnValue
    }
    
    /**
     * Get the Directoty Path of the current Unvired Account.
     * @return A String representing the path.
     */
    static func getDocumentsDirectoryPath() -> String {
        return PathManager.shared().path(for: .accountSandboxFolder)
    }
    
    /**
     Removes leading Zeroes from String.
     Example:
     For an input of 00000256, Returns  256
     @param string A String representation containing number having leading zeroes.
     @return String representation wihout the leading zeroes.
     */
    static func filterZeroPrefixFromString(string: String) -> String {
        let getValue = (string as NSString).intValue
        return "\(getValue)"
    }
    
    /**
     Returns the database handler which can be used for making calls to application database.
     @return Optional IDataManager
     */
    static func getApplicationDataManager() -> IDataManager? {
        let dataManager: IDataManager
        do {
            dataManager = try ApplicationManager.sharedInstance().getDataManager()
        } catch let error as NSError {
            Logger.loggerWithlog (
                LEVEL.ERROR,
                className: self.classForCoder(),
                methodName: #function,
                msg: NSLocalizedString("Error while fetching application Data Manager: \(error.localizedDescription)",  comment: "")
            )
            return nil
        }
        return dataManager
    }
}
