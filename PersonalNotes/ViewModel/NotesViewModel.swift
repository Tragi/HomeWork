//
//  NotesViewModel.swift
//  PersonalNotes
//
//  Created by maredlu1 on 16/12/2019.
//  Copyright © 2019 HomeWork. All rights reserved.
//

import UIKit

protocol NotesViewModelDelegate: class {
    func reload()
    func reloadDataSource(changes:DataSourceChanges, animated: Bool)
}

typealias DataSourceChanges = (deletedSections:[Int], insertedSections:[Int], movedSections:[(from:Int, to:Int)], deletedIndexPaths:[IndexPath], insertedIndexPaths:[IndexPath], movedIndexPaths:[(from:IndexPath, to:IndexPath)], updatedIndexPaths:[IndexPath])

class NotesViewModel: NSObject {
    
    enum ActionType {
        case sort
        case dataBase
        case add
        case refresh
        case initial
        case delete
    }
    
    var state = NotesViewState()
    var dataSource:[[Note]] = []
    var dataService:DataService = APIService()
    
    weak var collectionViewFlowLayout:NotesCollectionViewFlowLayout?
    weak var delegate:NotesViewModelDelegate?
    
    func viewStateChanged(actionType:ActionType) {
        var refresh = true
        var loading = false
        collectionViewFlowLayout?.state = .initial
        switch actionType {
        case .sort:
            state.sort = state.sort == .ascending ? .descending : .ascending
            refresh = false
        case .dataBase:
            state.dataBase = state.dataBase == .online ? .offline : .online
            loading = state.dataBase == .online
            setupDataBase()
        case .initial:
            loading = true
        default: break
        }
        delegate?.reload()
        refreshDataSource(refresh: refresh, loading: loading)
    }
    
    func dataSourceStateChanged(actionType:ActionType, indexPath:IndexPath?, title:String? = nil) {
        switch actionType {
        case .delete:
            if let indexPath = indexPath, dataSource.count > indexPath.section, dataSource[indexPath.section].count > indexPath.item {
                collectionViewFlowLayout?.state = .delete
                delete(note: dataSource[indexPath.section][indexPath.item])
            }
        case .add:
            if let indexPath = indexPath, dataSource.count > indexPath.section, dataSource[indexPath.section].count > indexPath.item  {
                var note = dataSource[indexPath.section][indexPath.item]
                note.title = title ?? ""
                collectionViewFlowLayout?.state = .update
                update(note: note)
            } else if let title = title {
                collectionViewFlowLayout?.state = .insert
                createNote(title:title)
            }
        default: break
        }
        delegate?.reload()
    }
    
    private func refreshDataSource(refresh:Bool, loading: Bool = false) {
        if loading {
            state.display = .loading
        }
        if refresh {
            delegate?.reload()
            dataService.notes { [weak self] (notes, error) in
                self?.state.error = nil
                if let error = error {
                    self?.state.error = error.localizedDescription
                }
                if let notes = notes {
                    self?.prepare([notes])
                } else {
                    self?.prepare(nil)
                }
            }
        } else {
            prepare(dataSource)
        }
    }
    
    private func prepare(_ dataSource:[[Note]]?) {
        guard let dataSource = dataSource else {
            state.display = .dataSource
            state.error = "No data"
            delegate?.reload()
            return
        }
        
        let targetDataSource = [(dataSource.first ?? []).sorted(by: {
            if self.state.sort == .ascending {
                return $0.id > $1.id
            } else {
                return $0.id < $1.id
            }
        })]
                
        if  UserDefaults.standard.bool(forKey: "DeletionPreview") != true, targetDataSource.count > 0, targetDataSource[0].count > 0 {
            state.dataSourceState.append(NotesViewState.DataSourceState(indexPath: IndexPath(item: 0, section: 0), state: .preview))
            UserDefaults.standard.set(true, forKey: "DeletionPreview")
        }
        
        let changes = dataSourceChanges(initialDataSource: self.dataSource, targetDataSource: targetDataSource)
        self.dataSource = targetDataSource
        state.display = .dataSource
        state.error = targetDataSource.flatMap({$0}).count == 0 ? "No data to display" : nil
        delegate?.reloadDataSource(changes: changes, animated: true)
        delegate?.reload()
        
    }
    
