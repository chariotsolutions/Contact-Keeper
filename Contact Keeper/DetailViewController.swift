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
            addrLineOneLabel?.text = contact.homeAddress.streetAddress
            addrLineTwoLabel?.text = "\(contact.homeAddress.city), \(contact.homeAddress.state) \(contact.homeAddress.zip)"
        } else {
            self.title = "Select A Contact"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
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

