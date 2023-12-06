//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var itemArray = [Item]()
    
    var selectedCategory : CategoryEnt? {
        didSet{
            loadItems()
        }
    }
    
    // find the path and set the name of plist file
//    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    // context of CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up a delegate for searchBar
        searchBar.delegate = self
        
        loadItems()
        
    }
    
    //MARK: - Add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        // title of the alert
        let alert = UIAlertController(title: "Add New Todo", message: "", preferredStyle: .alert)
        // title of the action, which is the title of button
        let action = UIAlertAction(title: "Add item", style: .default) { action in
            
            // create instance by DataModel
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            newItem.itemToCate = self.selectedCategory
            
            // add item to the array
            self.itemArray.append(newItem)
            
            // persist the itemArray
            self.saveItems()

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
        
        if searchBar.text?.count == 0 {
            
            // load data
            loadItems()
        }else {
            // create a request
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            
            // do the search
//            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            
            // sort the result by title in ascending order
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            // load data
            loadItems(with: request, predicate: NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!))
        }
        
        // resign first responder
        searchBar.resignFirstResponder()
    }
    
    // be called when text changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count == 0 {
            
            // load data
            loadItems()
        }else {
            // create a request
            let request : NSFetchRequest<Item> = Item.fetchRequest()
            
            // do the search
//            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            
            // sort the result by title in ascending order
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            // load data
            loadItems(with: request, predicate: NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!))
        }
    }
}

//MARK: - FileManager
extension TodoListViewController {
    // Save items in document directory
    func saveItems() {
        
        do {
            try self.context.save()
        }
        catch {
            print("Error saving data to Data Model, \(error)")
        }
        
        tableView.reloadData()
    }
    
    // Load items from datamodel
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "itemToCate.name MATCHES %@", selectedCategory!.name!)
        
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }else{
            request.predicate = categoryPredicate
        }
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Erroe fetching data from context, \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - UITableViewDataSource
extension TodoListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // Must be followed by this order below, otherwise the index does not exist
        // 1. delete the data from context
        context.delete(itemArray[indexPath.row])
        
        // 2. then remove the item from array
        itemArray.remove(at: indexPath.row)
        
        // 3. save
        saveItems()
    }
}


//MARK: - UITableViewDelegate
extension TodoListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // let the cell change back to white after clicking
        tableView.deselectRow(at: indexPath, animated: true)
        
        // checkmark or de-checkmark after clicking
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        // Save the status of checkmarks
        saveItems()
        
    }
}


