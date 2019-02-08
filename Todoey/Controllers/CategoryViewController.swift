//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Admin on 6/2/19.
//  Copyright © 2019 ozCortex. All rights reserved.
//

import UIKit
import RealmSwift


class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()

    var categoryArray : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories added yet"
        return cell
    }
    
    //Mark: - Data Manipulation Methods
    func save(category: Category){
        do{
            try realm.write {
                realm.add(category)
            }
        }
        catch{
            print("error saving category, \(error)")
        }
        tableView.reloadData()
    }
    override func updateModel(at indexPath: IndexPath) {
            if let category=self.categoryArray?[indexPath.row]{
                do{
                    try self.realm.write{
                        self.realm.delete(category)
                    }
                }
                catch{
                    print("error deleting \(error)")
                }
            }
    }
    
    func loadCategories(){
        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //what will happen once user clicks add button
            let newCategory = Category()
            newCategory.name = textField.text!
            self.save(category: newCategory)
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new category"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
        
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
}

//extension CategoryViewController: SwipeTableViewCellDelegate{
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        guard orientation == .right else { return nil }
//        
//        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
//            // handle action by updating model with deletion
//            
//            if let category=self.categoryArray?[indexPath.row]{
//                do{
//                    try self.realm.write{
//                        self.realm.delete(category)
//                    }
//                }
//                catch{
//                    print("error deleting \(error)")
//                }
//            }
//        }
//        // customize the action appearance
//        deleteAction.image = UIImage(named: "delete")
//        return [deleteAction]
//    }
//    
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//        options.expansionStyle = .destructive
//        return options
//    }
//}
