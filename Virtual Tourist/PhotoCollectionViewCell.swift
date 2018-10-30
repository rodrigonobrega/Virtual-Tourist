//
//  PhotoCollectionViewCell.swift
//  Virtual Tourist
//
//  Created by Rodrigo on 14/10/18.
//  Copyright © 2018 Rodrigo. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var downloadActivity: UIActivityIndicatorView!
    
    func updateCellWithPhoto(_ photo: Photo) {
        if let binaryPhoto = photo.binaryPhoto {
            self.downloadActivity.stopAnimating()
            let image = UIImage(data: binaryPhoto, scale: 1.0)
            self.photoImage.image = image
        } else {
            self.downloadActivity.startAnimating()
            self.photoImage.image = nil
        }
    }
    
}
