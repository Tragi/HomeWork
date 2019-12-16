//
//  NoteObject+CoreDataProperties.swift
//  PersonalNotes
//
//  Created by maredlu1 on 16/12/2019.
//  Copyright © 2019 HomeWork. All rights reserved.
//
//

import Foundation
import CoreData


extension NoteObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NoteObject> {
        return NSFetchRequest<NoteObject>(entityName: "NoteObject")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?

}
