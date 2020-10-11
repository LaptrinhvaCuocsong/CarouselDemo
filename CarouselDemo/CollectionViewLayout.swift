//
//  CollectionViewLayout.swift
//  CarouselDemo
//
//  Created by Nguyen Manh Hung on 10/11/20.
//  Copyright © 2020 Nguyen Manh Hung. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
    var isCenter: Bool = false

    override func copy(with zone: NSZone? = nil) -> Any {
        let attributes = super.copy(with: zone) as! CollectionViewLayoutAttributes
        attributes.isCenter = isCenter
        return attributes
    }
}

//class CollectionViewLayout: UICollectionViewLayout {
//    private let itemSpacing: CGFloat = 8 // khoảng cách giữa các Cell
//    private var currentCellIndex = 0 // IndexPath.item của cell sẽ được focus
//    private var offsetX: CGFloat = 0 // vị trí offset của UICollectionView khi tính toán lại vị trí của các Cell
//    private var leftArray: [Int] = [] // mảng chứa IndexPath.item của các Cell nằm bên trái Cell đang được focus
//    private var rightArray: [Int] = [] // mảng chứa IndexPath.item của các Cell nằm bên phải Cell đang được focus
//    private var attributes: [UICollectionViewLayoutAttributes] = []
//    private var contentWidth: CGFloat = 0
//
//    private var numberOfItem: Int {
//        return collectionView?.numberOfItems(inSection: 0) ?? 0
//    }
//
//    private var sizeCell: CGSize {
//        let width = collectionView!.frame.width - itemSpacing * 4
//        let height = collectionView!.frame.height
//        return CGSize(width: width, height: height)
//    }
//
//    override func prepare() {
//    }
//
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        return []
//    }
//
//    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
//        return nil
//    }
//
//    override var collectionViewContentSize: CGSize {
//        return CGSize.zero
//    }
//
//    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        return true
//    }
//}

 class CollectionViewLayout: UICollectionViewLayout {
    private let itemSpacing: CGFloat = 8
    private let cycleStart: CGFloat = 10000

    private var attributes: [UICollectionViewLayoutAttributes] = []
    private var contentWidth: CGFloat = 0

    private var currentCellIndex = 0
    private var offsetX: CGFloat = 0
    private var leftArray: [Int] = []
    private var rightArray: [Int] = []
    private var isFirstTimePrepare = true

    private var numberOfItem: Int {
        return collectionView?.numberOfItems(inSection: 0) ?? 0
    }

    private var sizeCell: CGSize {
        let width = collectionView!.frame.width - itemSpacing * 4
        let height = collectionView!.frame.height
        return CGSize(width: width, height: height)
    }

    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }

        // Tại lần đầu prepare cần set offsetX của collectionView = 10000
        if isFirstTimePrepare {
            offsetX = cycleStart
            collectionView.contentOffset.x = cycleStart
            isFirstTimePrepare = false
        }

        // Trường hợp collectionView.reloadData
        if attributes.count != numberOfItem {
            attributes.removeAll()
            leftArray.removeAll()
            rightArray.removeAll()
        }

        // Tính số cell ở bên trái và bên phải cell đang được focus
        let numberOfLeftItem = numberOfItem % 2 == 1 ? numberOfItem / 2 : numberOfItem / 2 - 1
        let numberOfRightItem = numberOfItem - 1 - numberOfLeftItem

        // Lấy IndexPath.item của các cell ở bên trái và bên phải cell đang được focus
        var leadingRightArray: [Int] = []
        var trailingRightArray: [Int] = []
        var i = currentCellIndex - 1 < 0 ? numberOfItem - 1 : currentCellIndex - 1
        while leadingRightArray.count < numberOfLeftItem {
            leadingRightArray.append(i)
            i = (i - 1 < 0) ? numberOfItem - 1 : i - 1
        }
        var j = currentCellIndex + 1 >= numberOfItem ? 0 : currentCellIndex + 1
        while trailingRightArray.count < numberOfRightItem {
            trailingRightArray.append(j)
            j = (j + 1) >= numberOfItem ? 0 : j + 1
        }

        /*
         + leftArray là mảng chứa Index.item của các cell ở bên trái lần change offset của collectionView trước đó
         + Do đó nếu item nào chưa tồn tại trong leftArray ở lần change offset này thì cần được add vào additionalLeftArray để có thể thay đổi vị trí của cell đó
         **/
        var additionalLeftArray: [Int] = []
        for item in leadingRightArray {
            if !leftArray.contains(item) {
                additionalLeftArray.append(item)
            }
        }
        leftArray = leadingRightArray

        /*
        + rightArray là mảng chứa Index.item của các cell ở bên phải lần change offset của collectionView trước đó
        + Do đó nếu item nào chưa tồn tại trong rightArray ở lần change offset này thì cần được add vào additionalRightArray để có thể thay đổi vị trí của cell đó
        **/
        var additionalRightArray: [Int] = []
        for item in trailingRightArray {
            if !rightArray.contains(item) {
                additionalRightArray.append(item)
            }
        }
        rightArray = trailingRightArray

        // offsetX là vị trí hiện tại của collectionView
        let centerX = offsetX + collectionView.frame.width / 2

        for i in 0 ..< numberOfItem {
            let indexPath = IndexPath(item: i, section: 0)
            let attr = CollectionViewLayoutAttributes(forCellWith: indexPath)
            attr.isCenter = i == currentCellIndex

            if additionalLeftArray.contains(i) {
                if let index = leadingRightArray.firstIndex(of: i) {
                    // Tính khoảng cách từ minX của cell đến vị trí trung tâm, cách tính này sẽ dựa vào design
                    var distance: CGFloat = 0
                    for _ in 0 ... index {
                        distance += sizeCell.width + itemSpacing
                    }
                    distance += sizeCell.width / 2
                    attr.frame = CGRect(x: centerX - distance, y: 0, width: sizeCell.width, height: sizeCell.height)
                }
            } else if additionalRightArray.contains(i) {
                if let index = trailingRightArray.firstIndex(of: i) {
                    // Tính khoảng cách từ minX của cell đến vị trí trung tâm, cách tính này sẽ dựa vào design
                    var distance: CGFloat = 0
                    for j in 0 ... index {
                        distance += (j == index ? 0 : sizeCell.width) + itemSpacing
                    }
                    distance += sizeCell.width / 2
                    attr.frame = CGRect(x: centerX + distance, y: 0, width: sizeCell.width, height: sizeCell.height)
                }
            } else {
                if let frame = attributes.filter({ $0.indexPath.item == i }).first?.frame {
                    attr.frame = frame
                } else {
                    // Tính vị trí của cell đang được focus
                    let frame = CGRect(x: centerX - sizeCell.width / 2, y: 0, width: sizeCell.width, height: sizeCell.height)
                    attr.frame = frame
                }
            }

            if let index = attributes.firstIndex(where: { $0.indexPath.item == i }) {
                attributes.remove(at: index)
            }
            attributes.append(attr)
        }

        contentWidth = CGFloat(numberOfItem + 3) * itemSpacing + CGFloat(numberOfItem) * sizeCell.width
    }

    override class var layoutAttributesClass: AnyClass {
        return CollectionViewLayoutAttributes.self
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributes
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.item]
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth * 20000, height: collectionView?.frame.height ?? 0)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    func scroll(to newIndex: Int, animated: Bool = true, isSwipeLeft: Bool) {
        currentCellIndex = newIndex
        if isSwipeLeft {
            let newX = (collectionView?.contentOffset.x ?? cycleStart) + sizeCell.width + itemSpacing
            offsetX = newX
            collectionView?.setContentOffset(CGPoint(x: newX, y: 0), animated: animated)
        } else {
            let newX = (collectionView?.contentOffset.x ?? cycleStart) - sizeCell.width - itemSpacing
            offsetX = newX
            collectionView?.setContentOffset(CGPoint(x: newX, y: 0), animated: animated)
        }
    }
 }
