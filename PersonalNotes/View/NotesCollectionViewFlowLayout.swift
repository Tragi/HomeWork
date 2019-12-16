//
//  NotesCollectionViewFlowLayout.swift
//  PersonalNotes
//
//  Created by maredlu1 on 16/12/2019.
//  Copyright © 2019 HomeWork. All rights reserved.
//

import UIKit

class NotesCollectionViewFlowLayout: UICollectionViewFlowLayout {
    enum State {
        case initial
        case delete
        case insert
        case update
    }
    
    var state:State = .initial
    
    private var animatingIndexPaths:[IndexPath] = []
    
    @IBInspectable public var prefferedItemSize:CGSize = .zero {
        didSet {
            self.itemSize = prefferedItemSize
        }
    }
    @IBInspectable public var prefferedItemSpace:CGFloat = 0 {
        didSet {
            self.minimumInteritemSpacing = prefferedItemSpace
        }
    }
    @IBInspectable public var prefferedLineSpace:CGFloat = 0 {
        didSet {
            self.minimumLineSpacing = prefferedLineSpace
        }
    }
    @IBInspectable public var prefferedHorizontalMargin:CGFloat = 0 {
        didSet {
            self.sectionInset = UIEdgeInsets(top: prefferedVerticalMargin, left: self.sectionInset.left, bottom: prefferedVerticalMargin, right: self.sectionInset.right)
        }
    }
    @IBInspectable public var prefferedVerticalMargin:CGFloat = 0 {
        didSet {
            self.sectionInset = UIEdgeInsets(top: self.sectionInset.top, left: prefferedHorizontalMargin, bottom: self.sectionInset.bottom, right: prefferedHorizontalMargin)
        }
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) {
            if (animatingIndexPaths.contains(itemIndexPath)) {
                switch state {
                case .initial:
                    attributes.center = CGPoint(x: attributes.center.x + attributes.size.width, y: attributes.center.y)
                case .update:
                    attributes.transform3D = CATransform3DMakeRotation(.pi / 2, 1, 0, 0)
                case .delete, .insert:
                    attributes.center = CGPoint(x: attributes.center.x, y: attributes.center.y - attributes.size.height)
                }
            }
            return attributes
        }
        return nil
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) {
            if (animatingIndexPaths.contains(itemIndexPath)) {
                switch state {
                case .initial:
                    attributes.center = CGPoint(x: attributes.center.x - attributes.size.width, y: attributes.center.y)
                case .update:
                    attributes.transform3D = CATransform3DMakeRotation(-.pi / 2, 1, 0, 0)
                case .delete, .insert:
                    attributes.center = CGPoint(x: attributes.center.x, y: attributes.center.y - attributes.size.height)
                }     
            }
            return attributes
        }
        return nil
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        animatingIndexPaths = []
        
        for updateItem in updateItems {
            switch (updateItem.updateAction, updateItem.indexPathAfterUpdate, updateItem.indexPathBeforeUpdate) {
                case (.insert, let .some(indexPath), _):
                    animatingIndexPaths.append(indexPath)
                case (.delete, _, let .some(indexPath)):
                    animatingIndexPaths.append(indexPath)
//                case (.move, let .some(indexPathAfterUpdate), let .some(indexPathBeforeUpdate)):
//                    animatingIndexPaths.append(indexPathAfterUpdate)
//                    animatingIndexPaths.append(indexPathBeforeUpdate)
                default: break
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        animatingIndexPaths = []
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return !__CGSizeEqualToSize(self.collectionView?.bounds.size ?? CGSize.zero, newBounds.size)
    }
}
