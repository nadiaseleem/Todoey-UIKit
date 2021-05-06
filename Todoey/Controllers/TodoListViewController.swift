//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var items: Results<Item>?
    
    var selectedCategory:Category?{
        didSet{
            loadItemsFromDB()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self // we can make it from main.storyboard as well
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exists.")}

        if let bgColor = UIColor(hexString: selectedCategory?.color ?? "FFFFFF"){
            
            let navBarAppearance = UINavigationBarAppearance()
               navBarAppearance.configureWithOpaqueBackground()
               navBarAppearance.backgroundColor = bgColor
            navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]

               navBar.standardAppearance = navBarAppearance
               navBar.scrollEdgeAppearance = navBarAppearance
            searchBar.barTintColor = bgColor
            searchBar.tintColor = bgColor
            searchBar.searchTextField.backgroundColor = UIColor.white
            navBar.tintColor = UIColor(contrastingBlackOrWhiteColorOn: bgColor, isFlat: true)

        }

        navigationItem.title = selectedCategory?.name
        
        
        
        
    }
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        
        let alertController = UIAlertController(title: "Add New Item", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Add a new item"
        }
        
        alertController.addAction(UIAlertAction(title: "Add", style: .destructive, handler: { (_) in
            
            if let text = alertController.textFields?[0].text {
                if !text.isEmpty{
                    do {
                        try self.realm.write(){
                            let newItem = Item()
                            newItem.title = text
                            self.selectedCategory?.items.append(newItem) //this adds the item to the DB
//                            self.realm.add(newItem)//we can ignore the add method
                            
                        }
                        
                        
                    } catch  {
                        print("Error saving new item, =>\(error.localizedDescription)")
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in
            
        }))
        
        present(alertController, animated: true, completion: nil)
        
    }
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.row]{
            
            if let color = selectedCategory?.color{
                

                cell.backgroundColor = UIColor(hexString: color)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(items!.count))
                cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn:cell.backgroundColor ?? UIColor.white, isFlat:true)

            
                
                cell.textLabel?.text = item.title
                cell.textLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .heavy)
//                cell.accessoryType = item.done ? .checkmark : .none
                    let imageView: UIImageView = UIImageView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
                imageView.image = item.done ? UIImage(named: "checkmark") : UIImage(named: "no checkmark")

                imageView.contentMode = .scaleAspectFit

                cell.accessoryView = imageView
//                cell.textLabel?.presentAsDone(item.done)
            }
            
        
            
        }
//             UIColor(complementaryFlatColorOf: UIColor(hexString: "853DAE")!).lighten(byPercentage: 0.2*CGFloat(self.multiplier/10))!
        
        
        return cell
    }
    
    
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = items?[indexPath.row]{
            do {
                try realm.write(){
                    item.done = !item.done
                }
            } catch  {
                print("Error updating the done value in an item, =>\(error.localizedDescription)")
                
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.searchBar.resignFirstResponder()
            }

        }
    }

    
    // MARK: - TableView Data Minipulation Methods
    
    
    func loadItemsFromDB(){
        
        
        items = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
 override func updateModel(at indexPath: IndexPath, do actionName:String) {
    if actionName == "delete"{
    if let itemForDeletion = items?[indexPath.row]{
            do {
                try realm.write()
                {
                    realm.delete(itemForDeletion)
                }
                
            } catch  {
                print("Error trying to delete a todo item, => \(error.localizedDescription)")
            }
        }
    }else if actionName == "edit"{
        
        let alert = UIAlertController(title: "Edit item name", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) in
            textField.text = self.items?[indexPath.row].title
        })
        alert.addAction(UIAlertAction(title: "Update", style: .destructive, handler: { (updateAction) in
            do{
                try self.realm.write(){
                    self.items?[indexPath.row].title = alert.textFields!.first!.text!
                }

            }catch{
                print("error in updating item title, => \(error.localizedDescription)")
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

//MARK: - UISearchBarDelegate Methods
extension TodoListViewController : UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let searchBarText = searchBar.text , !searchBarText.isEmpty else{
            return
        }
        
        items = items?.filter("title contains[cd] %@", searchBarText).sorted(byKeyPath: "dateCreated", ascending: true)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItemsFromDB()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        
    }
    
    
    
}

////MARK: - UILabel Methods
//
//extension UILabel {
//
//    func presentAsDone(_ isStrikeThrough:Bool) {
//        if isStrikeThrough {
//            if let lblText = self.text {
//                let attributeString =  NSMutableAttributedString(string: lblText)
//                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
//                attributeString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.black, range: NSMakeRange(0, attributeString.length))
//                self.font = UIFont.systemFont(ofSize: 16.0)
//                self.attributedText = attributeString
//
//            }
//        } else {
//            if let attributedStringText = self.attributedText {
//                let txt = attributedStringText.string
//                self.attributedText = nil
//                self.text = txt
//                return
//            }
//        }
//    }
//}
