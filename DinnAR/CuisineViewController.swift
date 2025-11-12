//
//  CuisineViewController.swift
//  DinnAR
//
//  Created by Angela Liu on 10/19/25.
//

import UIKit

public let cuisineType = ["Chinese", "Italian", "Japanese", "Korean", "Thai", "Indian", "Mexican", "American", "French", "Greek", "Others", "All"]

class CuisineViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var cuisineViewCell = "CuisineCollectionViewCell"
    var selectedCuisineIndex = [IndexPath]()
    
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var CuisineCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CuisineCollectionView.delegate = self
        CuisineCollectionView.dataSource = self
        CuisineCollectionView.backgroundColor = UIColor(named: "BackgroundColor")
        
        nextButton.layer.cornerRadius = 10
        nextButton.backgroundColor = UIColor(named: "ButtonColor")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cuisineType.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CuisineCollectionView.dequeueReusableCell(withReuseIdentifier: cuisineViewCell, for: indexPath) as! CollectionViewCell
        let content = cuisineType[indexPath.item]
        cell.textLabel.text = content
        
        if selectedCuisineIndex.contains(indexPath) {
            cell.textLabel.textColor = .white
            cell.cellView.backgroundColor = UIColor(named: "BurntOrange")
        } else {
            cell.cellView.backgroundColor = .white
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCusine = cuisineType[indexPath.item]
        if selectedCusine == "All" {
            selectedCuisineIndex.removeAll()
            selectedCuisineIndex.append(indexPath)
        } else {
            if let allIndex = cuisineType.firstIndex(of: "All") {
                let allPath = IndexPath(item: allIndex, section: 0)
                selectedCuisineIndex.removeAll { $0 == allPath }
            }
            
            if selectedCuisineIndex.contains(indexPath) {
                selectedCuisineIndex.removeAll { $0 == indexPath }
            } else {
                selectedCuisineIndex.append(indexPath)
            }
        }
        CuisineCollectionView.reloadData()
    }
    // Grid layout
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (CuisineCollectionView.frame.width - 40) / 2
        return CGSize(width: width, height: 45)}
}
