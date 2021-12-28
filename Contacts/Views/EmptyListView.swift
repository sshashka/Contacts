//
//  EmptyListView.swift
//  Contacts
//
//  Created by Саша Василенко on 19.12.2021.
//

import Foundation
import UIKit

class EmptyListView: UIView {
    
    @IBOutlet weak var addContactButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func commonInit() {
        if let nib = Bundle.main.loadNibNamed("EmptyListView", owner: self),
              let nibView = nib.first as? EmptyListView {
                nibView.frame = bounds
                nibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                addSubview(nibView)
           }
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        presentAddController()
    }
    
    func presentAddController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "NewContactController") as? NewContactController {
            let navVC = UINavigationController.init(rootViewController: vc)
            if let window = self.window, let rootVC = window.rootViewController {
                var currVC = rootVC
                while let presentedVC = currVC.presentedViewController {
                    currVC = presentedVC
                }
                currVC.present(navVC, animated: true, completion: nil)
            }
        }
    }
}
