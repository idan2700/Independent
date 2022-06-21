//
//  LeadViewController.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import UIKit
import Contacts
import ContactsUI

class LeadViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var monthPickerView: UIView!
    @IBOutlet weak var nextMonthButton: UIButton!
    @IBOutlet weak var lastMonthButton: UIButton!
    @IBOutlet weak var currentMonthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newLeadButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addFromContactsButton: UIButton!
    @IBOutlet weak var addManualyButton: UIButton!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var noLeadsLabel: UILabel!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var addleadButtonsWidth: NSLayoutConstraint!
    @IBOutlet weak var presentByButtonsView: UIStackView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var presentByButtons: [UIButton]!
    @IBOutlet weak var monthViewHeight: NSLayoutConstraint!
    @IBOutlet weak var monthViewTopSpace: NSLayoutConstraint!
    @IBOutlet weak var tableViewView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var viewModel: LeadViewModel!
    
    var tabBarVC: SOTabBarController!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        self.view.addGesture()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.start()
    }
        
    @IBAction func didChangeSegmant(_ sender: UISegmentedControl) {
        viewModel.didChangeSegmant(selectedIndex: sender.selectedSegmentIndex)
    }
    
    @IBAction func didTapNextMonth(_ sender: UIButton) {
        viewModel.didTapNextMonth(currentPresentedMonth: currentMonthLabel.text ?? "")
    }
    
    @IBAction func didTapLastMonth(_ sender: UIButton) {
        viewModel.didTapLastMonth()
    }
    
    @IBAction func didTapCreateNewLead(_ sender: UIButton) {
        viewModel.didTapCreateNewLead()
    }
                       
    @IBAction func didTapAddManualy(_ sender: UIButton) {
        viewModel.didTapAddManualy()
    }
    
    @IBAction func didTapAddFromContacts(_ sender: UIButton) {
        viewModel.didTapAddFromContacts()
    }
    
    @IBAction func didTapPresentBy(_ sender: UIButton) {
        if let titleLabel = sender.titleLabel?.text {
        viewModel.didTapPresentBy(presentByTitle: titleLabel)
        }
    }
    
    private func updateUI() {
        addManualyButton.alpha = 0
        addFromContactsButton.alpha = 0
        buttonView.makeRoundCorners(radius: 10)
        currentMonthLabel.text = viewModel.stringDate
        lastMonthButton.setTitle("", for: .normal)
        nextMonthButton.setTitle("", for: .normal)
        newLeadButton.setTitle("", for: .normal)
        addFromContactsButton.makeBorder(width: 2, color: UIColor(named: "gold")!.cgColor)
        addManualyButton.makeBorder(width: 2, color: UIColor(named: "gold")!.cgColor)
        newLeadButton.makeRound()
        monthPickerView.makeRoundCorners(radius: 10)
        monthView.makeRoundCorners(radius: 10)
        addManualyButton.layer.cornerRadius = 10
        addFromContactsButton.layer.cornerRadius = 10
        collectionViewHeight.constant = (view.frame.width - 31) / 3
        addleadButtonsWidth.constant = 0
        presentByButtonsView.makeRoundCorners(radius: 10)
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            let atrbString = NSAttributedString(string: "חפש ליד", attributes: [.foregroundColor : UIColor(named: "30white")!, .font : UIFont.systemFont(ofSize: 10)])
            textfield.attributedPlaceholder = atrbString
            textfield.textColor = UIColor(named: "50white") ?? .white
        }
        tableViewView.addShadow(color: UIColor(named: "50gold")!, opacity: 1, radius: 1, size: CGSize(width: -1.1, height: -1.1))
        tableViewView.makeTopRoundCorners(radius: 20)
        tableView.makeTopRoundCorners(radius: 20)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(named: "30white")!], for: .normal)
        segmentControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
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
        let width = (view.frame.width - 31) / 3
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
        cell.delegate = self
        cell.configure(with: cellViewModel)
        return cell
    }
}