    private func setupDataBase() {
        dataService = state.dataBase == .online ? APIService() : CoreDataService()
    }
    
    private func createNote(title:String) {
        dataService.createNote(title: title) { [weak self] (note, error) in
            guard note != nil else {
                self?.state.error = error?.localizedDescription ?? "Something get wrong"
                self?.delegate?.reload()
                return
            }
            self?.refreshDataSource(refresh: true)
        }
    }
    
    private func update(note: Note) {
        dataService.updateNote(note: note) { [weak self] (note, error) in
            guard note != nil else {
                self?.state.error = error?.localizedDescription ?? "Something get wrong"
                self?.delegate?.reload()
                return
            }
            self?.refreshDataSource(refresh: true)
        }
    }
    
    private func delete(note:Note) {
        dataService.deleteNote(note: note) { [weak self] (note, error) in
            if note == nil, error == nil {
                self?.refreshDataSource(refresh: true)
            } else if let error = error {
                self?.state.error = error.localizedDescription
            } else {
                self?.state.error = "Something wrong prevent to delete this note"
            }
            self?.delegate?.reload()
        }
    }
    
    //generic logic for comparing previous data source with new one and resolve all changes for tableview/collectionview datasource changes
    //it is simplified from proper handling of section (2 dimensional arrays) - just good enough for this Notes purpose
    private func dataSourceChanges(initialDataSource: [[Note]], targetDataSource: [[Note]]) -> DataSourceChanges {
        var deletedSections:[Int] = [], insertedSections:[Int] = [], deleted:[IndexPath] = [],inserted:[IndexPath] = [], updated:[IndexPath] = []
        var movedSections:[(from:Int,to:Int)] = [], movedItems:[(from:IndexPath,to:IndexPath)] = []
        
        //just check inputs - server may send duplicit IDs or any other broken data, so in this case skip changes and it will cause simply tableView.reloadData()
        let initialStateIds = initialDataSource.flatMap({$0.compactMap({$0.id > 0 ? $0.id : nil})})
        let targetStateIds = targetDataSource.flatMap({$0.compactMap({$0.id > 0 ? $0.id : nil})})
        guard  initialStateIds.count == Set(initialStateIds).count, targetStateIds.count == Set(targetStateIds).count else {
            return (deletedSections, insertedSections, movedSections, deleted, inserted, movedItems, updated)
        }
        
        var insertedIds:[Int] = []
        targetDataSource.enumerated().forEach { (tuple) in let (toIndex, element) = tuple
            if initialDataSource.count > toIndex {
                element.enumerated().forEach({ (tuple) in let (toOffset, toElement) = tuple
                    if initialDataSource[toIndex].contains(where: {$0.id == toElement.id && $0.title == toElement.title}) == false {
                        inserted.append(IndexPath(row: toOffset, section: toIndex))
                        insertedIds.append(toElement.id)
                    }
                })
            } else {
                insertedSections.append(toIndex)
            }
        }
        initialDataSource.enumerated().forEach { (tuple) in let (fromIndex, element) = tuple
            if targetDataSource.count > fromIndex {
                element.enumerated().forEach({ (tuple) in let (fromOffset, fromElement) = tuple
                    if targetDataSource[fromIndex].contains(where: {$0.id == fromElement.id && $0.title == fromElement.title}) == false {
                        deleted.append(IndexPath(row: fromOffset, section: fromIndex))
                    }
                })
            } else {
                deletedSections.append(fromIndex)
            }
        }
        
        initialDataSource.enumerated().forEach { (tuple) in let (index, section) = tuple
            section.enumerated().forEach({ (tuple) in let (offset, item) = tuple
                if item.id > 0, targetDataSource.count > index, let targetOffset = targetDataSource[index].firstIndex(where: {item.id == $0.id && item.title == $0.title}), targetOffset < section.count {
                    movedItems.append((from: IndexPath(row: offset, section: index), to: IndexPath(row: targetOffset, section: index)))
                }
            })
        }
        
        return (deletedSections, insertedSections, movedSections, deleted, inserted, movedItems, updated)
    }
    
}
