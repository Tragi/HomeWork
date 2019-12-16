//
//  DataService.swift
//  PersonalNotes
//
//  Created by maredlu1 on 16/12/2019.
//  Copyright © 2019 HomeWork. All rights reserved.
//

import UIKit

protocol DataService: class {

    func notes(completionHandler: @escaping (([Note]?, Error?) -> Void))
    func createNote(title:String, completionHandler: @escaping ((Note?, Error?) -> Void))
    func updateNote(note:Note, completionHandler: @escaping ((Note?, Error?) -> Void))
    func deleteNote(note:Note, completionHandler: @escaping ((Note?, Error?) -> Void))
}
