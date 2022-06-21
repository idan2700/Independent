//
//  FuSectionTableViewCell.swift
//  Independent
//
//  Created by Idan Levi on 21/06/2022.
//

import UIKit

class FuSectionTableViewCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: FuSectionTableViewCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    
    func configure(with cellViewModel: FuSectionTableViewCellViewModel) {
        self.viewModel = cellViewModel
        cellView.makeRoundCorners(radius: 20)
        cellView.addShadow(color: UIColor(named: "50gold")!, opacity: 1, radius: 1, size: CGSize(width: -1.1, height: -1.1))
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension FuSectionTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "fuCell", for: indexPath) as? FuTableViewCell else {return UITableViewCell()}
        let cellViewModel = viewModel.viewModelForCell(at: indexPath)
        cell.configure(with: cellViewModel)
        cell.delegate = self
        return cell
    }
}

extension FuSectionTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let closeDeal = createTableViewAction(title: "סגור עסקה", image: nil) {
            self.viewModel.didTapMakeDeal(at: indexPath)
        }
        let lock = createTableViewAction(title: "סגור ליד", image: UIImage(systemName: "lock")!) {
            self.viewModel.didTapLockLead(at: indexPath)
        }
        let fuDate = createTableViewAction(title: "שנה תאריך", image: UIImage(systemName: "calendar")) {
            self.viewModel.didTapChangeFuDate(at: indexPath)
        }
        closeDeal.backgroundColor = .gold
        
        return UISwipeActionsConfiguration(actions: [closeDeal, lock, fuDate])
        
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = createTableViewAction(title: "מחק", image: UIImage(systemName: "trash")!) {
            self.viewModel.didTapDelete(at: indexPath)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")!.colored(in: .white)
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension FuSectionTableViewCell: FuTableViewCellDelegate {
    func updateCell() {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
}
