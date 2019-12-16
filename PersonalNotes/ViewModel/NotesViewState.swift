//
//  NotesViewState.swift
//  PersonalNotes
//
//  Created by maredlu1 on 16/12/2019.
//  Copyright © 2019 HomeWork. All rights reserved.
//

import UIKit

typealias DataSourceChanges = (deletedSections:[Int], insertedSections:[Int], movedSections:[(from:Int, to:Int)], deletedIndexPaths:[IndexPath], insertedIndexPaths:[IndexPath], movedIndexPaths:[(from:IndexPath, to:IndexPath)], updatedIndexPaths:[IndexPath])

struct NotesViewState {
    
    enum Sort:String {
        case ascending = "Ascending"
        case descending = "Descending"
    }
    
    var sort:Sort = .ascending
    
    enum DataBase:String {
        case offline = "Offline"
        case online = "Online"
    }
    
    var dataBase:DataBase = .online
    
    enum Display:String {
        case dataSource = "dataSource"
        case error = "Error"
        case loading = "Loading"
    }
    
    var display:Display = .loading
    
    struct DataSourceState {
        enum State:String {
            case initial = "Initial"
            case preview = "Preview"
            case delete = "Delete"
        }
        var indexPath:IndexPath
        var state:State = .initial
    }
    
    var dataSourceState:[DataSourceState]
    var dataSourceChanges:DataSourceChanges
}
