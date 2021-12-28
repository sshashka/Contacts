//
//  ContactInputCell.swift
//  Contacts
//
//  Created by Саша Василенко on 20.12.2021.
//
import UIKit

class ContactInputCell: UITableViewCell {
    
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    private var datePicker: UIDatePicker?
    
    
    var saveButtonDelegate: SaveButtonDelegate?
    let border = CALayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        inputField.delegate = self
        inputField.layer.addSublayer(border)
        errorLabel.isHidden = true
//        configDatePicker()
        
//        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(ContactInputCell.cellTapped(gestureRecogniser:)))
//
//        self.addGestureRecognizer(tapGestureRecogniser)
    }
    
//    func configDatePicker() {
//        datePicker = UIDatePicker()
//        datePicker?.datePickerMode = .date
//        datePicker?.addTarget(self, action: #selector(ContactInputCell.dateChanged(datePicker: )), for: .valueChanged)
//        inputField.inputView = datePicker
//    }
//
//    @objc func dateChanged(datePicker: UIDatePicker) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yyyy"
//
//        inputField.text = dateFormatter.string(from: datePicker.date)
//        inputField.inputView?.endEditing(true)
//    }
//
//    @objc func cellTapped(gestureRecogniser: UITapGestureRecognizer) {
//        self.endEditing(true)
//    }
    
}

extension ContactInputCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.inputLabel.textColor = .systemBlue
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        self.inputLabel.textColor = .black
        guard let inputText = inputField.text else { return }
        
        if inputText.count > 0 {
            self.saveButtonDelegate?.enableSaveButton()
        } else {
            self.saveButtonDelegate?.disableSaveButton()
        }
        
        if self.inputLabel.text == "First name".localized() {
            let whiteSpace = !inputField.isNotWhiteSpace()
            let moreThanMax = inputField.isMoreThanMaxLength()
            if inputField.text != nil  {
                if whiteSpace {
                    setWhiteSpaceError()
                }
                if moreThanMax {
                    setMoreThanMaxError()
                }
                if !whiteSpace && !moreThanMax {
                    removeError()
                }
            } else {
            removeError()
        }
    }
        
        if self.inputLabel.text == "Last name".localized() {
            let whiteSpace = !inputField.isNotWhiteSpace()
            let moreThanMax = inputField.isMoreThanMaxLength()
            if inputField.text != nil  {
                if whiteSpace {
                    setWhiteSpaceError()
                }
                if moreThanMax {
                    setMoreThanMaxError()
                }
                if !whiteSpace && !moreThanMax {
                    removeError()
                }
            } else {
            removeError()
        }
    }
        
        if self.inputLabel.text == "Phone number".localized() {
            if inputField.text != nil {
                if inputField.phoneNumberIsValid() == false {
                    setPhoneNumberError()
                } else {
                    removeError()
                }
            } else {
                removeError()
            }
        }
        if self.inputLabel.text == "Email" {
            if inputField.text != nil {
                if inputField.emailIsValid() == false {
                    setEmailError()
                } else {
                    removeError()
                }
            } else {
                removeError()
            }
        }
    }
    
    func updateBorder(textField: UITextField, color: UIColor, width: CGFloat) -> Void {
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0.0, y: textField.frame.size.height + 8, width: textField.frame.size.width, height: width);
    }
    
    func setWhiteSpaceError() {
        inputField.isError(baseColor: UIColor.red.cgColor, numberOfShakes: 2, revert: false)
        errorLabel.text = "Field can not contain only spaces".localized()
        errorLabel.isHidden = false
        updateBorder(textField: inputField, color: UIColor.red, width: 2.0)
        self.saveButtonDelegate?.disableSaveButton()
    }
    
    func setMoreThanMaxError() {
        inputField.isError(baseColor: UIColor.red.cgColor, numberOfShakes: 2, revert: false)
        errorLabel.text = "Max length is 30 characters".localized()
        errorLabel.isHidden = false
        updateBorder(textField: inputField, color: UIColor.red, width: 2.0)
        self.saveButtonDelegate?.disableSaveButton()
    }
    
    func setEmailError() {
        inputField.isError(baseColor: UIColor.red.cgColor, numberOfShakes: 2, revert: false)
        errorLabel.text = "Wrong email format".localized()
        errorLabel.isHidden = false
        border.isHidden = false
        updateBorder(textField: inputField, color: UIColor.red, width: 2.0)
        self.saveButtonDelegate?.disableSaveButton()
    }
    
    func setPhoneNumberError() {
        inputField.isError(baseColor: UIColor.red.cgColor, numberOfShakes: 2, revert: false)
        errorLabel.text  = "Wrong number format".localized()
        errorLabel.isHidden = false
        border.isHidden = false
        updateBorder(textField: inputField, color: UIColor.red, width: 2.0)
        self.saveButtonDelegate?.disableSaveButton()
    }
    
    func removeError() {
        errorLabel.isHidden = true
        updateBorder(textField: inputField, color: UIColor.white, width: 2.0)
    }
}


extension UITextField {
    
    func phoneNumberIsValid() -> Bool {
        var numCounter = 0
        if self.text!.first == "+" {
            for char in self.text!.substring(fromIndex: 1) {
                if char.isNumber {
                    numCounter += 1
                }
            }
        }
        
        if self.text!.isEmpty {
            return true
        }
        
        return numCounter == (self.text!.count - 1)
    }
    
    func emailIsValid() -> Bool {
        let __firstpart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let __serverpart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let __emailRegex = __firstpart + "@" + __serverpart + "[A-Za-z]{2,8}"
        let __emailPredicate = NSPredicate(format: "SELF MATCHES %@", __emailRegex)
        
        if self.text!.isEmpty {
            return true
        }
        
        return __emailPredicate.evaluate(with: self.text)
    }
    
    func isError(baseColor: CGColor, numberOfShakes shakes: Float, revert: Bool) {
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "shadowColor")
        animation.fromValue = baseColor
        animation.toValue = UIColor.red.cgColor
        animation.duration = 0.4
        if revert { animation.autoreverses = true } else { animation.autoreverses = false }
        self.layer.add(animation, forKey: "")

        let shake: CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.07
        shake.repeatCount = shakes
        if revert { shake.autoreverses = true  } else { shake.autoreverses = false }
        shake.fromValue = NSValue(cgPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        shake.toValue = NSValue(cgPoint: CGPoint(x: self.center.x + 10, y: self.center.y))
        self.layer.add(shake, forKey: "position")
    }
    
    func isNotWhiteSpace() -> Bool {
        if self.text!.isEmpty {
            return true
        }
        return !self.text!.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func isMoreThanMaxLength() -> Bool {
        return self.text!.count > 30
    }
}

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
