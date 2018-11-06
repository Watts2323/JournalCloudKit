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
                completion(false)
            } else {
                completion(true)
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
        }
    }
}
