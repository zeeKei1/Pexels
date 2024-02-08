//
//  SearchTextCollectionViewCell.swift
//  Pexels
//
//  Created by Zamanbek Kozhas on 04.11.2023.
//

import UIKit

protocol SearchTextCollectionViewCellDelegate {
    func searchTextCollectionViewCell(_ collectionView: UICollectionView, deleteButtonWasTapped indexPath: IndexPath)
}

class SearchTextCollectionViewCell: UICollectionViewCell {

    static let identifier: String = "SearchTextCollectionViewCell"
    
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var indexPath: IndexPath?
    var collectionView: UICollectionView?
    var delegate: SearchTextCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.lightGray.cgColor
        cardView.layer.cornerRadius = 10
    }

    func set(title: String, delegate: SearchTextCollectionViewCellDelegate, collectionView: UICollectionView, indexPath: IndexPath) {
        titleLabel.text = title
        self.delegate = delegate
        self.indexPath = indexPath
        self.collectionView = collectionView
        
    }
    @IBAction func deleteButtonClicked(_ sender: UIButton) {
        
        bounce(button: sender) {
            guard let indexPath = self.indexPath, let collectionView = self.collectionView else {
                return
            }
            
            self.delegate?.searchTextCollectionViewCell(collectionView, deleteButtonWasTapped: indexPath)
        }
    }
    
    func bounce(button: UIButton, completion: @escaping (()->())) {
        UIView.animate(
            withDuration: 0.3,
            animations: {
                button.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.3) {
                    button.transform = CGAffineTransform.identity
                } completion: { completed in
                    if completed {
                        completion()
                    }
                }
            }
        )
    }
}
