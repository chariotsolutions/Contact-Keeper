//
//  MasterViewController.swift
//  Contact Keeper
//
//  Created by Steven Beyers on 6/2/17.
//  Copyright © 2017 Chariot. All rights reserved.
//

import UIKit
import Contacts
import MobileCoreServices

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var contacts = Contact.generateContacts()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        tableView.dropDelegate = self
        tableView.dragDelegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let contact = contacts[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.contact = contact
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)

        if let contactCell = cell as? ContactTableViewCell {
            let contact = contacts[indexPath.row]
        
            contactCell.imageView?.image = contact.image
            contactCell.contactName.text = contact.fullName
            contactCell.contactPhoneNumber.text = contact.phoneNumber
        }
        
        
        return cell
    }
}

extension MasterViewController: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let contact = contacts[indexPath.row]
        let contactCopy = contact.cnContact()
        
        let data = try? CNContactVCardSerialization.data(with: [contactCopy])
        let itemProvider = NSItemProvider()
        
        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypeVCard as String, visibility: .all) { completion in
            completion(data, nil)
            return nil
        }
        
        // set the table view as the context so that the drop delegate methods can determine when to reject this
        session.localContext = tableView
        
        return [UIDragItem(itemProvider: itemProvider)]
    }
    
}

extension MasterViewController: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: [kUTTypeVCard as String]) && session.items.count == 1
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if let sourceTable = session.localDragSession?.localContext as? UITableView, sourceTable == tableView {
            return UITableViewDropProposal(operation: .forbidden)
        }
        
        return UITableViewDropProposal(dropOperation: .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        for item: UIDragItem in coordinator.session.items {
            item.itemProvider.loadDataRepresentation(forTypeIdentifier: kUTTypeVCard as String, completionHandler: { (data, error) in
                if let data = data {
                    do {
                        let newContacts = try CNContactVCardSerialization.contacts(with: data)
                        var indexPaths = [IndexPath]()
                        
                        for (index, contact) in newContacts.enumerated() {
                            let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                            indexPaths.append(indexPath)
                            
                            let newContact = Contact(contact: contact)
                            self.contacts.insert(newContact, at: indexPath.row)
                        }
                        
                        DispatchQueue.main.async {[weak self]() in
                            self?.tableView.insertRows(at: indexPaths, with: .automatic)
                        }
                    } catch {
                        // an error occurred
                    }
                }
            })
        }
    }
    
}

