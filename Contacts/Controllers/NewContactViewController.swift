//
//  NewContactViewController.swift
//  Contacts
//
//  Created by Саша Василенко on 21.12.2021.
//

import UIKit
import MobileCoreServices
import AVFoundation
import Photos

class NewContactController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, SaveButtonDelegate {
    
//    Enum to determine whether we are adding new contact, or modifying existing
    enum TypeOfControllerInteraction  {
        case addNew
        case editExisting
    }
    
    var updateTableDelegate: ReloadContactsTableDelegate?
    var editedContactDelegate: PassEditedContactDelegate?
    var contactToEdit: Contact?
    var typeOfInteract: TypeOfControllerInteraction = .addNew
    var imagePickerController: UIImagePickerController!
    var birthdayPicker: UIDatePicker!
    var heightPicker: UIPickerView!
    var contactsListViewModel: ContactsListViewModel!
    var contactCollector: [Row : String] = [.firstName : "", .lastName : "", .phoneNumber : "", .email : "", .birthday : "", .height : "", .notes : ""]
    
    @IBOutlet weak var contactTableView: UITableView!
    @IBOutlet weak var contactAvatar: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    
//    MARK: ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        self.birthdayPicker = UIDatePicker()
        if #available(iOS 13.4, *) {
            birthdayPicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        self.heightPicker = UIPickerView()
        if typeOfInteract == .editExisting, let contactToEdit = contactToEdit {
            addPhotoButton.setTitle("Change photo".localized(), for: .normal)
            self.title = contactToEdit.firstName +  " " + contactToEdit.lastName
        }
        heightPicker.delegate = self
        heightPicker.dataSource = self
        disableSaveButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.imagePickerController = UIImagePickerController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateTableDelegate?.reloadContactsTable()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateTableDelegate?.reloadContactsTable()
    }
//    ImagePicker methods for camera and PhotoLibrary
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            DispatchQueue.main.async {
                self.imagePickerController.allowsEditing = true
                self.imagePickerController.sourceType = .camera
                self.imagePickerController.mediaTypes = [kUTTypeImage as String]
                self.imagePickerController.delegate = self
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
        }
    }
    
    func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            DispatchQueue.main.async {
                self.imagePickerController.allowsEditing = true
                self.imagePickerController.sourceType = .photoLibrary
                self.imagePickerController.delegate = self
                self.present(self.imagePickerController, animated: true, completion: nil)
            }
        }
    }
    
