//
//  CollectionViewCell.swift
//  CarouselDemo
//
//  Created by Nguyen Manh Hung on 10/11/20.
//  Copyright © 2020 Nguyen Manh Hung. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        guard let layoutAttributes = layoutAttributes as? CollectionViewLayoutAttributes else {
            return
        }
        let isCenter = layoutAttributes.isCenter
        transform = CGAffineTransform.identity.scaledBy(x: 1, y: isCenter ? 1 : 0.9)
    }
}
