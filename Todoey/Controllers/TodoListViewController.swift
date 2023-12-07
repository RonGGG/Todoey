//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
//import CoreData
import RealmSwift

class TodoListViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
//    var itemArray = [Item]()
    var itemArray : Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory : Category? {
        didSet{
//            loadItems()
            self.load()
        }
    }
    
    // find the path and set the name of plist file
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    // context of CoreData
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up a delegate for searchBar
        searchBar.delegate = self
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        // title of the alert
        let alert = UIAlertController(title: "Add New Todo", message: "", preferredStyle: .alert)
        // title of the action, which is the title of button
        let action = UIAlertAction(title: "Add item", style: .default) { action in
            
            if let currentCate = self.selectedCategory {
                
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.done = false
                        newItem.date = Date()
                        currentCate.items.append(newItem)
                    }
                } catch {
                    print("Add item error, \(error)")
                }
            }
            
            self.tableView.reloadData()

        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    override func updateModel(at indexPath: IndexPath) {
//        print("update in todo")
        if let item = self.itemArray?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting item from itemArray, \(error)")
            }
        }
        
    }
}

//MARK: - UISearchBarDelegate
extension TodoListViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        // resign first responder
        searchBar.resignFirstResponder()
    }
    
    // be called when text changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0 {
            
            // load data
            self.load()
        }else {
            
            itemArray = selectedCategory?.items.filter("title CONTAINS[cd] %@", searchText).sorted(byKeyPath: "title", ascending: true)
            
            tableView.reloadData()
        }
    }
}

//MARK: - FileManager
extension TodoListViewController {
    
    func load() {
        itemArray = selectedCategory?.items.sorted(byKeyPath: "date", ascending: true)
        tableView.reloadData()
    }
}

//MARK: - UITableViewDataSource
extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
            
        }else{
            cell.textLabel?.text = "No items Added"
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension TodoListViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemArray?[indexPath.row] {
            
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch  {
                print("Error changing item status, \(error)")
            }
        }
        
        tableView.reloadData()
    }
    
}
