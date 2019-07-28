//
//  NSManagedObject+Custom.swift
//  Lexlab
//
//  Created by Lexter Labra on 6/12/15.
//  Copyright © 2015 Lexter Labra. All rights reserved.
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
}
