//
//  ViewController.swift
//  ContactEdit
//
//  Created by Roman Kozak on 4/28/18.
//  Copyright © 2018 Roman Kozak. All rights reserved.
//

import UIKit
import Contacts

struct ActionItem {
    let cellId: String
    let title: String
    let prepareCellAction: ((UITableViewCell) ->Void)?
    let handleInputAction: ((Int) -> Void)?
}

class LayoutCell : UITableViewCell {
    var actionItem: ActionItem? {
        didSet {
            textLabel?.text = actionItem?.title
            actionItem?.prepareCellAction?(self)
        }
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView?
    
    var tableLayout: [[ActionItem]]? = nil
    var storeManager: StoreManager? {
        didSet {
            tableView?.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableLayout = [
            [
                ActionItem(cellId: "SummaryCell",
                           title: "Number of all contacts",
                           prepareCellAction: { (cell: UITableViewCell) in
                                cell.detailTextLabel?.text = String(self.storeManager?.allContacts.count ?? 0)
                           },
                           handleInputAction: nil)
            ],
            [
                ActionItem(cellId: "ActionCell",
                           title: "Generate contacts",
                           prepareCellAction: nil,
                           handleInputAction: { self.storeManager?.generateContacts($0) }),
                ActionItem(cellId: "ActionCell",
                           title: "Remove random contacts",
                           prepareCellAction: nil,
                           handleInputAction: { self.storeManager?.removeRandomContacts($0) })
            ]
        ]
        
        //
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contactsDidChange),
            name: NSNotification.Name.CNContactStoreDidChange,
            object: nil)
        
        
        //
        let store = CNContactStore()
        store.requestAccess(for: CNEntityType.contacts) { (res, error) in
            guard res == true, error == nil else {
                preconditionFailure("No access to contacts")
            }
            DispatchQueue.main.async {
                self.storeManager = StoreManager(with: store)
            }
        }
    }

    //////
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableLayout?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableLayout?[section].count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let actionItem = tableLayout?[indexPath.section][indexPath.row],
            let cell = tableView.dequeueReusableCell(withIdentifier: actionItem.cellId) as? LayoutCell
            else
        {
            return UITableViewCell()
        }
        
        cell.actionItem = actionItem
        return cell
    }
    
    //////
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async { tableView.deselectRow(at: indexPath, animated: true)     }
    }
    
    //////
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ActionSegue",
            let actionVC = segue.destination as? InputViewController,
            let cell = sender as? LayoutCell
        {
            actionVC.actionItem = cell.actionItem
        }
    }
    
    //////
    
    @objc func contactsDidChange() {
        reloadData()
    }
    
    @IBAction func onRefresh() {
        reloadData()
    }
    
    //////
    
    func reloadData() {
        storeManager?.refreshAllContacts()
        tableView?.reloadData()
    }
}

