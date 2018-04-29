//
//  ContactStore.swift
//  ContactEdit
//
//  Created by Roman Kozak on 4/29/18.
//  Copyright © 2018 Roman Kozak. All rights reserved.
//

import Foundation
import Contacts

class StoreManager {
    static let firstNames = ["Mary", "Patricia", "Linda", "Barbara", "Elizabeth", "Jennifer", "Maria", "Susan", "Margaret", "Dorothy", "Lisa", "Nancy", "Karen", "Betty", "Helen", "Sandra", "Donna", "Carol", "Ruth", "Sharon", "James", "John", "Robert", "Michael", "William", "David", "Richard", "Charles", "Joseph", "Thomas", "Christopher", "Daniel", "Paul", "Mark", "Donald", "George", "Kenneth", "Steven", "Edward", "Brian"]
    static let lastNames = ["Smith", "Johnson", "Williams", "Jones", "Brown", "Davis", "Miller", "Wilson", "Moore", "Taylor", "Anderson", "Thomas", "Jackson", "White", "Harris", "Martin", "Thompson", "Garcia", "Martinez", "Robinson", "Clark", "Rodriguez", "Lewis", "Lee", "Walker", "Hall", "Allen", "Young", "Hernandez", "King", "Wright", "Lopez", "Hill", "Scott", "Green", "Adams", "Baker", "Gonzalez", "Nelson", "Carter"]
    static let phonePrefixes = ["+38063", "+38093", "+38065", "+38098"]
    
    var store: CNContactStore
    var allContacts = [CNContact]()
    
    public init(with store: CNContactStore) {
        self.store = store
        refreshAllContacts()
    }
    
    //////
    
    func refreshAllContacts() {
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: store.defaultContainerIdentifier())
        allContacts = try! store.unifiedContacts(matching: predicate,
                                                 keysToFetch: [CNContactPhoneNumbersKey as CNKeyDescriptor])
    }
    
    func generateContacts(_ count: Int) {
        let fixedCount = (count < 5000) ? count : 5000
        let saveRequest = CNSaveRequest()
        for _ in 0..<fixedCount {
            saveRequest.add(StoreManager.generateRandomContact(), toContainerWithIdentifier: nil)
        }
        
        do {
            try store.execute(saveRequest)
        } catch {
            print("failed to generate with error \(error)")
        }
    }
    
    func removeRandomContacts(_ count: Int) {
        let fixedCount = (count < allContacts.count) ? count : allContacts.count
        let deleteRequest = CNSaveRequest()
        var alreadyRemoved = Set<Int>()
        while alreadyRemoved.count < fixedCount {
            let i = StoreManager.random(allContacts.count)
            if alreadyRemoved.contains(i) {
                continue
            }
            
            alreadyRemoved.insert(i)
            deleteRequest.delete(allContacts[i].mutableCopy() as! CNMutableContact)
        }
        
        do {
            try store.execute(deleteRequest)
            refreshAllContacts()
        } catch {
            print("failed to generate with error \(error)")
        }
    }
    
    /////
    
    static func generateRandomContact() -> CNMutableContact {
        let contact = CNMutableContact()
        contact.givenName = firstNames[random(firstNames.count)]
        contact.familyName = lastNames[random(lastNames.count)]
        let phone = CNPhoneNumber(stringValue:
            phonePrefixes[random(phonePrefixes.count)] + randomNumberString(with: 7))
        contact.phoneNumbers = [CNLabeledValue<CNPhoneNumber>(label: CNLabelHome,
                                                              value: phone)]
        return contact
    }
    
    //////
    
    static func random(_ up: Int) -> Int {
        return Int(arc4random_uniform(UInt32(up)))
    }
    
    static func randomNumberString(with size: Int) -> String {
        let string = NSMutableString()
        for _ in 0..<size {
            string.append(String(random(10)))
        }
        return String(string)
    }
    
}
