//
//  ShoppingListViewController.swift
//  CoreData-ShoppingList
//
//  Created by Zehra on 22.09.2022.
//

import UIKit
import CoreData

class ShoppingListViewController: UIViewController {

    @IBOutlet weak var shoppingTableView: UITableView!
    
    var shoppingList: [String] = []
    
    let searchControler = UISearchController(searchResultsController: nil)
    
    var filteredItems: [String] = []
    var isSearchBarEmpty: Bool {
        return searchControler.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        return searchControler.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UISearchResultsUpdating will inform your class of any text changes within the UISearchBar.
        searchControler.searchResultsUpdater = self
        // Set the current view to show the results. No obscure your view.
        searchControler.obscuresBackgroundDuringPresentation = false
        searchControler.searchBar.placeholder = "Search Items"
        navigationItem.searchController = searchControler
        //
        definesPresentationContext = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
    
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        fetchItems()
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredItems = shoppingList.filter { (item: String) -> Bool in
            return item.lowercased().contains(searchText.lowercased())
        }
        shoppingTableView.reloadData()
    }

    @IBAction func addBtnClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Add Item", message: "Add items into your cart.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Item"
        }
        
        let saveAction = UIAlertAction(title: "Add", style: .default) { (_) in
            self.shoppingList.removeAll()
            self.createItem(listItem: alert.textFields?.first?.text ?? "Error")
            self.fetchItems()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
}

extension ShoppingListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
}

extension ShoppingListViewController {
    
    func createItem(listItem: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Cart", in: managedContext)!
        let item = NSManagedObject(entity: entity, insertInto: managedContext)
        
        item.setValue(listItem, forKey: "item")
        
        do {
            try managedContext.save()
        } catch let error {
            print("Item can't be created: \(error.localizedDescription)")
        }
    }
    
    func fetchItems() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Cart")
        
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            for item in fetchResults as! [NSManagedObject] {
                shoppingList.append(item.value(forKey: "item") as! String)
            }
            shoppingTableView.reloadData()
        } catch let error {
            print((error.localizedDescription))
        }
    }
}

extension ShoppingListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredItems.count
        } else {
            return shoppingList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item: String
        if isFiltering {
            item = filteredItems[indexPath.row]
        } else {
            item = shoppingList[indexPath.row]
        }
        
        cell.textLabel?.text = item
        return cell
    }
}
