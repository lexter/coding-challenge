//
//  NSManagedObject+Custom.swift
//  LexterAppetiser
//
//  Created by Lexter Labra on 27/07/2019.
//  Copyright © 2019 Lexter Labra. All rights reserved.
//

import Foundation
import CoreData

// -------------------------------------------------------------------------------------------------------------------------------
// -------------------------------------------------------------------------------------------------------------------------------
// This code is taken from
// http://stackoverflow.com/questions/27109268/how-can-i-create-instances-of-managed-object-subclasses-in-a-nsmanagedobject-swi
// Its purpose is to create an entity in a flexible manner.

/**
 This method is used to cast an object to its exact data type.
 - parameter obj: An object subject for casting.
 - returns: T  The exact object data type.
 */
func objcast<T>(_ obj: AnyObject) -> T { return obj as! T }
// -------------------------------------------------------------------------------------------------------------------------------

/// Extending NSManagedObject to add flexibility.
extension NSManagedObject {
    
    // MARK: - Create Methods
    
    // -------------------------------------------------------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------------------------------------------------------
    // This code is taken from
    // http://stackoverflow.com/questions/27109268/how-can-i-create-instances-of-managed-object-subclasses-in-a-nsmanagedobject-swi
    // Its purpose is to create an entity in a flexible manner.
    
    /**
     Create and return an instance of NSManagedObject class.
     It also return the exact subclass' data type. In our case,
     Languages and LanguagePairs are a subclass of NSManagedObject,
     when calling this class method in Language using this code Language.create(context),
     it returns the Language instance, not the NSManagedObject.
     
     - parameter context: The context to where the managed object stored. If the context value is nil, it will use the application managed object context.
     
     - returns: instance  The actual object instance.
     */
    final class func createInContext(_ context:NSManagedObjectContext) -> Self {
        return objcast(NSEntityDescription.insertNewObject(forEntityName: entityName(), into: context))
    }
    
    final class func createWithEntityName(_ entityName: String, context:NSManagedObjectContext) -> Self {
        return objcast(NSEntityDescription.insertNewObject(forEntityName: entityName, into: context))
    }
    
    /**
     Returns the name of this class in a string.
     
     - returns: String The string name of this class.
     */
    final class func entityName() -> String {
        let classString = NSStringFromClass(self)
        // The entity is the last component of dot-separated class name:
        let components = classString.split { $0 == "." }.map { String($0) }
        return components.last ?? classString
    }
    // -------------------------------------------------------------------------------------------------------------------------------
    
    // MARK: - Fetch Methods
    
    /**
     Executes a fetch request with predicate and sort options for this class's entity and return the results.
     It constructs the sort descriptors and group by query options at runtime based on the values being passed in sortDescriptors and groupBy respectively.
     If an error occurs during the execution, an empty array is return.
     
     - parameter predicate:   An NSPredicate to be assigned when executing the fetching. This is an optional. When predicate is not necessary, just pass in nil.
     - parameter sortDescriptors: An array of Dictionary<String, String> containing "key" and "ascending" keys; where "key" contains the entity field and "ascending" for the order which should only contain "true" or "false" string literals. It will be constructed into NSSortDescriptor and assign each to fetch request. This is an optional. When sort descriptors are not necessary, just pass in nil.
     - parameter limit:   Used as the fetch query limit. Default is 0, which means the fetchRequest limit is is used. This is optional.
     - parameter context: The context. This is optional. If the context value is nil, it will use the application managed object context.
     
     - returns: request result    Returns the result on success; empty array on error/fail.
     */
    final class func fetch<T: NSManagedObject>(predicate:NSPredicate?, sortDescriptors: [[String: String]]?, limit: Int = 0, context:NSManagedObjectContext) -> [T] {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: entityName())
        fetchRequest.predicate = predicate
        
        // Construct the sort descriptors
        if sortDescriptors != nil {
            var sortItems: [NSSortDescriptor] = []
            for sortObj in sortDescriptors! {
                let sort = NSSortDescriptor(key: sortObj["key"]!, ascending: sortObj["ascending"]! == "true" ? true : false)
                sortItems.append(sort)
            }
            fetchRequest.sortDescriptors = sortItems
        }
        
        if limit > 0 { fetchRequest.fetchLimit = limit }
        
