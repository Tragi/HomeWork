//
//  APIService.swift
//  PersonalNotes
//
//  Created by maredlu1 on 16/12/2019.
//  Copyright © 2019 HomeWork. All rights reserved.
//

import UIKit

class APIService: DataService {
    //hacking mockuped api for better performance
    var notes:[Note] = []
    
    //CRUD requests
    func notes(completionHandler: @escaping (([Note]?, Error?) -> Void)) {
        guard let url = URL(string: "https://private-anon-9f8fc36965-note10.apiary-mock.com/notes") else {
            completionHandler(nil, NSError(domain: "APIService", code: -1, userInfo: ["error": "Unable to initialize URL"]))
            return
        }
        SessionService.global.sendRequest(url: url, httpMethod: "GET", httpBody: nil) { [weak self] (data, error, response) in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            guard let data = data else {
                completionHandler(nil, NSError(domain: "APIService", code: -1, userInfo: ["error": "No Data"]))
                return
            }
            do {
                let notes = try JSONDecoder().decode([Note].self, from: data)
                notes.forEach({ (note) in
                    if false == self?.notes.contains(where: {note.id == $0.id}) {
                        self?.notes.append(note)
                    }
                })
                completionHandler(self?.notes ?? notes, nil)
            } catch let error {
                completionHandler(nil, error)
            }
        }
    }
    
    func createNote(title:String, completionHandler: @escaping ((Note?, Error?) -> Void)) {
        guard let url = URL(string: "https://private-anon-9f8fc36965-note10.apiary-mock.com/notes") else {
            completionHandler(nil, NSError(domain: "APIService", code: -1, userInfo: ["error": "Unable to initialize URL"]))
            return
        }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: ["Title":title], options: .prettyPrinted) else {
            completionHandler(nil, NSError(domain: "APIService", code: -1, userInfo: ["error": "Unable to create POST body"]))
            return
        }
        SessionService.global.sendRequest(url: url, httpMethod: "POST", httpBody: httpBody) { [weak self] (data, error, response) in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            guard let data = data else {
                completionHandler(nil, NSError(domain: "APIService", code: -1, userInfo: ["error": "No Data"]))
                return
            }
            do {
                let note = try JSONDecoder().decode(Note.self, from: data)
                if false == self?.notes.contains(where: {$0.id == note.id}) {
                    self?.notes.append(note)
                }
                completionHandler(note, nil)
            } catch let error {
                completionHandler(nil, error)
            }
            
        }
    }
    
    func updateNote(note:Note, completionHandler: @escaping ((Note?, Error?) -> Void)) {
        guard let url = URL(string: "https://private-anon-9f8fc36965-note10.apiary-mock.com/notes/\(note.id)") else {
            completionHandler(nil, NSError(domain: "APIService", code: -1, userInfo: ["error": "Unable to initialize URL"]))
            return
        }
        guard let httpBody = try? JSONSerialization.data(withJSONObject: ["Title":note.title], options: .prettyPrinted) else {
            completionHandler(nil, NSError(domain: "APIService", code: -1, userInfo: ["error": "Unable to create POST body"]))
            return
        }
        SessionService.global.sendRequest(url: url, httpMethod: "PUT", httpBody: httpBody) { [weak self] (data, error, response) in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            guard let data = data else {
                completionHandler(nil, NSError(domain: "APIService", code: -1, userInfo: ["error": "No Data"]))
                return
            }
            do {
                let note = try JSONDecoder().decode(Note.self, from: data)
                if let notes = self?.notes {
                    for (index, item) in notes.enumerated() {
                        if note.id == item.id {
                            self?.notes[index] = note
                        }
                    }
                }
                completionHandler(note, nil)
            } catch let error {
                completionHandler(nil, error)
            }
        }
    }
    
    func deleteNote(note:Note, completionHandler: @escaping ((Note?, Error?) -> Void)) {
        guard let url = URL(string: "https://private-anon-9f8fc36965-note10.apiary-mock.com/notes/\(note.id)") else {
            completionHandler(nil, NSError(domain: "APIService", code: -1, userInfo: ["error": "Unable to initialize URL"]))
            return
        }
        
        SessionService.global.sendRequest(url: url, httpMethod: "DELETE", httpBody: nil) { [weak self] (data, error, response) in
            guard error == nil else {
                completionHandler(nil, error)
                return
            }
            guard data != nil else {
                completionHandler(nil, NSError(domain: "APIService", code: -1, userInfo: ["error": "No Data"]))
                return
            }
            self?.notes.removeAll(where: {$0.id == note.id})
            completionHandler(nil, nil)
        }
    }
}
