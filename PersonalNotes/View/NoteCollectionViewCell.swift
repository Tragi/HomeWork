//
//  NoteCollectionViewCell.swift
//  PersonalNotes
//
//  Created by maredlu1 on 16/12/2019.
//  Copyright © 2019 HomeWork. All rights reserved.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleView: UILabel?
    @IBOutlet var paningConstraint:NSLayoutConstraint?
      
    var deleteHandler:((NoteCollectionViewCell) -> Void) = {_ in}
    var startingOffsetX:CGFloat = 0
    var panGestureReognizer:UIPanGestureRecognizer?
    
    deinit {
        print("Cell is free")
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        let panGestureReognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureRecognizerDidRecognize))
        panGestureReognizer.delegate = self
        addGestureRecognizer(panGestureReognizer)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        deleteHandler = { _ in}
        paningConstraint?.constant = 0
        panGestureReognizer?.isEnabled = false
    }
    
    func setupViewModel(title:String, deleteHandler: @escaping ((NoteCollectionViewCell) -> Void)) {
        titleView?.text = title
        self.deleteHandler = deleteHandler
    }
    
    func startPreview() {
        paningConstraint?.constant = 85
        UIView.animate(withDuration: 0.25, delay: 0.5, options: [], animations: {
            self.layoutIfNeeded()
        }) { (_) in
            self.paningConstraint?.constant = 0
            UIView.animate(withDuration: 0.25, delay: 0.5, options: [], animations: {
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    @IBAction func deleteButtonDidTouch(sender: UIButton?) {
        deleteHandler(self)
    }

    //Deleting gesture
    @objc func gestureRecognizerDidRecognize(sender: UIPanGestureRecognizer) {
        switch (sender.state) {
            case .began:
                startingOffsetX = sender.translation(in: self).x + (paningConstraint?.constant ?? 0)
            case .changed:
                let deltaX = startingOffsetX - sender.translation(in: self).x
                paningConstraint?.constant = max (deltaX, 0)
            case .failed, .cancelled, .ended:
                NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(setFinalContentPosition), object: nil)
                perform(#selector(setFinalContentPosition), with: nil, afterDelay: 0.15)
            case .possible: break
            @unknown default: break
            
        }
    }

    @objc func setFinalContentPosition() {
        guard let constraint = paningConstraint else {
            return
        }
        if constraint.constant > 80 && constraint.constant < bounds.width / 4 * 3 {
            constraint.constant = 85
        } else if constraint.constant > 80 {
            constraint.constant = bounds.width;
            deleteButtonDidTouch(sender: nil)
        } else {
            constraint.constant = 0;
        }
            
        UIView.animate(withDuration: 0.35) {
            self.layoutIfNeeded()
        }
    }
}

extension NoteCollectionViewCell: UIGestureRecognizerDelegate {
    //should swipe gesutre recognizer be prefered instead of collectionview gesture recognizer
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let shouldRecognize = abs(gestureRecognizer.velocity(in: self).y) < abs(gestureRecognizer.velocity(in: self).x)
            return shouldRecognize
        }
        return true
    }
}
