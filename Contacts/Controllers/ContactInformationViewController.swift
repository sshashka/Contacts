//
//  ContactInformationViewController.swift
//  Contacts
//
//  Created by Саша Василенко on 20.12.2021.
//

import UIKit

class ContactInformationViewController: UIViewController {
    
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var detailTableVIew: UITableView!
    
    var contactListViewModel: ContactsListViewModel!
    var contactViewModel: Contact!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "\(contactViewModel.firstName)" + " " + "\(contactViewModel.lastName)"
        navigationController?.navigationBar.prefersLargeTitles = false
        contactImage.image = contactViewModel.photo
        contactImage.setRounded()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(presentEditController))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        detailTableVIew.reloadData()
    }
    
    @objc func presentEditController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "NewContactController") as? NewContactController {
            editVC.contactToEdit = contactViewModel
            editVC.typeOfInteract = .editExisting
            editVC.contactsListViewModel = contactListViewModel
            editVC.editedContactDelegate = self
            navigationController?.pushViewController(editVC, animated: true)
        } else { return }
    }
}

extension ContactInformationViewController: UITableViewDelegate, UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactInformationTableViewCell", for: indexPath) as? ContactInformationTableViewCell else {
            fatalError()
        }
        
        switch indexPath.row {
        case 0:
            cell.contactTypeLabel.text = "First name".localized()
            cell.contactInfoLabel.text = contactViewModel.firstName
        case 1:
            cell.contactTypeLabel.text = "Last name".localized()
            cell.contactInfoLabel.text = contactViewModel.lastName
        case 2:
            cell.contactTypeLabel.text = "Phone".localized()
            cell.contactInfoLabel.text = contactViewModel.phoneNumber
        case 3:
            cell.contactTypeLabel.text  = "Email"
            cell.contactInfoLabel.text = contactViewModel.email
        case 4:
            cell.contactTypeLabel.text = "Birthday".localized()
            cell.contactInfoLabel.text = contactViewModel.birthday
        case 5:
            cell.contactTypeLabel.text = "Height".localized()
            cell.contactInfoLabel.text = contactViewModel.height
        case 6:
            cell.contactTypeLabel.text = "Notes".localized()
            cell.contactInfoLabel.text = contactViewModel.notes
        default:
            cell.contactInfoLabel.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
}

extension ContactInformationViewController: PassEditedContactDelegate {
    func passEditedContact(editedContact: Contact) {
        contactViewModel = editedContact
        detailTableVIew.reloadData()
        contactListViewModel.setAlphabetSections()
        print("pass delegate")
    }
}
