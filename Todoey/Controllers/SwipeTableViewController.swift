//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Nadia Seleem on 14/10/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController,SwipeTableViewCellDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 70
        tableView.separatorStyle = .none

    }

    // MARK: - TableView Data Source Methods

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "delete"){
            action, indexPath in
            
            self.updateModel(at: indexPath, do: "delete")
        }
            
        let editAction = SwipeAction(style: .default, title: "edit"){
            action , indexPath in
            self.updateModel(at: indexPath, do: "edit")
        }
        
        
        // customize the action appearance
        editAction.image = UIImage(systemName: "pencil", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .medium))?
            .withTintColor(.systemYellow, renderingMode: .alwaysOriginal)
        editAction.backgroundColor = .darkGray
        deleteAction.image = UIImage(systemName: "trash",
                                     withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .small))?
            .withTintColor(.white, renderingMode: .alwaysOriginal)

 
        return [deleteAction,editAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    func updateModel(at indexPath:IndexPath, do actionName: String){
        
    }
    
}

