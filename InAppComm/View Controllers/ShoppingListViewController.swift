//
//  ShoppingListViewController.swift
//  InAppComm
//
//  Created by Gabriel Theodoropoulos.
//  Copyright © 2019 Appcoda. All rights reserved.
//

import UIKit

class ShoppingListViewController: UIViewController {

    // MARK: - IBOutlet Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Properties
    
    var shoppingList = ShoppingList()
    
    var selectedItemIndex: Int?
    
    
    
    
    // MARK: - View Init Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTableView()
        selectedItemIndex = nil
        
        if let name = shoppingList.name {
            navigationItem.title = name
        }
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isMovingFromParent {
            updateParent()
        }
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "idShowEditItemViewControllerSegue" {
                if let editItemVC = segue.destination as? EditItemViewController {
                    
                    editItemVC.delegate = self
                    
                    if let index = selectedItemIndex {
                        editItemVC.editedItem = shoppingList.items[index]
                    }
                    
                }
            }
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
        tableView.register(UINib(nibName: "ShoppingListItemCell", bundle: nil), forCellReuseIdentifier: "idShoppingListItemCell")
    }
 
    
    
    
    func updateParent() {
        if let id = shoppingList.id {
            NotificationCenter.default.post(name: .didUpdateShoppingList, object: nil, userInfo: ["id": id, "items": shoppingList.items])
        } else {
            if shoppingList.items.count > 0 {
                NotificationCenter.default.post(name: .didCreateShoppingList, object: shoppingList.items, userInfo: nil)
            }
        }
    }
    
    
    
    
    // MARK: - IBAction Methods
    
    @IBAction func addItem(_ sender: Any) {
        performSegue(withIdentifier: "idShowEditItemViewControllerSegue", sender: self)
    }
    
    
}




// MARK: - UITableViewDelegate, UITableViewDataSource
extension ShoppingListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "idShoppingListItemCell", for: indexPath) as? ShoppingListItemCell {
            cell.label.text = shoppingList.items[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isSelected = false
        
        selectedItemIndex = indexPath.row
        performSegue(withIdentifier: "idShowEditItemViewControllerSegue", sender: self)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68.0
    }
}




extension ShoppingListViewController: EditItemViewControllerDelegate {
    func shouldAdd(item: String) {
        shoppingList.items.append(item)
        tableView.reloadData()
    }
    
    
    func isItemPresent(item: String) -> Bool {
        if let _ = shoppingList.items.firstIndex(of: item) {
            return true
        } else {
            return false
        }
    }
    
    
    func shouldReplace(item: String, withItem newItem: String) {
        if let index = shoppingList.items.firstIndex(of: item) {
            shoppingList.items[index] = newItem
            tableView.reloadData()
        }
    }
    
    
    func shouldRemove(item: String) {
        if let index = shoppingList.items.firstIndex(of: item) {
            shoppingList.items.remove(at: index)
            tableView.reloadData()
        }
    }
}
