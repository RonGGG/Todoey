//
//  Item.swift
//  Todoey
//
//  Created by 郭梓榕 on 6/12/2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift
class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    var itemToCate = LinkingObjects(fromType: Category.self, property: "items")
}