        do {
            let result = try context.fetch(fetchRequest)
            return result
        } catch let error as NSError {
            print("\(#function) Error ---> \(error)")
            return []
        }
    }
    
    /**
     Executes a DISTINCT fetch request with predicate and sort options for this class's entity and return the results.
     It constructs the sort descriptors and group by query options at runtime based on the values being passed in sortDescriptors and groupBy respectively.
     If an error occurs during the execution, an empty array is return.
     
     - parameter predicate:   An NSPredicate to be assigned when executing the fetching. This is an optional. When predicate is not necessary, just pass in nil.
     - parameter propertiesToFetch: The properties to be including in the fetch result.
     - parameter sortDescriptors: An array of Dictionary<String, String> containing "key" and "ascending" keys; where "key" contains the entity field and "ascending" for the order which should only contain "true" or "false" string literals. It will be constructed into NSSortDescriptor and assign each to fetch request. This is an optional. When sort descriptors are not necessary, just pass in nil.
     - parameter limit:   Used as the fetch query limit. Default is 0, which means the fetchRequest limit is is used. This is optional.
     - parameter context: The context. This is optional. If the context value is nil, it will use the application managed object context.
     
     - returns: request result    Returns the result on success; empty array on error/fail.
     */
    final class func distinctFetch(predicate:NSPredicate?, propertiesToFetch: [String], sortDescriptors: [[String: String]]?, limit: Int = 0, context:NSManagedObjectContext) -> [AnyObject] {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName())
        fetchRequest.predicate = predicate
        
        // Construct the sort descriptors
        if sortDescriptors != nil {
            var sortItems: [NSSortDescriptor] = []
            for sortObj in sortDescriptors! {
                let sort = NSSortDescriptor(key: sortObj["key"]!, ascending: sortObj["ascending"]! == "true" ? true : false)
                sortItems.append(sort)
            }
            fetchRequest.sortDescriptors = sortItems
        }
        
        if limit > 0 { fetchRequest.fetchLimit = limit }
        
        fetchRequest.returnsDistinctResults = true
        fetchRequest.propertiesToFetch = propertiesToFetch
        fetchRequest.resultType = .dictionaryResultType
        
        do {
            let result = try context.fetch(fetchRequest)
            return result as [AnyObject]
        } catch _ as NSError {
            return []
        }
    }
    
    /**
     Fetch all items of this NSManagedObject instance with no options.
     The function calls the fetch(predicate, sortDescription, context) method and pass nil on both predicate and sort parameters.
     If an error occurs during the execution, an empty array is return.
     
     - parameter context: The context. This is an optional. If the context value is nil, it will use the application managed object context.
     
     - returns: request result    Returns the result on success; empty array on error/fail.
     */
    final class func fetchAll<T: NSManagedObject>(_ context: NSManagedObjectContext) -> [T] {
        return self.fetch(predicate: nil, sortDescriptors: nil, context: context)
    }
    
    /**
     Fetch all items of this NSManagedObject instance with no options.
     The function calls the fetch(predicate, sortDescription, context) method and pass nil on predicate,
     while the sortDescriptor will be of the value with this method sortDescriptor parameter.
     If an error occurs during the execution, an empty array is return.
     
     - parameter sortDescriptors: An array of Dictionary<String, String> containing "key" and "ascending" keys; where "key" contains the entity field and "ascending" for the order which should only contain "true" or "false" string literals. It will be constructed into NSSortDescriptor and assign each to fetch request. This is an optional. When sort descriptors are not necessary, just pass in nil.
     - parameter context: The context. This is an optional. If the context value is nil, it will use the application managed object context.
     
     - returns: request result    Returns the result on success; empty array on error/fail.
     */
    final class func fetchAllWithSort<T: NSManagedObject>(_ sortDescriptors: [[String: String]], context: NSManagedObjectContext) -> [T] {
        return self.fetch(predicate: nil, sortDescriptors: sortDescriptors, context: context)
    }
    
    /**
     Fetch all items of this NSManagedObject instance with no options.
     The function calls the fetch(predicate, sortDescription, context) method and pass nil on sortDescriptors,
     while the predicate will be of the value with this method predicate parameter.
     If an error occurs during the execution, an empty array is return.
     
     - parameter predicate:   An NSPredicate to be assigned when executing the fetching. This is an optional. When predicate is not necessary, just pass in nil.
     - parameter context: The context. This is an optional. If the context value is nil, it will use the application managed object context.
     
     - returns: request result    Returns the result on success; empty array on error/fail.
     */
    final class func fetchWithPredicate<T: NSManagedObject>(_ predicate: NSPredicate, context: NSManagedObjectContext) -> [T] {
        return self.fetch(predicate: predicate, sortDescriptors: nil, context: context)
    }
    
    /**
     Fetch an item of this NSManagedObject instance that matches the predicate.
     The function calls the fetchWithPredicate(predicate, context) method where predicate will be of the value with this method predicate parameter.
     If success, the function will return the object; otherwise, nil
     
     - parameter predicate:   An NSPredicate to be assigned when executing the fetching. This is an optional. When predicate is not necessary, just pass in nil.
     - parameter context: The context. This is an optional. If the context value is nil, it will use the application managed object context.
     
     - returns: result    Returns the result object on success; nil on no match and error/fail.
     */
    final class func fetchObject<T: NSManagedObject>(predicate: NSPredicate, context: NSManagedObjectContext) -> T? {
        return self.fetchWithPredicate(predicate, context: context).first
    }
    
    // MARK: - Delete Methods
    
    /**
     Delete the item passed in the parameter.
     The passed managedObject will get type casted into this class type.
     
     - parameter managedObject:   The managed object to be deleted.
     - parameter context: The context. This is an optional. If the context value is nil, it will use the application managed object context.
     */
    class func delete(_ managedObject: AnyObject, context: NSManagedObjectContext) {
        context.delete(objcast(managedObject))
    }
    
    // MARK: - Managed Object Utilities
    
    // -------------------------------------------------------------------------------------------------------------------------------
    // -------------------------------------------------------------------------------------------------------------------------------
    // Taken from http://stackoverflow.com/questions/24844681/list-of-classs-properties-in-swift
    /**
     List all properties of the class and return them in an array.
     
     - returns: array  Array contains the list of the properties along with its data type.
     */
    //    final func allProperties() -> [[String: String]] {
    //        var propertyNames: [[String: String]] = []
    /*var count: UInt32 = 0
     autoreleasepool { () -> () in
     let properties: UnsafeMutablePointer <objc_property_t> = class_copyPropertyList(self.classForCoder , &count);
     let intCount = Int(count)
     for i in 0 ..< intCount {
     autoreleasepool(invoking: {
     let property: objc_property_t = properties[i]
     
     // Get the property's declared name
     let name = NSString(utf8String: property_getName(property))!
     
     // -------------------------------------------------------------------------------------------------------------------------------
     // -------------------------------------------------------------------------------------------------------------------------------
     // This solution is taken from  http://stackoverflow.com/questions/25517073/ios-how-do-i-get-an-objects-propertys-type-in-swift
     //
     // Get the property's Data Type
     let attr = String(validatingUTF8: property_getAttributes(property))!.components(separatedBy: ",")
     var varType = attr.first!.replacingOccurrences(of: "T@", with: "", options: NSString.CompareOptions.regularExpression, range: nil)
     varType = varType.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.regularExpression, range: nil)
     
     // If the data tpye is empty, it means it is of type String.
     // Hence, explicitly assign "String" for dev friendly purposes.
     varType = varType.isEmpty ? "String" : varType
     
     propertyNames.append(["name": (name as String), "dataType": varType])
     })
     }
     free(properties);
     }*/
    //        return propertyNames;
    //    }
    // -------------------------------------------------------------------------------------------------------------------------------
    
    /**
     Map the source data key-values to the managed object fields-values respectively.
     This is a case sensitive assignment.
     Both source and destination keys/fields must match.
     
     - parameter dictionary:  Source data that contains the key-value pair.
     */
//    @objc func mapData(_ sourceData: [String: AnyObject]) {
        //        let props: [[String: String]] = self.allProperties()
        //        for dictProp in props {
        //            let dataType = dictProp["dataType"]!
        //            if dataType == "NSSet" || dataType == "NSMutableSet" || dataType == "NSArray" || dataType == "NSMutableArray" || dataType == "NSDictionary" || dataType == "NSMutableDictionary" || dataType == "Array" || dataType == "Dictionary" { continue }
        //            let prop = dictProp["name"]!
        //            let value: AnyObject? = sourceData[prop]
        //            if (value is NSNull || value == nil) { continue }
        //            self.setValue(sourceData[prop], forKey: prop)
        //        }
//    }
}
