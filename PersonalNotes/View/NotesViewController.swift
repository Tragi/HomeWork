//
//  NotesViewController.swift
//  PersonalNotes
//
//  Created by maredlu1 on 16/12/2019.
//  Copyright © 2019 HomeWork. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController, NotesViewModelDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView?
    @IBOutlet weak var errorView: UIView?
    @IBOutlet weak var errorLabel: UILabel?
    @IBOutlet weak var loadingView: UIView?
    @IBOutlet weak var dataBaseItem: UIBarButtonItem?
    @IBOutlet weak var sortItem: UIBarButtonItem?
    @IBOutlet weak var addButton: UIButton?
    
    let viewModel = NotesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.delegate = self
        viewModel.viewStateChanged(actionType: .initial)
        if let flowLayout = collectionView?.collectionViewLayout as? NotesCollectionViewFlowLayout {
            viewModel.collectionViewFlowLayout = flowLayout
        }

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
        collectionView?.alwaysBounceVertical = true   
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController, let controller = navigationController.topViewController as? NoteEditorViewController {
            let indexPath = sender as? IndexPath
            if let indexPath = indexPath, viewModel.dataSource.count > indexPath.section, viewModel.dataSource[indexPath.section].count > indexPath.item {
                let note = viewModel.dataSource[indexPath.section][indexPath.item]
                controller.text = note.title
            }
            controller.completionHandler = {[weak self] (controller, success) in
                self?.dismiss(animated: true, completion: {
                    if success {
                        self?.viewModel.dataSourceStateChanged(actionType: .add, indexPath: indexPath, title: controller.textView?.text)
                    }
                })
            }
        }
    }
    
    func reload() {
        UIView.animate(withDuration: 0.15) {
            self.errorLabel?.text = self.viewModel.state.error
            self.errorView?.isHiddenInStackView = self.viewModel.state.error == nil
            self.collectionView?.isHiddenInStackView = self.viewModel.state.display != .dataSource
            self.loadingView?.isHiddenInStackView = self.viewModel.state.display != .loading
            self.dataBaseItem?.title = self.viewModel.state.dataBase == .online ? "Online" : "Offline"
            self.sortItem?.title = self.viewModel.state.sort == .ascending ? "Des" : "Asc"
            self.title = "Notes"
        }
    }
    
    func reloadDataSource(changes: DataSourceChanges, animated: Bool) {
        self.collectionView?.refreshControl?.endRefreshing()
        guard let collectionView = collectionView else { return }
        
        guard animated, changes.insertedSections.count + changes.insertedIndexPaths.count + changes.deletedSections.count + changes.deletedIndexPaths.count + changes.movedSections.count + changes.movedIndexPaths.count > 0 else {
            collectionView.reloadData()
            return
        }
        
        collectionView.isUserInteractionEnabled = false
        if changes.movedIndexPaths.count > 0 {
//            UIView.animate(withDuration: 0.15) { [unowned self] in
//                changes.movedIndexPaths.forEach { (from, to) in
//                    if let cell = self.collectionView?.cellForItem(at: from) as? NoteCollectionViewCell, self.viewModel.dataSource.count > to.section, self.viewModel.dataSource[to.section].count > to.row {
//                        let note = self.viewModel.dataSource[to.section][to.row]
//                        cell.setupViewModel(title:  note.title, deleteHandler: cell.deleteHandler)
//                    }
//                }
//            }
        }
        
        collectionView.performBatchUpdates({
            if changes.deletedSections.count > 0 {
                collectionView.deleteSections(IndexSet(changes.deletedSections))
            }
            if changes.insertedSections.count > 0 {
                collectionView.insertSections(IndexSet(changes.insertedSections))
            }
            if changes.deletedIndexPaths.count > 0 {
                collectionView.deleteItems(at: changes.deletedIndexPaths)
            }
            if changes.insertedIndexPaths.count > 0 {
                collectionView.insertItems(at: changes.insertedIndexPaths)
            }
            changes.movedSections.forEach {
                self.collectionView?.moveSection($0.from, toSection: $0.to)
            }
            changes.movedIndexPaths.forEach {
                self.collectionView?.moveItem(at: $0.from, to: $0.to)
            }
        }, completion: { (_) in
            self.collectionView?.reloadData()
            self.collectionView?.isUserInteractionEnabled = true
        })
    }
    
    @objc func refresh(sender: Any?) {
        viewModel.viewStateChanged(actionType: .refresh)
    }
    
    @IBAction func addButtondDidTouch(sender: UIButton) {
        performSegue(withIdentifier: "NoteEditorViewController", sender: nil)
    }
    
    @IBAction func sortItemDidTouch(sender: UIBarButtonItem) {
        viewModel.viewStateChanged(actionType: .sort)
    }
    
    @IBAction func dataBaseItemDidTouch(sender: UIBarButtonItem) {
        viewModel.viewStateChanged(actionType: .dataBase)
    }
}

extension NotesViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.dataSource.count
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.dataSource.count > section ? viewModel.dataSource[section].count : 0
    }
        
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCollectionViewCell", for: indexPath) as? NoteCollectionViewCell, viewModel.dataSource.count > indexPath.section, viewModel.dataSource[indexPath.section].count > indexPath.item else {
            return UICollectionViewCell()
        }
        
        let note = viewModel.dataSource[indexPath.section][indexPath.item]
        cell.setupViewModel(title: note.title, deleteHandler: { [weak self] (cell) in
            self?.viewModel.dataSourceStateChanged(actionType: .delete, indexPath: indexPath)
        })
        return cell
    }
        
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "NoteEditorViewController", sender: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //troubles with autosizing of collectionView items, don't waste time and lets do it manually
        guard viewModel.dataSource.count > indexPath.section, viewModel.dataSource[indexPath.section].count > indexPath.item else {
            return UICollectionViewFlowLayout.automaticSize
        }
        let note = viewModel.dataSource[indexPath.section][indexPath.item]
        let constraintRect = CGSize(width: collectionView.bounds.width - 20, height: CGFloat.greatestFiniteMagnitude)
        let text = note.title
        let boundingBox = text.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: UIFont.systemFont(ofSize: 15)], context: nil)
        return CGSize(width: constraintRect.width, height: boundingBox.height + 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? NoteCollectionViewCell else {
            return
        }
        if viewModel.state.dataSourceState.contains(where: {$0.state == .preview && $0.indexPath == indexPath}) {
            cell.startPreview()
            viewModel.state.dataSourceState.removeAll(where: {$0.state == .preview})
            UserDefaults.standard.set(true, forKey: "ItemCellHint")
        }
    }
}
