//
//  LeadViewController.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import UIKit

class LeadViewController: UIViewController {

    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var monthPickerView: UIView!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var lastMonthButton: UIButton!
    @IBOutlet weak var currentMonthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newLeadButton: GradientButton!
    @IBOutlet weak var tableView: UITableView!
    var viewModel: LeadViewModel!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        tableView.dataSource = self
        currentMonthLabel.text = viewModel.stringDate
        nextMonthButton.setTitle("", for: .normal)
        lastMonthButton.setTitle("", for: .normal)
        newLeadButton.makeRoundCorners(radius: 10)
        monthPickerView.makeRoundCorners(radius: 10)
        monthView.makeRoundCorners(radius: 10)
    }
 
    @IBAction func didTapNextMonth(_ sender: UIButton) {
        viewModel.didTapNextMonth()
    }
    
    @IBAction func didTapLastMonth(_ sender: UIButton) {
        viewModel.didTapLastMonth()
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
        let width = (view.frame.width - 51) / 3
        let height = width
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension LeadViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LeadCell", for: indexPath) as? LeadTableViewCell else {return UITableViewCell()}
        let cellViewModel = viewModel.getCellViewModel(at: indexPath)
        cell.configure(with: cellViewModel)
        return cell
    }
}

extension LeadViewController: LeadViewModelDelegate {
    func updateCurrentMonthLabel() {
        currentMonthLabel.text = viewModel.stringDate
    }
}
