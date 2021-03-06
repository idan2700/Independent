//
//  MainViewModel.swift
//  Independent
//
//  Created by Idan Levi on 07/01/2022.
//

import Foundation
import Firebase

protocol MainViewModelDelegate: AnyObject {
    func reloadData()
    func presentAlert(message: String)
}

class MainViewModel {
    
    weak var delegate: MainViewModelDelegate?
    private var dateFormatter = DateFormatter()
    private var sections = [Section]()
    
    init(delegate: MainViewModelDelegate?) {
        self.delegate = delegate
    }
    
    func start() {
        sections.append(Section(title: "מצב פיננסי", items: [.finance(viewModel: FinanceTableViewCellViewModel())]))
        sections.append(Section(title: "יעדים", items: [.goals(viewModel: GoalsTableViewCellViewModel())]))
        sections.append(Section(title: "שיחות מעקב להיום", items: [.fu(viewModel: FuSectionTableViewCellViewModel())]))
        delegate?.reloadData()
    }
    
    var userName: String {
        guard let userName = Auth.auth().currentUser?.displayName else {return "שלום, אורח"}
        if userName == "" {
            return "שלום, אורח"
        } else {
        return "\(greetingByTime), \(userName)"
        }
    }
    
    var greetingByTime: String {
        dateFormatter.dateFormat = "HH:mm"
        let date = dateFormatter.string(from: Date())
        if  date >= "05:00" && date < "11:00" {
            return "בוקר טוב"
        } else if date >= "11:00" && date < "16:00" {
            return "צהריים טובים"
        }else if date >= "16:00" && date < "18:00" {
            return "אחה״צ טובים"
        } else if date >= "18:00" && date < "21:00" {
            return "ערב טוב"
        } else {
            return "לילה טוב"
        }
    }
    
    var currentDate: String {
        dateFormatter.dateFormat = "EEEE, d MMMM, yyyy"
        return dateFormatter.string(from: Date())
    }
    
    var numberOfSections: Int {
        return sections.count
    }
    
    func numberOfRaws(at section: Int)-> Int {
        return sections[section].items.count
    }
        
    func getItemForCell(at indexPath: IndexPath)-> MainItem {
        return sections[indexPath.section].items[indexPath.row]
    }
    
    func didPickUpdatedLead(lead: Lead) {
        guard let index = LeadManager.shared.todaysFu.firstIndex(where: {$0.leadID == lead.leadID}) else {return}
        LeadManager.shared.todaysFu[index].fuDate = lead.fuDate
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let updatedDate = lead.fuDate {
            if dateFormatter.string(from: updatedDate) != dateFormatter.string(from: Date()) {
                LeadManager.shared.todaysFu.remove(at: index)
            }
        }
        delegate?.reloadData()
    }
}

struct Section {
    var title: String
    var items: [MainItem]
}

enum MainItem: CaseIterable {
    static var allCases = [MainItem]()
    
    case finance(viewModel: FinanceTableViewCellViewModel)
    case goals(viewModel: GoalsTableViewCellViewModel)
    case fu(viewModel: FuSectionTableViewCellViewModel)
}


