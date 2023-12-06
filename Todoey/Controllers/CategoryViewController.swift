//
//  CategoryViewController.swift
//  Todoey
//
//  Created by 郭梓榕 on 2/12/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    // create itemarray
    var categories = [CategoryEnt]()
    

    // context of CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories()
    }

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Item", message: "This is an alert.", preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "name of item"
        }
        
        alert.addAction(UIAlertAction(title: "Add item", style: .default) {action in
            
            if let textField = alert.textFields?.first, let text = textField.text {
                // create an item
                let cate = CategoryEnt(context: self.context)
                cate.name = text
                
                // append the item to itemArray
                self.categories.append(cate)
    
                // save items after appending
                self.saveCategories()
            }
        })
        
        self.present(alert, animated: true, completion: nil)

    }
}

//MARK: - Core data
extension CategoryViewController {
    func loadCategories(with request: NSFetchRequest<CategoryEnt> = CategoryEnt.fetchRequest() ) {
        do {
            categories = try context.fetch(request)
        }
        catch {
            print("Load categories error: \(error)")
        }
        
        tableView.reloadData()
    }
    func saveCategories() {
        do {
            try context.save()
        }
        catch {
            print("Save categories error: \(error)")
        }
        
        tableView.reloadData()
    }
}

//MARK: - Table view delegate
extension CategoryViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // segua to destination
        let destinationVC = segue.destination as! TodoListViewController
        
        // pass the element to destination VC
        if let indexPath = tableView.indexPathForSelectedRow {
            
            destinationVC.selectedCategory = categories[indexPath.row]
            
        }
    }
}

// MARK: - Table view data source
extension CategoryViewController {
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return itemArray.count
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // set up reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CateItemCell", for: indexPath)
        
        // set title for cell
        cell.textLabel?.text = categories[indexPath.row].name
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        context.delete(categories[indexPath.row])
        
        categories.remove(at: indexPath.row)
        
        saveCategories()
    }
}