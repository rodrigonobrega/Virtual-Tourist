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
         DispatchQueue.main.async {
            if photo.binaryPhoto != nil {
                self.downloadActivity.stopAnimating()
                self.photoImage.image = UIImage(data: photo.binaryPhoto!)
            } else {
                self.downloadActivity.startAnimating()
                self.photoImage.image = nil
            }
            
        }
    }
    
}
    