extension LeadViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let closeDeal = createTableViewAction(title: "סגור עסקה", image: nil) {
            self.viewModel.didTapMakeDeal(at: indexPath)
        }
        let call = createTableViewAction(title: "התקשר", image: UIImage(systemName: "phone")!) {
            self.viewModel.didTapCall(at: indexPath)
        }
        let whatsapp = createTableViewAction(title: "שלח הודעה", image: UIImage(systemName: "envelope")!) {
            self.viewModel.didTapSendWhatsapp(at: indexPath)
        }
        let lock = createTableViewAction(title: "סגור ליד", image: UIImage(systemName: "lock")!) {
            self.viewModel.didTapLockLead(at: indexPath)
        }
        closeDeal.backgroundColor = .gold
        
        if viewModel.currentMonthLeads[indexPath.row].status == .closed {
            return UISwipeActionsConfiguration()
        } else if viewModel.currentMonthLeads[indexPath.row].status == .deal {
            return UISwipeActionsConfiguration(actions: [call, whatsapp])
        } else {
        return UISwipeActionsConfiguration(actions: [closeDeal, call, whatsapp, lock])
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = createTableViewAction(title: "מחק", image: UIImage(systemName: "trash")!) {
            self.viewModel.didTapDelete(at: indexPath)
        }
        delete.backgroundColor = .systemRed
        delete.image = UIImage(systemName: "trash")!.colored(in: .white)
        if viewModel.currentMonthLeads[indexPath.row].status == .closed || viewModel.currentMonthLeads[indexPath.row].status == .deal {
            return UISwipeActionsConfiguration()
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {

        if #available(iOS 13.0, *) {
            for subview in tableView.subviews {
                if NSStringFromClass(type(of: subview)) == "_UITableViewCellSwipeContainerView" {
                    for swipeContainerSubview in subview.subviews {
                        if NSStringFromClass(type(of: swipeContainerSubview)) == "UISwipeActionPullView" {
                            for case let button as UIButton in swipeContainerSubview.subviews {
                                button.titleLabel?.font = .systemFont(ofSize: 12)
                                button.setTitleColor(.black, for: .normal)
                            }
                        }
                    }
                }
            }
        } else {
            for subview in tableView.subviews {
                if NSStringFromClass(type(of: subview)) == "UISwipeActionPullView" {
                    for case let button as UIButton in subview.subviews {
                        button.titleLabel?.font = .systemFont(ofSize: 12)
                        button.setTitleColor(.black, for: .normal)
                    }
                }
            }
        }
     }
}

extension LeadViewController: CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        picker.dismiss(animated: true) {
            self.viewModel.didSelectContact(contact: contact)
        }
    }
}

extension LeadViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let text = searchBar.text {
            viewModel.didSearchForLead(text: text)
        }
    }
}

extension LeadViewController: LeadViewModelDelegate {
    func moveToFuDate(lead: Lead) {
        let fuDateVC: FuDateViewController = storyBoard.instantiateViewController()
        fuDateVC.delegate = self
        fuDateVC.viewModel = FuDateViewModel(delegate: fuDateVC, lead: lead)
        fuDateVC.modalPresentationStyle = .overFullScreen
        self.present(fuDateVC, animated: true, completion: nil)
    }
    
   
    func moveToCreateDealVC(lead: Lead) {
        let createDealVC: CreateEventViewController = storyBoard.instantiateViewController()
        createDealVC.viewModel = CreateEventViewModel(delegate: createDealVC, isLaunchedFromLead: true, isNewEvent: true, currentDate: Date(), eventType: .deal)
        createDealVC.viewModel.name = lead.fullName
        createDealVC.viewModel.phone = lead.phoneNumber
        createDealVC.modalPresentationStyle = .overFullScreen
        self.present(createDealVC, animated: true, completion: nil)
    }
    
    func presentUpdatedCell(lead: Lead) {
        guard let index = viewModel.currentMonthLeads.firstIndex(where: {$0.leadID == lead.leadID}) else {return}
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? LeadTableViewCell else {return}
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        cell.cellView.glowOnce()
    }
    
    func moveToEditSummryLeadVC(with lead: Lead, indexPath: IndexPath) {
        let editSummryVC: EditLeadSummryViewController = storyBoard.instantiateViewController()
        editSummryVC.viewModel = EditLeadSummryViewModel(lead: lead, delegate: editSummryVC, indexPath: indexPath)
        editSummryVC.delegate = self
        editSummryVC.modalPresentationStyle = .overFullScreen
        self.present(editSummryVC, animated: true, completion: nil)
    }
    
    func changePresentByButtonUI(currentSelectedButton: String) {
        for button in presentByButtons {
            if button.titleLabel?.text == currentSelectedButton {
                button.backgroundColor = UIColor(named: "10white") ?? .white
                button.tintColor = UIColor(named: "gold") ?? .white
            } else {
                button.backgroundColor = UIColor(named: "5white") ?? .white
                button.tintColor = UIColor(named: "30white") ?? .white
            }
        }
    }
    
