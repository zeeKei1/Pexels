//
//  PhotoCollectionViewCell.swift
//  Pexels
//
//  Created by Zamanbek Kozhas on 04.11.2023.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {

    static let identifier: String = "PhotoCollectionViewCell"
    var photo: Photo?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = UIImage(named: "image_placeholder")
    }

    func setup(photo: Photo) {
        self.photo = photo
        
        let mediumPhotoURLString: String = photo.src.medium
        guard let mediumPhotoURL = URL(string: mediumPhotoURLString) else {
            print("Couldn't create URL with given mediumPhotoURLString: \(mediumPhotoURLString)")
            return
        }
        
        self.activityIndicatorView.startAnimating()
       let dataTask = URLSession.shared.dataTask(with: mediumPhotoURL, completionHandler: imageLoadCompletionHandler(data:urlResponse:error:))
        dataTask.resume()
    }
    
    func imageLoadCompletionHandler(data: Data?, urlResponse: URLResponse?, error: Error?) {
        
        if urlsAreSame(responseURL: urlResponse?.url?.absoluteString) {
            
            DispatchQueue.main.async {
                self.activityIndicatorView.stopAnimating()
            }
        }
        
        if let error = error {
            
            print("Error loading image: \(error.localizedDescription)")
        } else if let data = data {
            
            guard urlsAreSame(responseURL: urlResponse?.url?.absoluteString) else {
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }
    }
    
    func urlsAreSame(responseURL: String?) -> Bool {
        
        guard let currentPhotoURL = self.photo?.src.medium, let responseURL = responseURL else {
            print("Current photo url OR Response url are absent")
            return false
        }
        guard currentPhotoURL == responseURL else {
            print("ATTENTION! currentPhotoURL and responseURL are different!")
            return false
        }
        return true
    }
}
