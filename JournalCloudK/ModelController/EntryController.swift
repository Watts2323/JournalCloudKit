//
//  EntryController.swift
//  JournalCloudK
//
//  Created by Xavier on 11/5/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    
    //Shared Intsance/ Singleton
    static let shared = EntryController()
    
    //Entry Array aka Source of Truth. We will be appending new Entries to this Entry Array
    var entries: [Entry] = []
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    func save(entry: Entry, completion: @escaping (Bool) -> Void) {
        let entryRecord = CKRecord(entry: entry)
        
        CKContainer.default().privateCloudDatabase.save(entryRecord) { (record, error) in
            if let error = error {
                print("There was an error in \(#function) ; \(error) ; \(error.localizedDescription) ")
                completion(false); return
            }
            guard let record = record,
                // Creating a new instance of an Entry to append to the entries array later
                let newEntry = Entry(ckRecord: record) else { completion(false);return}
            self.entries.append(newEntry)
            completion(true)
        }
    }
    func addEntryWith(title: String, body:String, completion: @escaping (Bool) -> Void) {
        let entry = Entry(title: title, body: body)
        
        self.save(entry: entry) { (success) in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func update(entry: Entry, title: String, body: String, completion: @escaping (Bool) -> Void) {
        
        //Update locally
        entry.title = title
        entry.body = body
        
        //Update the entry record from CK
        privateDB.fetch(withRecordID: entry.ckRecordId) { (record, error) in
            if let error = error {
                print("There was an error in \(#function) ; \(error) ; \(error.localizedDescription) ")
                completion(false);return
            }
            guard let record = record else { completion(false);return}
            
            record[Constants.titleKey] = title
            record[Constants.bodyKey] = body
            
            //Black Diamond
            // CKModifyRecordsOperation is it's own class and it has properties called records to save and records to delete. It allows you to save records and delete record IDs from the database after they have been modified.
            let operations = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: [record.recordID])
            //This is basically used to keeop everything fresh. Because records can be modified at any point, the savePolicy knows which records are relevant,knows when a newer version of an exsisiting record comes about. The changed keys means it saves only records that have been saved. There are other constants you can use
            operations.savePolicy = .changedKeys
            //Defaults to normal, But it helps you prioritize the order in which operations execute, low, normal, high, very High
            operations.queuePriority = .high
            //Does whatever the user clicks on basically. User friendly
            operations.qualityOfService = .userInitiated
            //This runs after the operations execute and the results come back
            operations.modifyRecordsCompletionBlock = { (records, recordIDs, error) in
                completion(true)
            }
            self.privateDB.add(operations)
        }
    }
    
    func delete(entry: Entry, completion: @escaping (Bool) -> Void) {
        
        //Delete entry Locally
        guard let index = EntryController.shared.entries.firstIndex(of: entry) else { return }
        EntryController.shared.entries.remove(at: index)
        
        //Delete Entry from CloudKit
        privateDB.delete(withRecordID: entry.ckRecordId) { (record, error) in
            if let error = error {
                print("There was an error in \(#function) ; \(error) ; \(error.localizedDescription) ")
                completion(false);return
            } else {
                print("Record was deleted from Cloudkit 🤙🏿")
                completion(true)
            }
        }
    }
    
    func fetchEntries(completion: @escaping (Bool) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.recordKey, predicate: predicate)
        
        CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: nil) { (record, error) in
            if let error = error {
                print("There was an error in \(#function) ; \(error) ; \(error.localizedDescription) ")
                completion(false);return
            }
            guard let record = record else { completion(false); return }
            
//            var entriesFromFetch: [Entry] = []
            
            let entries = record.compactMap{ Entry(ckRecord: $0) }
            self.entries = entries
            completion(true)
        }
    }
}
