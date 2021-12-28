//
//  LocalizeExtension.swift
//  Contacts
//
//  Created by Саша Василенко on 20.12.2021.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString(self, tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
}
