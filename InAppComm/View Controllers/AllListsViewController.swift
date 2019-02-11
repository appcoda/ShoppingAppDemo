//
//  AllListsViewController.swift
//  InAppComm
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class AllListsViewController: UIViewController {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    // MARK: - Properties
    
    var listManager = ShoppingListsManager()
    
    var selectedListIndex: Int?
    
    var renameListView: RenameListView?
    
    
    
    // MARK: - View Init Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidCreateShoppingList(notification:)), name: .didCreateShoppingList, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDidUpdateShoppingList(notification:)), name: .didUpdateShoppingList, object: nil)
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTableView()
        selectedListIndex = nil
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let identifier = segue.identifier {
            if identifier == "idEditShoppingListSegue" {
                if let shoppingListVC = segue.destination as? ShoppingListViewController {
                    if let index = selectedListIndex {
                        shoppingListVC.shoppingList.id = listManager.lists[index].id
                        shoppingListVC.shoppingList.name = listManager.lists[index].name
                        shoppingListVC.shoppingList.items = listManager.lists[index].items
                    }
                }
            }
        }
    }
    

    
    // MARK: - IBAction Methods
    
    @IBAction func createNewList(_ sender: Any) {
        if renameListView == nil {
            performSegue(withIdentifier: "idEditShoppingListSegue", sender: self)
        }
    }
    
    
    
    // MARK: - Custom Methods
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = UIColor.clear
        tableView.isScrollEnabled = true
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: "ShoppingListCell", bundle: nil), forCellReuseIdentifier: "idShoppingListCell")
    }
    
    
    
    func showRenameListView() {
        if renameListView == nil {
            renameListView = RenameListView(frame: CGRect.zero)
            renameListView?.alpha = 0.0
            self.view.addSubview(renameListView!)
            renameListView?.translatesAutoresizingMaskIntoConstraints = false
            renameListView?.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            renameListView?.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
            renameListView?.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            renameListView?.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            
            UIView.animate(withDuration: 0.4, animations: {
                self.renameListView?.alpha = 1.0
            }) { (finished) in
                if finished {
                    self.renameListView?.textField.becomeFirstResponder()
                }
            }
            
            
            
            // Add action handlers here!
            
            renameListView?.handleCancelRenaming {
                self.renameListView?.removeFromSuperview()
                self.renameListView = nil
            }
         
            
            
            renameListView?.handleRenaming(handler: { (listName) in
                if let index = self.selectedListIndex {
                    self.listManager.lists[index].name = listName
                    self.tableView.reloadData()
                    self.renameListView?.removeFromSuperview()
                    self.renameListView = nil
                }
            })
            
        }
    }
    
    
    
    @objc func handleDidCreateShoppingList(notification: Notification) {
        if let items = notification.object as? [String] {
            let newShoppingList = ShoppingList(id: listManager.getNextListID(),
                                               name: "Shopping List",
                                               editTimestamp: Date.timeIntervalSinceReferenceDate,
                                               items: items)
            
            listManager.add(list: newShoppingList)
            tableView.reloadData()
        }
    }
    
    
    
    @objc func handleDidUpdateShoppingList(notification: Notification) {
        if let userInfo = notification.userInfo {
            if let id = userInfo["id"] as? Int, let items = userInfo["items"] as? [String] {
                listManager.updateItems(inListWithID: id, items: items)
                tableView.reloadData()
            }
        }
    }
    
}






// MARK: - UITableViewDelegate, UITableViewDataSource
extension AllListsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listManager.lists.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "idShoppingListCell", for: indexPath) as? ShoppingListCell {
            if let name = listManager.lists[indexPath.row].name {
                let itemsLiteral = (listManager.getItemsCount(atIndex: indexPath.row) == 1) ? "item" : "items"
                cell.textLabel?.text = "\(name) (\(listManager.getItemsCount(atIndex: indexPath.row)) \(itemsLiteral))"
            }
            
            if let timestamp = listManager.getFormattedEditedTimestamp(listIndex: indexPath.row) {
                cell.detailTextLabel?.text = "Edited on \(timestamp)"
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        
        selectedListIndex = indexPath.row
        performSegue(withIdentifier: "idEditShoppingListSegue", sender: self)
    }
    
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, handler) in
            let alert = UIAlertController(title: "Delete Shopping List", message: "Are you sure you want to delete it?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                self.listManager.lists.remove(at: indexPath.row)
                self.tableView.reloadData()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        
        let renameAction = UIContextualAction(style: .normal, title: "Rename") { (action, view, handler) in
            DispatchQueue.main.async { [unowned self] in
                self.selectedListIndex = indexPath.row
                self.showRenameListView()
            }
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, renameAction])
        config.performsFirstActionWithFullSwipe = false
        
        return config
        
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
}

