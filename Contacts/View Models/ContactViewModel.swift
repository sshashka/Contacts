//
//  ContactViewModel.swift
//  Contacts
//
//  Created by Саша Василенко on 21.12.2021.
//

import UIKit

class ContactsListViewModel {
    var contacts: [Contact] = []
    var sections = [Section]()
    var reloadDelegate: ReloadContactsTableDelegate?
    let contactDataService = ContactDataService()
}

extension ContactsListViewModel {
    var numberOfSections: Int {
        return sections.count
    }
    
    func setAlphabetSections() {
        let groupedContacts = Dictionary(grouping: contacts, by: { String(($0.firstName + $0.lastName).prefix(1)) })
        let keys = groupedContacts.keys.sorted()
        sections = keys.map { Section(letter: String($0).uppercased(), contacts: groupedContacts[$0]!.sorted { (contact1, contact2) -> Bool in
            let contactName1 = contact1.firstName + contact1.lastName + contact1.email
            let contactName2 = contact2.firstName + contact2.lastName + contact2.email
            return (contactName1.localizedCaseInsensitiveCompare(contactName2)) == .orderedAscending
        })}
    }
    
    func numberOfRowsInSection(_ index: Int) -> Int {
        return self.sections[index].contacts.count
    }
    
    func contactAtIndex(section: Int, _ index: Int) -> ContactViewModel {
        let contact = sections[section].contacts[index]
        return ContactViewModel(contact)
    }
    
    func loadContacts() {
        contacts = contactDataService.retrieveContacts()
        self.setAlphabetSections()
    }
    
    func addContact(contact: Contact) {
        contactDataService.add(contact: contact)
        contacts.append(contact)
        self.setAlphabetSections()
        reloadDelegate?.reloadContactsTable()
    }
    
    func updateContact(contact: Contact) {
        guard let index = contacts.firstIndex(where: {$0.id == contact.id}) else { return }
        if let entityToUpdate = contactDataService.savedContacts.first(where: { $0.id == contact.id }) {
            contactDataService.update(entity: entityToUpdate)
        }
        contacts[index] = contact
        setAlphabetSections()
    }
    
    func deleteContact(contact: Contact) {
        guard let index = contacts.firstIndex(where: {$0.id == contact.id}) else { return }
        if let entityToDelete = contactDataService.savedContacts.first(where: {$0.id == contact.id}) {
            contactDataService.delete(entity: entityToDelete)
            contacts.remove(at: index)
            self.setAlphabetSections()
        }
    }
}

struct Section {
    let letter: String
    var contacts: [Contact]
}

struct ContactViewModel {
    var contact: Contact
    
    init(contact: Contact) {
        self.contact = contact
    }
}

extension ContactViewModel {
    init(_ contact: Contact) {
        self.contact = contact
    }
}

extension ContactViewModel {
    var firstName: String {
        return self.contact.firstName
    }
    var lastName: String {
        return self.contact.lastName
    }
    var phoneNumber: String {
        return self.contact.phoneNumber
    }
    var email: String {
        return self.contact.email
    }
    var birthday: String {
        return self.contact.birthday
    }
    var height: String {
        return self.contact.height
    }
    var notes: String {
        return self.contact.notes
    }
    var photo: UIImage {
        return self.contact.photo ?? UIImage(named: "emptyAvatar")!
    }
}


