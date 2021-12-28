//
//  ContactDataService.swift
//  Contacts
//
//  Created by Саша Василенко on 20.12.2021.
//
import CoreData
import UIKit

class ContactDataService {
    private let container: NSPersistentContainer
    private let containerName: String = "Contacts"
    private let entityName: String = "ContactItem"
    
    var savedContacts: [ContactItem] = []
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { (_ , error) in
            if let error = error {
                print("Unable to load Core Data \(error)")
            }
        }
        self.getContacts()
    }
    
    func getContacts() {
        let request = NSFetchRequest<ContactItem>(entityName: entityName)
        do {
           savedContacts = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching contacts. \(error)")
        }
    }
    
    func add(contact: Contact) {
        let entity = ContactItem(context: container.viewContext)
        entity.id = Int16(contact.id)
        entity.firstName = contact.firstName
        entity.lastName = contact.lastName
        entity.phoneNumber = contact.phoneNumber
        entity.email =  contact.email
        entity.birthday = contact.birthday
        entity.height = contact.height
        entity.notes = contact.notes
        entity.photo = contact.photo?.jpegData(compressionQuality: 0.1)
        applyChanges()
    }
    
    func update(entity: ContactItem) {
        guard let index = savedContacts.firstIndex(where: { $0.phoneNumber == entity.phoneNumber }) else { return }
        savedContacts[index] = entity
        applyChanges()
    }
    
    func delete(entity: ContactItem) {
        container.viewContext.delete(entity)
        applyChanges()
    }
    
    func retrieveContacts() -> [Contact] {
        var retrievedContacts: [Contact] = []
        guard savedContacts.isEmpty == false else {
            return []
        }
        for savedContact in savedContacts {
            let id = savedContact.id
            guard
                let firstName = savedContact.firstName ,
                let lastName = savedContact.lastName ,
                let phoneNumber = savedContact.phoneNumber,
                let email = savedContact.email,
                let birthday = savedContact.birthday,
                let height = savedContact.height,
                let notes = savedContact.notes,
                let photo = UIImage(data: savedContact.photo ?? Data.init())
                else {
                    return retrievedContacts
            }
            retrievedContacts.append(Contact(id: Int(id), firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, email: email, birthday: birthday, height: height, notes: notes, photo: photo))
        }
        return retrievedContacts
    }
    
    private func save() {
        do {
            try container.viewContext.save()
        } catch let error {
            print("Unable to save to Core Data. \(error)")
        }
    }
    
    private func applyChanges() {
        save()
        getContacts()
    }
}