//    Restricted access to photo sources alert methods
    func alertForRestrictedCameraAccess() {
        let alert = UIAlertController(title: "Camera access".localized(), message: "Access to the camera is prohibited. Please provide it in settings to continue.".localized(), preferredStyle: .alert)
        let goToSettings = UIAlertAction(title: "Settings".localized(), style: .default) { _ in
            self.openSettings()
        }
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel) {_ in }
        alert.addAction(goToSettings)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func alertForRestrictedPhotoAccess() {
        let alert =  UIAlertController(title: "Photos access".localized(), message: "Access to the photo gallery is prohibited. Please provide it in settings to continue.".localized(), preferredStyle: .alert)
        let goToSettings = UIAlertAction(title: "Settings".localized(), style: .default) { _ in
            self.openSettings()
        }
        let cancel = UIAlertAction(title: "Cancel".localized(), style: .cancel) {_ in }
        alert.addAction(goToSettings)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
//    interface builder navBar buttons methods
    @IBAction func cancelAddingNewContact(_ sender: UIButton) {
        
        switch typeOfInteract {
        case .addNew:
            navigationController?.dismiss(animated: true, completion: nil)
        case .editExisting:
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func saveNewContact(_ sender: UIButton) {
        
        switch typeOfInteract {
        case .addNew:
            saveContact()
            updateTableDelegate?.reloadContactsTable()
            navigationController?.dismiss(animated: true, completion: nil)
        case .editExisting:
            editContact()
            updateTableDelegate?.reloadContactsTable()
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func addEditPhotoButton(_ sender: UIButton) {
        actionSheetforImagePicker()
    }
//    Save button delegate methods to enable and disable button if there are mistakes in textFields
    func enableSaveButton() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func disableSaveButton() {
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
//    Creating UIBarButtonItems and adding them to nav bar
    private func configNavigationBar() {
        lazy var cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAddingNewContact))
        lazy var saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveNewContact))
        self.navigationItem.leftBarButtonItem = cancelButton
        self.navigationItem.rightBarButtonItem = saveButton
    }
//    initializing ViewModel of Contacts list and configurating navbar
    func setup() {
        configNavigationBar()
    }
//   MARK: UIPickerViewDelegate/DataSource
    let pickerData: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 3
        case 1:
            return 10
        case 2:
            return 10
        default:
            break
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return pickerData[row]
    }
    
//    collecting data from textfields and creating new Contact object
    func saveContact() {
        for label in labels {
            guard let index = (labels.firstIndex { $0 == label }) else { return }
            let indexPath = IndexPath.init(row: index, section: 0)
            let cell = contactTableView.cellForRow(at: indexPath) as! ContactInputCell
            
            switch label {
            case "First name".localized():
                contactCollector[.firstName] = cell.inputField.text
            case "Last name".localized():
                contactCollector[.lastName] = cell.inputField.text
            case "Phone number".localized():
                contactCollector[.phoneNumber] = cell.inputField.text
            case "Email":
                contactCollector[.email] = cell.inputField.text
            case "Birthday".localized():
                contactCollector[.birthday] = cell.inputField.text
            case "Height".localized():
                contactCollector[.height] = cell.inputField.text
            case "Notes".localized():
                contactCollector[.notes] = cell.inputField.text
            default:
                return
            }
        }
        
        var id = contactsListViewModel.contacts.endIndex + 1
        if contactsListViewModel.contacts.isEmpty {
            id = 0
        }
        
        guard
            let firstName = contactCollector[.firstName],
            let lastName = contactCollector[.lastName],
            let phoneNumber = contactCollector[.phoneNumber],
            let email = contactCollector[.email],
            let birthday = contactCollector[.birthday],
            let height = contactCollector[.height],
            let notes = contactCollector[.notes],
            let photo = self.contactAvatar.image
        else { return }
        
        let contactToSave = Contact(id: id, firstName: firstName, lastName: lastName, phoneNumber: phoneNumber, email: email, birthday: birthday, height: height, notes: notes, photo: photo)
        contactsListViewModel.addContact(contact: contactToSave)
        contactsListViewModel.setAlphabetSections()
//        cleaning contactCollector before next use
        for (key, _) in contactCollector {
            contactCollector[key] = ""
        }
    }
//    collecting data from textfields to edit existing Contact object
    func editContact() {
        guard var contactToEdit = contactToEdit else { return }
        for label in labels {
            guard let index = (labels.firstIndex { $0 == label }) else { return }
            let indexPath = IndexPath.init(row: index, section: 0)
            let cell = contactTableView.cellForRow(at: indexPath) as! ContactInputCell
            
            switch label {
            case "First name".localized():
                contactCollector[.firstName] = cell.inputField.text
            case "Last name".localized():
                contactCollector[.lastName] = cell.inputField.text
            case "Phone number".localized():
                contactCollector[.phoneNumber] = cell.inputField.text
            case "Email":
                contactCollector[.email] = cell.inputField.text
            case "Birthday".localized():
                contactCollector[.birthday] = cell.inputField.text
            case "Height".localized():
                contactCollector[.height] = cell.inputField.text
            case "Notes".localized():
                contactCollector[.notes] = cell.inputField.text
            default:
                return
            }
         
        }
        
        guard
            let firstName = contactCollector[.firstName],
            let lastName = contactCollector[.lastName],
            let phoneNumber = contactCollector[.phoneNumber],
            let email = contactCollector[.email],
            let birthday = contactCollector[.birthday],
            let height = contactCollector[.height],
            let notes = contactCollector[.notes],
            let photo = self.contactAvatar.image
        else { return }
        
        contactToEdit.firstName = firstName
        contactToEdit.lastName  = lastName
        contactToEdit.phoneNumber = phoneNumber
        contactToEdit.email = email
        contactToEdit.birthday = birthday
        contactToEdit.height = height
        contactToEdit.notes = notes
        contactToEdit.photo = photo
        
        contactsListViewModel.updateContact(contact: contactToEdit)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let contactVC = storyboard.instantiateViewController(withIdentifier: "DetailController") as? ContactInformationViewController else { return }
        contactVC.contactViewModel = contactToEdit
        editedContactDelegate?.passEditedContact(editedContact: contactToEdit)
    }
//    method for opening phone settings to allow access to camera/library if restricted
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
                  return
              }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

//MARK: Conforming to TableView
extension NewContactController {
    
    var labels: [String] {
        return ["First name".localized(), "Last name".localized(), "Phone number".localized(), "Email", "Birthday".localized(), "Height".localized(), "Notes".localized()]
    }
    
    enum Section {
        case profile(rows: [Row])
    
    var rows: [Row] {
        switch self {
        case let .profile(rows):
            return rows
        }
    }
}
    
    enum Row {
        case firstName
        case lastName
        case phoneNumber
        case email
        case birthday
        case height
        case notes
        
        var title: String {
            switch self {
            case .firstName:
                return "First name".localized()
            case .lastName:
                return "Last name".localized()
            case .phoneNumber:
                return "Phone number".localized()
            case .email:
                return "Email"
            case .birthday:
                return "Birthday".localized()
            case .height:
                return "Height".localized()
            case .notes:
                return "Notes".localized()
            }
        }
    }
    
    @objc func datePickerDone() {
        let indexPath = IndexPath.init(row: 4, section: 0)
        let cell = contactTableView.cellForRow(at: indexPath) as! ContactInputCell
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        cell.inputField.text = formatter.string(from: birthdayPicker.date)
       
       self.view.endEditing(true)
     }
    
