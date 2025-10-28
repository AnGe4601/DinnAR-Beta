//
//  CollectionViewCell.swift
//  DinnAR
//
//  Created by Angela Liu on 10/19/25.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        // Set up the border and corner style here
        cellView.layer.cornerRadius = 20
        cellView.layer.borderWidth = 1
        cellView.layer.borderColor = UIColor(named: "BurntOrange")?.cgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel.textColor = .black
        cellView.backgroundColor = .white
    }
}
