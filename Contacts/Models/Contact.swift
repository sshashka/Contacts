//
//  Contact.swift
//  Contacts
//
//  Created by Саша Василенко on 20.12.2021.
//

import UIKit

struct ContactList {
    var contacts: Contact
}

struct Contact {
    var id: Int
    var firstName: String
    var lastName: String
    var phoneNumber: String
    var email: String
    var birthday: String
    var height: String
    var notes: String
    var photo: UIImage?


    init() {
        self.id = 0
        self.firstName = ""
        self.lastName = ""
        self.phoneNumber = ""
        self.email = ""
        self.birthday = ""
        self.height = ""
        self.notes = ""
        self.photo = nil
    }
    
    init(id: Int, firstName: String, lastName: String, phoneNumber: String, email: String, birthday: String, height: String, notes: String, photo: UIImage?) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.phoneNumber = phoneNumber
        self.email = email
        self.birthday = birthday
        self.height = height
        self.notes = notes
        self.photo = photo
    }
}
