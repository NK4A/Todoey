//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Admin on 4/2/19.
//  Copyright © 2019 ozCortex. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
        
    @IBOutlet weak var searchBar: UISearchBar!
    var todoItems : Results<Item>?
    let realm = try! Realm()
    
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let colourHEX = selectedCategory?.colour else {fatalError("Navbar doesn't exist")}
        title = selectedCategory!.name
        updateNavBar(withHexCode: colourHEX)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateNavBar(withHexCode: "1D9BF6")
    }
    //MARK: - Update the Nav Bar
    
    func updateNavBar (withHexCode colourHexCode: String){
        guard let navBar = navigationController?.navigationBar else {fatalError("Navbar doesn't exist")}
        guard  let navBarColur = UIColor(hexString: colourHexCode) else {fatalError("Navbar doesn't exist")}
        navBar.barTintColor = navBarColur
        navBar.tintColor = ContrastColorOf(navBarColur, returnFlat: true)
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColur, returnFlat: true) ]
        searchBar.barTintColor = navBarColur
    }
    
    //MARK - TableView Data methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.accessoryType = (item.done == true) ? .checkmark : .none
            
            if let colour = UIColor(hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(todoItems!.count)){
               cell.backgroundColor = colour
            cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
        
        
        } else{
            cell.textLabel?.text = "No items created yet"
        }
       return cell
    }

    //MARK - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item=todoItems?[indexPath.row]{
            do{
                try realm.write{
                    item.done = !item.done
                }
            }catch{
                print("error saving chek state \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once user clicks add button
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }
                catch{
                    print("error saving category, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
    
    func loadItems(){
     todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
     tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item=self.todoItems?[indexPath.row]{
            do{
                try self.realm.write{
                    self.realm.delete(item)
                }
            }
            catch{
                print("error deleting \(error)")
            }
        }
    }
    
}
//MARK: - Search Bar Extension

extension TodoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }

}
