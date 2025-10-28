//
//  ResturantTypeViewController.swift
//  DinnAR
//
//  Created by Angela Liu on 10/17/25.
//

import UIKit

public let resturantTypeArr = ["Cafe/Bistro", "Food Truck", "Fine Dine", "Fast Food", "Casual Dining", "Bar", "All"]

    class ResturantTypeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        var resturantTypeCell = "rtCollectionViewCell"
        var selectedResturantIndex = [IndexPath]()
        //var selectedResturantData = [String]()
        
        @IBOutlet weak var backButton: UIButton!
        @IBOutlet weak var nextButton: UIButton!
        @IBOutlet weak var resturantTypeCollection: UICollectionView!
        @IBOutlet weak var textLabel: UILabel!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            resturantTypeCollection.delegate = self
            resturantTypeCollection.dataSource = self
            resturantTypeCollection.backgroundColor = UIColor(named: "BackgroundColor")
            
            backButton.layer.cornerRadius = 10
            backButton.backgroundColor = UIColor(named: "ButtonColor")
            nextButton.layer.cornerRadius = 10
            nextButton.backgroundColor = UIColor(named: "ButtonColor")
            
            // Debug Message
//            for family in UIFont.familyNames {
//                print("Family: \(family)")
//                for name in UIFont.fontNames(forFamilyName: family) {
//                    print("   \(name)")
//                }
//            }
            
            textLabel.font = UIFont(name: "DMSerifText-Regular", size: 24)
            textLabel.textColor = UIColor(named: "BurntOrange")
        }
        
        // Populate collection view
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = resturantTypeCollection.dequeueReusableCell(withReuseIdentifier: resturantTypeCell, for: indexPath) as! CollectionViewCell
            let type = resturantTypeArr[indexPath.item]
            cell.textLabel.text = type
            
            if selectedResturantIndex.contains(indexPath) {
                cell.textLabel.textColor = .white
                cell.cellView.backgroundColor = UIColor(named: "BurntOrange")
            } else {
                cell.cellView.backgroundColor = .white
            }

            return cell
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return resturantTypeArr.count
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let selectedType = resturantTypeArr[indexPath.item]
            
            if selectedType == "All" {
                selectedResturantIndex.removeAll()
                selectedResturantIndex.append(indexPath)
            } else {
                if let allIndex = resturantTypeArr.firstIndex(of: "All") {
                    let allPath = IndexPath(item: allIndex, section: 0)
                    selectedResturantIndex.removeAll { $0 == allPath }
                }
                
                if selectedResturantIndex.contains(indexPath) {
                    selectedResturantIndex.removeAll { $0 == indexPath }
                } else {
                    selectedResturantIndex.append(indexPath)
                }
            }
            resturantTypeCollection.reloadData()
        }
        
        // Grid layout
        func collectionView(_ collectionView: UICollectionView,
                                layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            let width = (resturantTypeCollection.frame.width - 40) / 2
            return CGSize(width: width, height: 45)}
    
    }
