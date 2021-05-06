//
//  Category.swift
//  Todoey
//
//  Created by Nadia Seleem on 12/10/2020.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    
    @objc dynamic var name = ""
    @objc dynamic var color = ""
    var items = List<Item>()
}
