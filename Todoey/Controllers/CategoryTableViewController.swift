//
//  CategoryTableViewController.swift
//  Todoey
//
//  Created by Nadia Seleem on 08/10/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    var categories: Results <Category>?
    var index = 1
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategoriesFromDB()
        colorArray.append(FlatOrangeDark())
    }
    
    var colorArray = ColorSchemeOf(ColorScheme.complementary, color: FlatBrown() .lighten(byPercentage: 0.2) ?? FlatBrown() , isFlatScheme: true)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exists.")}

        let navBarAppearance = UINavigationBarAppearance()
              navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(patternImage: UIImage(named: "stars2")!)
           navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
           navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]

              navBar.standardAppearance = navBarAppearance
              navBar.scrollEdgeAppearance = navBarAppearance
        navBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: FlatSkyBlue(), isFlat: true)
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Add New Category", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Add a new category"
        }
        alertController.addAction(UIAlertAction(title: "Add", style: .destructive, handler: { (_) in
            
            if let text = alertController.textFields?.last?.text {
                if !text.isEmpty{
                    do {
                        try self.realm.write(){
                            let newCategory = Category()
                            newCategory.name = text
                            newCategory.color = self.colorArray[self.index]
//                                .lighten(byPercentage: 0.2)!
                                .hexValue()
                            
                            
                            self.realm.add(newCategory)// must have the add method
                            self.index += 1
                            if self.index == self.colorArray.count{
                                self.index = 0
                            }
                        }
                    } catch  {
                        print("Error saving new category, =>\(error.localizedDescription)")
                    }
                   DispatchQueue.main.async {
                       self.tableView.reloadData()
                   }
                }
            }
            
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    // MARK: - TableView Data Source Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UIColor(hexString: categories?[indexPath.row].color ?? "FFFFFF")
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn:cell.backgroundColor ?? UIColor.white, isFlat:true)
//        cell.backgroundView = UIImageView(image: UIImage(named: "folder"))
        cell.textLabel?.text = categories?[indexPath.row].name
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0, weight: .heavy)
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            //Bring's sender's opacity back up to fully opaque.
            cell?.alpha = 1.0
            self.performSegue(withIdentifier: "goToItems", sender: self)

        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems"{
            let destinationVC = segue.destination as! TodoListViewController
            if let indexPath = tableView.indexPathForSelectedRow{
                destinationVC.selectedCategory = categories?[indexPath.row]
            }
            
        }
    }
    

    // MARK: - TableView Data Minipulation Methods

    
    fileprivate func loadCategoriesFromDB(){
        categories = realm.objects(Category.self)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    //delete category on swipe
    override func updateModel(at indexPath: IndexPath, do actionName:String) {
        if actionName == "delete"{
        if let categoryForDeletion = self.categories?[indexPath.row]{
            do {
                try self.realm.write{
                    self.realm.delete(categoryForDeletion.items)
                    self.realm.delete(categoryForDeletion)
                }
            } catch  {
                print("Error in deleting an item, => \(error.localizedDescription)")
            }
            
            }
        }else if actionName == "edit"{
            let alert = UIAlertController(title: "Edit category name", message: "", preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: { (textField) in
                
                textField.text = self.categories?[indexPath.row].name
            })
            alert.addAction(UIAlertAction(title: "Update", style: .destructive, handler: { (updateAction) in
                do{
                    try self.realm.write(){
                        self.categories?[indexPath.row].name = alert.textFields!.first!.text!
                    }

                }catch{
                    print("error in updating category name, => \(error.localizedDescription)")
                }

                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
                
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alert, animated: true)
            
        }
    }
    
}

