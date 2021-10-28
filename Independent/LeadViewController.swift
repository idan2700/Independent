//
//  LeadViewController.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import UIKit

class LeadViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newLeadButton: GradientButton!
    @IBOutlet weak var tableView: UITableView!
    var viewModel: LeadViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = LeadViewModel()
        collectionView.dataSource = self
        collectionView.delegate = self
        newLeadButton.makeButtonRound()
    }

}

extension LeadViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = collectionView.dequeueReusableCell(withReuseIdentifier: "LeadItem", for: indexPath) as? LeadCollectionViewCell else {return UICollectionViewCell()}
        let itemViewModel = viewModel.getItemViewModel(at: indexPath)
        item.configure(with: itemViewModel)
        return item
    }
}

extension LeadViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 50) / 3
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
