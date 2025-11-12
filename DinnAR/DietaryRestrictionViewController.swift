//
//  DietaryRestrictionViewController.swift
//  DinnAR
//
//  Created by Angela Liu on 10/21/25.
//

import UIKit

public let dietaryRestrictionArr = ["Vegetarian", "Vegan","Kosher", "Gluten-Free", "Nut-Free", "Dairy-Free", "Shellfish-Free", "None"]

class DietaryRestrictionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    var dietaryRestrictionViewCell = "DietaryRestrictionViewCell"
    var selectedRestrictionIndex = [IndexPath]()
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var readyFinalButton: UIButton!
    @IBOutlet weak var dietaryRestrictionCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dietaryRestrictionCollection.delegate = self
        dietaryRestrictionCollection.dataSource = self
        dietaryRestrictionCollection.backgroundColor = UIColor(named: "BackrgoundColor")
        
        backButton.layer.cornerRadius = 10
        backButton.backgroundColor = UIColor(named: "ButtonColor")
        readyFinalButton.layer.cornerRadius = 10
        readyFinalButton.backgroundColor = UIColor(named: "ButtonColor")
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dietaryRestrictionArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dietaryRestrictionCollection.dequeueReusableCell(withReuseIdentifier: dietaryRestrictionViewCell, for: indexPath) as! CollectionViewCell
        let content = dietaryRestrictionArr[indexPath.item]
        cell.textLabel.text = content
        
        if selectedRestrictionIndex.contains(indexPath) {
            cell.textLabel.textColor = .white
            cell.cellView.backgroundColor = UIColor(named: "BurntOrange")
        } else {
            cell.cellView.backgroundColor = .white
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedType = dietaryRestrictionArr[indexPath.item]
        
        if  selectedType == "None" {
            selectedRestrictionIndex.removeAll()
            selectedRestrictionIndex.append(indexPath)
        } else {
            
            if let noneIndex = dietaryRestrictionArr.firstIndex(of: "None") {
                let nonePath = IndexPath(item: noneIndex, section: 0)
                selectedRestrictionIndex.removeAll { $0 == nonePath }
            }
            // Save toggled selection
            if selectedRestrictionIndex.contains(indexPath) {
                selectedRestrictionIndex.removeAll { $0 == indexPath }
            } else {
                selectedRestrictionIndex.append(indexPath)
            }
            
        }
        dietaryRestrictionCollection.reloadData()
    }
    // Grid layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (dietaryRestrictionCollection.frame.width - 40) / 2
        return CGSize(width: width, height: 45)}
}
