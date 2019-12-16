//
//  CoreDataService.swift
//  PersonalNotes
//
//  Created by maredlu1 on 16/12/2019.
//  Copyright © 2019 HomeWork. All rights reserved.
//

import UIKit

class CoreDataService: DataService {
    let defaultContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    func notes(completionHandler: @escaping (([Note]?, Error?) -> Void)) {
        if let context = defaultContext {
            completionHandler(NoteObject.noteObjects(context: context).map({ Note(id: Int($0.id), title: $0.title ?? "") }), nil)
        } else {
            completionHandler(nil , NSError(domain: "CoreDataService", code: -1, userInfo: ["error": "Trouble with database"]))
        }
    }
    func createNote(title:String, completionHandler: @escaping ((Note?, Error?) -> Void)) {
        if let context = defaultContext, let noteObject = NoteObject.createNoteObject(context: context) {
            noteObject.title = title
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            completionHandler(Note(id: Int(noteObject.id), title: noteObject.title ?? ""), nil)
        } else {
            completionHandler(nil , NSError(domain: "CoreDataService", code: -1, userInfo: ["error": "Trouble with database"]))
        }
    }
    func updateNote(note:Note, completionHandler: @escaping ((Note?, Error?) -> Void)) {
        if let context = defaultContext, let noteObject = NoteObject.noteObject(id: note.id, context: context) {
            noteObject.title = note.title
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            completionHandler(Note(id: Int(noteObject.id), title: noteObject.title ?? ""), nil)
        } else {
            completionHandler(nil , NSError(domain: "CoreDataService", code: -1, userInfo: ["error": "Trouble with database"]))
        }
    }
    func deleteNote(note:Note, completionHandler: @escaping ((Note?, Error?) -> Void)) {
        if let context = defaultContext, let noteObject = NoteObject.noteObject(id: note.id, context: context) {
            noteObject.delete(context: context)
            (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
            completionHandler(nil, nil)
        } else {
            completionHandler(nil , NSError(domain: "CoreDataService", code: -1, userInfo: ["error": "Trouble with database"]))
        }
    }

}
