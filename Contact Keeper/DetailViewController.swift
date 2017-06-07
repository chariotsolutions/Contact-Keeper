//
//  DetailViewController.swift
//  Contact Keeper
//
//  Created by Steven Beyers on 6/2/17.
//  Copyright © 2017 Chariot. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var addrLineOneLabel: UILabel!
    @IBOutlet weak var addrLineTwoLabel: UILabel!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var sendTextButton: UIButton!
    @IBOutlet weak var sendEmailButton: UIButton!

    @IBOutlet var hidableViews: [UIView]!
    
    func configureView() {
        // Update the user interface for the detail item.
        let shouldHide = contact == nil
        _ = hidableViews?.map { $0.isHidden = shouldHide }
        
        if let contact = contact {
            self.title = contact.firstName
            
            imageView?.image = contact.image
            nameLabel?.text = contact.fullName
            phoneNumberLabel?.text = contact.phoneNumber
            emailLabel?.text = contact.emailAddress
            
            if let homeAddress = contact.homeAddress {
                addrLineOneLabel?.text = homeAddress.streetAddress
                addrLineTwoLabel?.text = "\(homeAddress.city), \(homeAddress.state) \(homeAddress.zip)"
            } else {
                addrLineOneLabel.text = ""
                addrLineTwoLabel.text = ""
            }
        } else {
            self.title = "Select A Contact"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        
        let dropInteraction = UIDropInteraction(delegate: self)
        imageView.addInteraction(dropInteraction)
        imageView.isUserInteractionEnabled = true
        
        let dragInteraction = UIDragInteraction(delegate: self)
        imageView.addInteraction(dragInteraction)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var contact: Contact? {
        didSet {
            // Update the view.
            configureView()
        }
    }

    @IBAction func callPresed(_ sender: Any) {
        print("Call \(contact?.firstName ?? "contact")")
    }

    @IBAction func sendTextPressed(_ sender: Any) {
        print("Send text to \(contact?.firstName ?? "contact")")
    }
    
    @IBAction func sendEmailPressed(_ sender: Any) {
        print("Send email to \(contact?.firstName ?? "contact")")
    }
    
}

extension DetailViewController: UIDragInteractionDelegate {
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        guard let image = imageView.image else {
            return []
        }
        
        let provider = NSItemProvider(object: image)
        let item = UIDragItem(itemProvider: provider)
        item.localObject = image
        
        return [item]
    }
}

extension DetailViewController: UIDropInteractionDelegate {
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self) && session.items.count == 1
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let dropLocation = session.location(in: view)
        
        let operation: UIDropOperation
        
        if imageView.frame.contains(dropLocation) {
            operation = .copy
        } else {
            operation = .cancel
        }
        
        return UIDropProposal(operation: operation)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { [weak self]imageItems in
            let images = imageItems as! [UIImage]
            self?.imageView.image = images.first
            self?.contact?.image = images.first
        }
    }
    
}
