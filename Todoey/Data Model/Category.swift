//
//  Category.swift
//  Todoey
//
//  Created by Admin on 7/2/19.
//  Copyright © 2019 ozCortex. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object{
    @objc dynamic var name : String = ""
    @objc dynamic var colour : String = ""
    let items = List<Item>()
}
