//
//  NotesViewState.swift
//  PersonalNotes
//
//  Created by maredlu1 on 16/12/2019.
//  Copyright © 2019 HomeWork. All rights reserved.
//

import UIKit

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
        case dataSource = "DataSource"
        case loading = "Loading"
    }
    
    var display:Display = .loading
    var error:String?
    
    struct DataSourceState {
        enum State:String {
            case initial = "Initial"
            case preview = "Preview"
            case delete = "Delete"
        }
        var indexPath:IndexPath
        var state:State = .initial
    }
    
    var dataSourceState:[DataSourceState] = []
}
