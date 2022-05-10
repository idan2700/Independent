//
//  CalenderViewController.swift
//  Independent
//
//  Created by Idan Levi on 28/10/2021.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass
import FSCalendar


class CalendarViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var addEventButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var missionButton: UIButton!
    @IBOutlet weak var noEventsLabel: UILabel!
    @IBOutlet weak var calendarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var addEventButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var addEventButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var closeEventsButtons: UIButton!
    @IBOutlet weak var missionButtonX: NSLayoutConstraint!
    @IBOutlet weak var dealButtonX: NSLayoutConstraint!
    @IBOutlet weak var presentedDayLabel: UILabel!
    var animator: UIViewPropertyAnimator?
    var viewModel: CalendarViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.start()
        calendar.calendarHeaderView.fs_height = 60
        tableViewView.makeTopRoundCorners(radius: 20)
        tableViewView.addShadow(color: UIColor(named: "50gold")!, opacity: 1, radius: 1, size: CGSize(width: -1.1, height: -1.1))
        headerView.makeTopRoundCorners(radius: 20)
        calendar.delegate = self
        calendar.dataSource = self
        dealButton.makeRound()
        missionButton.makeRound()
        tableViewHeight.constant = self.view.frame.height - calendarHeight.constant - 50
        addEventButton.setTitle("", for: .normal)
        closeEventsButtons.setTitle("", for: .normal)
        addEventButton.makeRoundCorners(radius: addEventButton.frame.width / 2)
        tableView.dataSource = self
        tableView.delegate = self
        closeEventsButtons.alpha = 0
        let swipeDownRegongnizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeDown))
        swipeDownRegongnizer.direction = .down
        swipeDownRegongnizer.delegate = self
        headerView.addGestureRecognizer(swipeDownRegongnizer)
        tableViewView.addGestureRecognizer(swipeDownRegongnizer)
        let swipeUpRegongnizer = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeUp))
        swipeUpRegongnizer.direction = .up
        swipeUpRegongnizer.delegate = self
        headerView.addGestureRecognizer(swipeUpRegongnizer)
        tableViewView.addGestureRecognizer(swipeUpRegongnizer)
        viewModel.didSelectDate(date: calendar.selectedDate ?? Date())
        calendar.scope = .week
        calendar.select(Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.start()
    }
    
    @IBAction func didTapAdd(_ sender: UIButton) {
        viewModel.didTapAdd()
    }
    
    @IBAction func didTapCloseEventsButtons(_ sender: UIButton) {
        viewModel.didTapCloseEventsButtons()
    }
    
    @IBAction func didTapAddMission(_ sender: UIButton) {
        viewModel.didTapAddMission()
    }
    
    @IBAction func didTapAddDeal(_ sender: UIButton) {
        viewModel.didTapAddDeal()
    }
    
    
    @objc func handleSwipeDown() {
        calendar.setScope(.month, animated: true)
    }
    
    @objc func handleSwipeUp() {
        calendar.setScope(.week, animated: true)
    }

}

extension CalendarViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
            calendar.fs_height = bounds.height + 10
        self.calendarHeight.constant = bounds.height
        tableViewHeight.constant = self.view.frame.height - calendarHeight.constant - 50
            self.view.layoutIfNeeded()
        }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        viewModel.didSelectDate(date: date)
    }
}
    
extension CalendarViewController: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return viewModel.calendarNumberOfEvents(date: date)
    }
}
extension CalendarViewController: FSCalendarDelegateAppearance {
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance,eventDefaultColorsFor date: Date) -> [UIColor]? {
        return viewModel.calendarEventsColor(date: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        return viewModel.calendarEventsColor(date: date)
    }
}

extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = viewModel.getEvent(at: indexPath)
        switch event {
        case .deal(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "DealCell", for: indexPath) as? DealTableViewCell else {return UITableViewCell()}
            cell.viewModel = viewModel
            cell.configure()
            viewModel.delegate = cell
            cell.delegate = self
            return cell
        case .mission(let viewModel):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MissionCell", for: indexPath) as? MissionTableViewCell else {return UITableViewCell()}
            cell.viewModel = viewModel
            cell.configure()
            viewModel.delegate = cell
            cell.delegate = self
            return cell
        }
    }
}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension CalendarViewController: CalendarViewModelDelegate {
    func selectDateInCalendar(date: Date) {
        self.calendar.select(date)
    }
    

    func moveToCreateMissionVC(currentDate: Date, isNewMission: Bool, existingMission: Event?) {
        let createMissionVC: CreateEventViewController = storyBoard.instantiateViewController()
        createMissionVC.delegate = self
        createMissionVC.viewModel = CreateEventViewModel(delegate: createMissionVC, isLaunchedFromLead: false, isNewEvent: isNewMission, currentDate: currentDate, eventType: .mission)
//        createMissionVC.viewModel = CreateMissionViewModel(delegate: createMissionVC, isNewMission: isNewMission)
        createMissionVC.viewModel.existingEvent = existingMission
        createMissionVC.modalPresentationStyle = .overFullScreen
        self.present(createMissionVC, animated: true) {
            self.viewModel.didTapCloseEventsButtons()
        }
    }
    
    func moveToCreateDealVC(currentDate: Date, isNewDeal: Bool, existingDeal: Event?) {
        let createDealVC: CreateEventViewController = storyBoard.instantiateViewController()
        createDealVC.delegate = self
        createDealVC.viewModel = CreateEventViewModel(delegate: createDealVC, isLaunchedFromLead: false, isNewEvent: isNewDeal, currentDate: currentDate, eventType: .deal)
        createDealVC.viewModel.existingEvent = existingDeal
        createDealVC.modalPresentationStyle = .overFullScreen
        self.present(createDealVC, animated: true) {
            self.viewModel.didTapCloseEventsButtons()
        }
    }
    
    func removeCell(at indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .right)
        tableView.endUpdates()
    }
    
    func setNoEventsLabelState(isHidden: Bool) {
        self.noEventsLabel.isHidden = isHidden
    }
    
    func presentErrorAlert(message: String) {
        self.presentErrorAlert(with: message, buttonAction: nil)
    }
    
    func reloadData() {
        calendar.reloadData()
        tableView.reloadData()
    }
    
    func updatePresentedDayLabel(with date: String) {
        self.presentedDayLabel.text = date
    }
    
    func changeCalendarVisability(toPresent: Bool) {
        if toPresent {
            self.calendar.setScope(.month, animated: true)
        } else {
            self.calendar.setScope(.week, animated: true)
        }
    }
    
    func changeEventsButtonVisability(toPresent: Bool) {
        if toPresent {
            missionButtonX.constant = missionButtonX.constant + 80.0
            dealButtonX.constant = -dealButtonX.constant - 80.0
            UIView.animate(withDuration: 0.2) {
                self.missionButton.transform = CGAffineTransform(rotationAngle: ( Double.pi) * 3)
                self.dealButton.transform = CGAffineTransform(rotationAngle: ( -Double.pi) * 3)
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.addEventButtonWidth.constant = 0
                self.addEventButtonHeight.constant = 0
                UIView.animate(withDuration: 0.1) {
                    self.addEventButton.alpha = 0
                    self.view.layoutIfNeeded()
                } completion: { _ in
                    self.missionButtonX.constant = self.missionButtonX.constant - 40.0
                    self.dealButtonX.constant = self.dealButtonX.constant + 40.0
                    UIView.animate(withDuration: 0.3) {
                        self.missionButton.transform = CGAffineTransform(rotationAngle:  180 * -Double.pi)
                        self.dealButton.transform = CGAffineTransform(rotationAngle: 180 * Double.pi)
                        self.closeEventsButtons.alpha = 1
                        self.view.layoutIfNeeded()
                    }
                }
            }
        } else {
            self.missionButtonX.constant = self.missionButtonX.constant + 40.0
            self.dealButtonX.constant = self.dealButtonX.constant - 40.0
            UIView.animate(withDuration: 0.2) {
                self.missionButton.transform = CGAffineTransform(rotationAngle:  3 * Double.pi)
                self.dealButton.transform = CGAffineTransform(rotationAngle: 3 * -Double.pi)
                self.closeEventsButtons.alpha = 0
                self.view.layoutIfNeeded()
            }  completion: { _ in
                self.addEventButtonWidth.constant = 50
                self.addEventButtonHeight.constant = 50
                UIView.animate(withDuration: 0.2) {
                    self.addEventButton.alpha = 1
                    self.view.layoutIfNeeded()
                } completion: { _ in
                    self.missionButtonX.constant = 0.0
                    self.dealButtonX.constant = 0.0
                    UIView.animate(withDuration: 0.3) {
                        self.missionButton.transform = CGAffineTransform(rotationAngle:  180 * -Double.pi)
                        self.dealButton.transform = CGAffineTransform(rotationAngle: 180 * Double.pi)
                        self.view.layoutIfNeeded()
                    } completion: { _ in
                        UIView.animate(withDuration: 0.1) {
                            self.addEventButton.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
                        } completion: { _ in
                            UIView.animate(withDuration: 0.1) {
                                self.addEventButton.transform = CGAffineTransform.identity
                            }
                        }
                    }
                }
            }
        }
    }
}

extension CalendarViewController: CreateEventViewControllerDelegate {
    func didPick(deal: Deal, isNewDeal: Bool) {
        if isNewDeal {
            viewModel.didPickNewDeal(newDeal: deal)
        } else {
            viewModel.didPickEditedDeal(deal: deal)
        }
    }
    
    func didPick(mission: Mission, isNewMission: Bool) {
        if isNewMission {
            viewModel.didPickNewMission(newMission: mission)
        } else {
            viewModel.didPickEditedMission(mission: mission)
        }
    }
}

extension CalendarViewController: DealTableViewCellDelegate {
    func didTapEdit(cell: DealTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapEditDeal(at: indexPath)
    }
    
    func didTapSendWhatsapp(cell: DealTableViewCell, phone: String) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapSendWhatsapp(at: indexPath, phone: phone)
    }
    
    func didTapCall(cell: DealTableViewCell, phone: String) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapCall(at: indexPath, phone: phone)
    }
    
    func didTapCancelDeal(cell: DealTableViewCell, phone: String) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapCancelDeal(at: indexPath, phone: phone)
    }
    
    func updateCellHeight() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

extension CalendarViewController: MissionTableViewCellDelegate {
    func didTapEdit(cell: MissionTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapEditMission(at: indexPath)
    }
    
    func didTapDelete(cell: MissionTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {return}
        viewModel.didTapDelete(at: indexPath)
    }
    
    func updateCell() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}


