//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class TodoListViewController: UITableViewController {

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
        
//        loadItems()
        
    }
    
//MARK: - Add new items
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
            // create instance by DataModel
//            let newItem = Item()
//            newItem.title = textField.text!
//            newItem.done = false
//            newItem.itemToCate = self.selectedCategory
            
            // add item to the array
//            self.itemArray.append(newItem)
            
            // persist the itemArray
//            self.save(item: newItem)

        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true)
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
//            // create a request
//            let request : NSFetchRequest<Item> = Item.fetchRequest()
//            
//            // do the search
////            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
//            
//            // sort the result by title in ascending order
//            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
//            
//            // load data
//            loadItems(with: request, predicate: NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!))
        }
    }
}

//MARK: - FileManager
extension TodoListViewController {
    // Save items in document directory
//    func saveItems() {
//        
//        do {
//            try self.context.save()
//        }
//        catch {
//            print("Error saving data to Data Model, \(error)")
//        }
//        
//        tableView.reloadData()
//    }
    
    // Load items from datamodel
//    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
//        
//        let categoryPredicate = NSPredicate(format: "itemToCate.name MATCHES %@", selectedCategory!.name!)
//        
//        
//        if let additionalPredicate = predicate {
//            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//        }else{
//            request.predicate = categoryPredicate
//        }
//        
//        do {
//            itemArray = try context.fetch(request)
//        } catch {
//            print("Erroe fetching data from context, \(error)")
//        }
//        
//        tableView.reloadData()
//    }
    
    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = itemArray?[indexPath.row] {
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
            
        }else{
            cell.textLabel?.text = "No items Added"
        }

        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
//        // Must be followed by this order below, otherwise the index does not exist
//        // 1. delete the data from context
//        context.delete(itemArray[indexPath.row])
//        
//        // 2. then remove the item from array
//        itemArray.remove(at: indexPath.row)
//        
//        // 3. save
//        saveItems()
        
        if let item = itemArray?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting item from itemArray, \(error)")
            }
        }
        
        tableView.reloadData()
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
        
        // let the cell change back to white after clicking
//        tableView.deselectRow(at: indexPath, animated: true)
        
//        // checkmark or de-checkmark after clicking
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
//        
//        // Save the status of checkmarks
//        saveItems()
        
    }
}