    func moveToContactsVC() {
        let ContactsVC = CNContactPickerViewController()
        ContactsVC.delegate = self
        ContactsVC.modalPresentationStyle = .overFullScreen
        self.present(ContactsVC, animated: true, completion: nil)
    }
    
    func changeNewLeadButtonState(isEnabled: Bool) {
        newLeadButton.isEnabled = isEnabled
        addManualyButton.isEnabled = isEnabled
        addFromContactsButton.isEnabled = isEnabled
    }
    
    func setNextMonthButtonState(isHidden: Bool) {
        nextMonthButton.isHidden = isHidden
    }
    
    func removeCell(at indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .right)
        tableView.endUpdates()
    }
    
    func setNoLeadsLabelState(isHidden: Bool) {
        noLeadsLabel.isHidden = isHidden
    }
    
    func presentErrorAlert(message: String) {
        self.presentErrorAlert(with: message)
    }
    
    func reloadData() {
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    func updateCurrentMonthLabel() {
        currentMonthLabel.text = viewModel.stringDate
    }
    
    func moveToCreateLeadVC(name: String?, phone: String?) {
        let createLeadVC: CreateLeadViewController = storyBoard.instantiateViewController()
        createLeadVC.modalPresentationStyle = .overFullScreen
        createLeadVC.delegate = self
        createLeadVC.viewModel = CreateLeadViewModel(delegate: createLeadVC, leads: viewModel.currentMonthLeads)
        createLeadVC.viewModel.nameFromContact = name
        createLeadVC.viewModel.phoneFromContact = phone
        self.present(createLeadVC, animated: true, completion: nil)
    }
    
    func changeCreateLeadButtonsVisability(toPresent: Bool) {
        if toPresent {
            addleadButtonsWidth.constant = 150
            UIView.animate(withDuration: 0.5) {
                self.newLeadButton.transform = CGAffineTransform(rotationAngle: -150)
                self.addManualyButton.alpha = 1
                self.addFromContactsButton.alpha = 1
                self.view.layoutIfNeeded()
            }
        } else {
            addleadButtonsWidth.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.newLeadButton.transform = CGAffineTransform(rotationAngle: ( -Double.pi) * 3)
                self.addManualyButton.alpha = 0
                self.addFromContactsButton.alpha = 0
                self.view.layoutIfNeeded()
            }
        }
    }

    func changeMonthlyViewVisability(toPresent: Bool) {
        if toPresent {
            monthViewHeight.constant = 40
            monthViewTopSpace.constant = 10
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
            monthViewHeight.constant = 0
            monthViewTopSpace.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func addNewLeadToTableView() {
        self.tableView.beginUpdates()
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .right)
        self.tableView.endUpdates()
        guard let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LeadTableViewCell else {return}
        cell.cellView.glowOnce()
    }
}

extension LeadViewController: LeadTableViewCellDelegate {
    func didTapFu(cell: LeadTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapFu(at: indexPath)
    }
    
    func didTapEditSummry(cell: LeadTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapEditLeadSummry(at: indexPath)
    }
    
    func didTapOpenLead(cell: LeadTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapOpenLead(at: indexPath)
    }
    
    func didTapMakeDeal(cell: LeadTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapMakeDeal(at: indexPath)
    }
    
    func didTapInfo(cell: LeadTableViewCell, isInfoButtonOpen: Bool) {
        self.tableView.beginUpdates()
        cell.configureCellExpend(toExpand: isInfoButtonOpen ? false : true)
        self.tableView.endUpdates()
    }
}

extension LeadViewController: CreateLeadViewControllerDelegate {
    func didPick(newLead: Lead) {
        viewModel.didPickNewLead(lead: newLead)
    }
}

extension LeadViewController: EditLeadSummryViewControllerDelegate {
    func didPick(updatedLead: Lead, indexPath: IndexPath) {
        viewModel.didPickUpdatedLead(lead: updatedLead, indexPath: indexPath)
    }
}

extension LeadViewController: FuDateViewControllerDelegate {
    func didPick(updatedLead: Lead) {
        guard let index = viewModel.currentMonthLeads.firstIndex(where: {$0.leadID == updatedLead.leadID}) else {return}
        let indexPath = IndexPath(row: index, section: 0)
        viewModel.didPickUpdatedLead(lead: updatedLead, indexPath: indexPath)
    }
}


