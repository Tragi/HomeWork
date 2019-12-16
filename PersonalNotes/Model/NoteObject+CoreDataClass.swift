//
//  NoteObject+CoreDataClass.swift
//  PersonalNotes
//
//  Created by maredlu1 on 16/12/2019.
//  Copyright © 2019 HomeWork. All rights reserved.
//
//

import Foundation
import CoreData

@objc(NoteObject)
public class NoteObject: NSManagedObject {
    static func noteObjects(context: NSManagedObjectContext) -> [NoteObject] {
        return (try? context.fetch(NSFetchRequest<NSFetchRequestResult>(entityName: "NoteObject")) as? [NoteObject]) ?? []
    }
    static func noteObject(id:Int, context: NSManagedObjectContext) -> NoteObject? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "NoteObject")
        request.predicate = NSPredicate(format: "id == \(id)")
               
        if let results = try? context.fetch(request) as? [NoteObject], let note = results.first {
            return note
        } else {
            return nil
        }
    }
    
    static func createNoteObject(context: NSManagedObjectContext) -> NoteObject? {
        if let note = NSEntityDescription.insertNewObject(forEntityName: "NoteObject", into: context) as? NoteObject {
            let lastId = NoteObject.noteObjects(context: context).sorted(by: {$0.id > $1.id}).first?.id ?? 0
            note.id = lastId + 1
            return note
        } else {
            return nil
        }
    }
    
    func delete(context:NSManagedObjectContext) {
        context.delete(self)
    }
        
}
