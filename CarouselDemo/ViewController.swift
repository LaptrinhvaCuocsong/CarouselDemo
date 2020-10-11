//
//  ViewController.swift
//  CarouselDemo
//
//  Created by Nguyen Manh Hung on 10/11/20.
//  Copyright © 2020 Nguyen Manh Hung. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private var collectionView: UICollectionView!

    private let colors: [UIColor] = [.yellow, .orange, .black, .green, .red]
    private let cellIdentifier = "Cell"
    private let collectionLayout = CollectionViewLayout()

    private var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.collectionViewLayout = collectionLayout
        collectionView.isScrollEnabled = false
        let swipeLeftMainCollectionView = UISwipeGestureRecognizer(target: self, action: #selector(swipeCollectionView(gesture:)))
        swipeLeftMainCollectionView.direction = .left
        collectionView.addGestureRecognizer(swipeLeftMainCollectionView)
        let swipeRightMainCollectionView = UISwipeGestureRecognizer(target: self, action: #selector(swipeCollectionView(gesture:)))
        swipeRightMainCollectionView.direction = .right
        collectionView.addGestureRecognizer(swipeRightMainCollectionView)
    }

    @objc private func swipeCollectionView(gesture: UISwipeGestureRecognizer) {
        guard colors.count > 0 else { return }

        var oIndex: Int?
        var nIndex: Int?
        switch gesture.direction {
        case .left:
            oIndex = currentIndex
            nIndex = currentIndex + 1 >= colors.count ? 0 : currentIndex + 1
            guard let oldIndex = oIndex, let newIndex = nIndex, oldIndex != newIndex else {
                return
            }
            setCurrentIndex(oldValue: currentIndex, newValue: newIndex, isSwipeLeft: true)
        case .right:
            oIndex = currentIndex
            nIndex = currentIndex - 1 < 0 ? colors.count - 1 : currentIndex - 1
            guard let oldIndex = oIndex, let newIndex = nIndex, oldIndex != newIndex else {
                return
            }
            setCurrentIndex(oldValue: currentIndex, newValue: newIndex, isSwipeLeft: false)
        default:
            break
        }
    }

    private func setCurrentIndex(oldValue: Int, newValue: Int, isSwipeLeft: Bool) {
        currentIndex = newValue
        collectionLayout.scroll(to: newValue, isSwipeLeft: isSwipeLeft)
    }

    private func updateCollectionViewCell(newIndex: Int) {
        UIView.animate(withDuration: 0.3) {
            for i in 0 ..< self.colors.count {
                let cell = self.collectionView.cellForItem(at: IndexPath(item: i, section: 0))
                cell?.transform = CGAffineTransform.identity.scaledBy(x: 1, y: newIndex == i ? 1 : 0.9)
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
        cell.backgroundColor = colors[indexPath.item]
        return cell
    }

    // MARK: - UICollectionViewDelegate

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCollectionViewCell(newIndex: currentIndex)
    }
}
