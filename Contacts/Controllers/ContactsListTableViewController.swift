//
//  ContactsListTableViewController.swift
//  Contacts
//
//  Created by Саша Василенко on 21.12.2021.
//

import Foundation
import UIKit

class ContactListTableViewController: UITableViewController {
    
    
    
    
    
    @IBOutlet weak var addContactBarButton: UIBarButtonItem!
    
    private var contactsListViewModel = ContactsListViewModel()
    var searchController = UISearchController()
    let refreshControl1 = UIRefreshControl()
    
    var filteredContacts:  [Contact] = []
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        refreshControl1.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl1)
        setupSearchController()
        configBackgroundView()
    }
    
    @objc func refresh(sender:AnyObject) {
        tableView.reloadData()
        self.refreshControl1.endRefreshing()
    }
    
    func configBackgroundView() {
        let frame = tableView.frame
        tableView.backgroundView = EmptyListView(frame: frame)
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(true)
    }
    func setup() {
        contactsListViewModel.loadContacts()
        contactsListViewModel.setAlphabetSections()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        definesPresentationContext  = true
    }
    
   
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "NewContactController") as? NewContactController {
            vc.updateTableDelegate = self
            vc.contactsListViewModel = contactsListViewModel
            vc.contactsListViewModel.reloadDelegate = self
            let navVC = UINavigationController.init(rootViewController: vc)
            self.present(navVC, animated: true)
        }
    }
    
//    MARK: Swipe actions
    private func handleDeleteContact(contact: Contact) {
        contactsListViewModel.deleteContact(contact: contact)
        tableView.reloadData()
    }
    
    private func handleEditContact(contact: Contact) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let editVC = storyboard.instantiateViewController(withIdentifier: "NewContactController") as? NewContactController {
            editVC.contactToEdit = contact
            editVC.typeOfInteract = .editExisting
            editVC.contactsListViewModel = contactsListViewModel
            editVC.contactsListViewModel.reloadDelegate = self
            navigationController?.pushViewController(editVC, animated: true)
        } else { return }
    }
    
    
//    MARK: TableView conforming
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredContacts.count
        }
        
        if contactsListViewModel.contactDataService.savedContacts.isEmpty {
            tableView.backgroundView = EmptyListView(frame: tableView.frame)
        } else {
            tableView.backgroundView = nil
        }
        return contactsListViewModel.sections[section].contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = contactsListViewModel.sections[indexPath.section]
        let contactVM: Contact
        if isFiltering {
            contactVM = filteredContacts[indexPath.row]
        } else {
            contactVM = section.contacts[indexPath.row]
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactTableViewCell", for: indexPath) as? ContactTableViewCell else {
            fatalError("Cell not found")
        }
//        let contactVM = self.contactsListViewModel.contactAtIndex(indexPath.row)
        cell.contactNameLabel.text = contactVM.firstName + " " + contactVM.lastName
        cell.contactPhoneNumberLabel.text = contactVM.phoneNumber
        cell.contactImage.setRounded()
        cell.contactImage.image = contactVM.photo
        cell.contactImage.setRounded()
        
        print(contactVM.phoneNumber)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = contactsListViewModel.sections[indexPath.section]
        let contactVM: Contact
        if isFiltering {
            contactVM = filteredContacts[indexPath.row]
        } else {
            contactVM = section.contacts[indexPath.row]
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let contactVC = storyboard.instantiateViewController(withIdentifier: "DetailController") as? ContactInformationViewController else { return }
        contactVC.contactViewModel = contactVM
        contactVC.contactListViewModel = contactsListViewModel
        contactVC.contactListViewModel.reloadDelegate = self
        navigationController?.pushViewController(contactVC, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return 1
        }
        return contactsListViewModel.sections.count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isFiltering {
            return nil
        }
        return contactsListViewModel.sections.map { $0.letter }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return nil
        }
        return contactsListViewModel.sections[section].letter
    }
    
//    MARK: Tableview trailing swipe actions
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var section = contactsListViewModel.sections[indexPath.section]
        let contactVM = section.contacts[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete".localized()) {  [weak self] (action, view, completionHandler) in
            self?.handleDeleteContact(contact: contactVM)
            section.contacts.remove(at: indexPath.row)
            tableView.reloadData()
            completionHandler(true)
        }
        let edit = UIContextualAction(style: .normal, title: "Edit".localized()) { [weak self] (action, view, completionHandler) in
            self?.handleEditContact(contact: contactVM)
        }
        delete.backgroundColor = .systemRed
        edit.backgroundColor = .systemOrange
        let configuration = UISwipeActionsConfiguration(actions: [delete, edit])
        tableView.reloadData()
        if isFiltering {
            return nil
        }
        
        return configuration
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredContacts = contactsListViewModel.contacts.filter( { (contact: Contact) -> Bool in
            let searchString = contact.firstName + " " + contact.lastName +  " " + contact.phoneNumber
            return searchString.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
}

//MARK: SearchController
extension ContactListTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard
            let text = searchBar.text,
            !text.isEmpty
        else { return }
        print(text)
    }
}

extension ContactListTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}

extension ContactListTableViewController: ReloadContactsTableDelegate {
    func reloadContactsTable() {
        tableView.reloadData()
        print("called delegate")
    }
}

