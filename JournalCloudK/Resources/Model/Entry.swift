//
//  Entry.swift
//  JournalCloudK
//
//  Created by Xavier on 11/5/18.
//  Copyright © 2018 Xavier ios dev. All rights reserved.
//

import Foundation
import CloudKit

struct Constants {
     static let titleKey = "Title"
     static let bodyKey = "Body"
      static let recordKey = "Entry"
}

class Entry {
    var title: String
    var body: String
    var ckRecordId: CKRecord.ID
    
    init(title: String, body: String, ckRecordId: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.title = title
        self.body = body
        self.ckRecordId = ckRecordId
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let title = ckRecord[Constants.titleKey] as? String,
            let body = ckRecord[Constants.bodyKey] as? String else { return nil }
        self.init(title: title, body: body, ckRecordId: ckRecord.recordID)
    }
}

extension Entry: Equatable {
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.title == rhs.title && lhs.body == rhs.body
    }
}

extension CKRecord {
    
    convenience init(entry: Entry) {
        self.init(recordType: Constants.recordKey, recordID: entry.ckRecordId)
        
        self.setValue(entry.title, forKey: Constants.titleKey)
        self.setValue(entry.body, forKey: Constants.bodyKey)
    }
}