    @objc func heightPickerDone() {
        let indexPath = IndexPath.init(row: 5, section: 0)
        let cell = contactTableView.cellForRow(at: indexPath) as! ContactInputCell
        
        let height = pickerData[heightPicker.selectedRow(inComponent: 0)] + pickerData[heightPicker.selectedRow(inComponent: 1)] + pickerData[heightPicker.selectedRow(inComponent: 2)]

        cell.inputField.text = height
        self.view.endEditing(true)
    }
    
    @objc func cancelPicker() {
        self.view.endEditing(true)
      }
        
    var sections: [Section] {
        return [ .profile(rows: [.firstName, .lastName, .phoneNumber, .email, .birthday, .height, .notes]) ]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        return section.rows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactInputCell", for: indexPath) as? ContactInputCell else {
            fatalError()
        }
        cell.saveButtonDelegate = self
        
        func showDatePicker() {
            //Formate Date
            birthdayPicker.datePickerMode = .date

           //ToolBar
           let toolbar = UIToolbar();
           toolbar.sizeToFit()
            let doneButton = UIBarButtonItem(title: "Done".localized(), style: .done, target: self, action: #selector(datePickerDone));
            let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let cancelButton = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(cancelPicker));

         toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)

            cell.inputField.inputAccessoryView = toolbar
            cell.inputField.inputView = birthdayPicker

         }
    
        func showHeightPicker() {
            
            let toolbar = UIToolbar();
            toolbar.sizeToFit()
             let doneButton = UIBarButtonItem(title: "Done".localized(), style: .done, target: self, action: #selector(heightPickerDone));
             let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
             let cancelButton = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(cancelPicker));
            
            toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
            
            cell.inputField.inputAccessoryView = toolbar
            cell.inputField.inputView = heightPicker
        }
        
        switch typeOfInteract {
        case .addNew:
            cell.inputLabel.text = labels[indexPath.row]
            cell.inputField.placeholder = labels[indexPath.row]
            
            switch indexPath.row {
            case 4:
                showDatePicker()
            case 5:
                showHeightPicker()
            default: break
                
            }
        case .editExisting:
            guard let contactToEdit = contactToEdit else { fatalError() }
            contactAvatar.setRounded()
            contactAvatar.image = contactToEdit.photo
            cell.inputLabel.text = labels[indexPath.row]
            cell.inputField.placeholder = labels[indexPath.row]
            switch indexPath.row {
            case 0:
                cell.inputField.text = contactToEdit.firstName
            case 1:
                cell.inputField.text = contactToEdit.lastName
            case 2:
                cell.inputField.text = contactToEdit.phoneNumber
            case 3:
                cell.inputField.text = contactToEdit.email
            case 4:
                cell.inputField.text = contactToEdit.birthday
                showDatePicker()
            case 5:
                cell.inputField.text = contactToEdit.height
                showHeightPicker()
            case 6:
                cell.inputField.text = contactToEdit.notes
            default:
                break
            }
        }
        
        return cell
    }
}
//MARK: ImagePicker
extension NewContactController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    enum PhotoSource {
        case photoLibrary
        case camera
    }
//    call actionSheet when AddPhotoButton pressed
    func actionSheetforImagePicker() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take Photo".localized(), style: .default) {_ in
            self.authorisationStatus(accessType: .camera)
        }
        let choosePhotoAction = UIAlertAction(title: "Choose from Photo Library".localized(), style: .default) {_ in
            self.authorisationStatus(accessType: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel, handler: nil)
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(choosePhotoAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }
//    determine access to photoSources
    func authorisationStatus(accessType: PhotoSource) {
        if accessType == .camera {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.openCamera()
                    }
                }
            case .restricted, .denied:
                alertForRestrictedCameraAccess()
            case .authorized:
                self.openCamera()
            default:
                break
            }
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({(status) in
                    if status == PHAuthorizationStatus.authorized {
                        self.openGallery()
                    }
                })
            case .restricted, .denied:
                alertForRestrictedPhotoAccess()
            case .authorized:
                self.openGallery()
            default:
                break
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("\(info)")
        
        let data = convertUIImageToDict(input: info)
        
        if let newImage = data[convertInfoKey(input: UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            let frame = CGRect(x: contactAvatar.center.x, y: contactAvatar.center.y, width: contactAvatar.bounds.size.width, height: contactAvatar.bounds.size.height)
            self.contactAvatar.image = newImage
            self.contactAvatar.frame = frame
            self.contactAvatar.layer.cornerRadius = frame.height / 2
            self.contactAvatar.clipsToBounds = true
            self.addPhotoButton.setTitle("Change Photo".localized(), for: .normal)
            
        }

        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func convertUIImageToDict(input: [UIImagePickerController.InfoKey : Any]) -> [String : Any] {
        Dictionary(uniqueKeysWithValues: input.map({ key, value in (key.rawValue, value)}))
    }
    
    func convertInfoKey(input: UIImagePickerController.InfoKey) -> String {
        input.rawValue
    }
    
}
//method to make any ImageView rounded
extension UIImageView {

    func setRounded() {
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }
}


