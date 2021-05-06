//
//  Item.swift
//  Todoey
//
//  Created by Nadia Seleem on 12/10/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object{
    
    @objc dynamic var title = ""
    @objc dynamic var done = false
    @objc dynamic var dateCreated = Date()
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
