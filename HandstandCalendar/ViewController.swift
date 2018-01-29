//
//  ViewController.swift
//  HandstandCalendar
//
//  Created by Andrei Oltean on 1/22/18.
//  Copyright © 2018 Handstand. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController {

    @IBOutlet weak var selectedDateLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendar: JTAppleCalendarView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var expandingView: UIView!
    @IBOutlet var filterButtons: [UIButton]!
    
    fileprivate var selectedButton: UIButton?
    fileprivate var previousTouchPoint: CGPoint?
    
    fileprivate var selectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        calendar.minimumLineSpacing = 1.0
        calendar.minimumInteritemSpacing = 0.0
        
        calendar.scrollToDate(selectedDate)
        calendar.selectDates([selectedDate])
    }
    
    @IBAction func didSelectFilter(_ sender: UIButton) {
        if let button = selectedButton {
            button.backgroundColor = #colorLiteral(red: 0.7019607843, green: 0.7019607843, blue: 0.7019607843, alpha: 1)
        }
        sender.backgroundColor = #colorLiteral(red: 0.3529411765, green: 0.7764705882, blue: 0.5725490196, alpha: 1)
        selectedButton = sender
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func set(cell: DateCell, cellState: CellState, hasEvents: Bool) {
        if cellState.dateBelongsTo != .thisMonth {
            cell.selectedView.isHidden = true
            cell.dateLabel.textColor = UIColor.clear
            cell.eventsView.isHidden = true
        } else {
            if cellState.isSelected {
                cell.selectedView.isHidden = false
                cell.dateLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            } else {
                cell.selectedView.isHidden = true
                cell.dateLabel.textColor = #colorLiteral(red: 0.3725490196, green: 0.3725490196, blue: 0.3725490196, alpha: 1)
            }
            if hasEvents {
                cell.eventsView.isHidden = false
            } else {
                cell.eventsView.isHidden = true
            }
        }
    }
    
    @IBAction func didPanExpandingView(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            previousTouchPoint = sender.location(in: view)
        } else if sender.state == .changed {
            let currentTouchPoint = sender.location(in: view)
            if currentTouchPoint.y > view.frame.origin.y {
                if let previousTouchPoint = previousTouchPoint {
                    let heightDifference = currentTouchPoint.y - previousTouchPoint.y
                    if collectionViewHeightConstraint.constant + heightDifference <= 280 {
                        if collectionViewHeightConstraint.constant + heightDifference >= 0 {
                            collectionViewHeightConstraint.constant += heightDifference
                        } else {
                            collectionViewHeightConstraint.constant = 0
                        }
                        self.view.layoutIfNeeded()
                    }
                }
            }
            previousTouchPoint = currentTouchPoint
        } else if sender.state == .ended {
            let velocity = sender.velocity(in: view)
            if velocity.y <= -800 {
                self.collectionViewHeightConstraint.constant = 0
            } else if velocity.y >= 800 {
                self.collectionViewHeightConstraint.constant = 280
            } else {
                if self.collectionViewHeightConstraint.constant >= (280 / 2) {
                    self.collectionViewHeightConstraint.constant = 280
                } else {
                    self.collectionViewHeightConstraint.constant = 0
                }
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
}

extension ViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd"
        
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        let startDate = dateFormatter.date(from: "\(Calendar.current.component(.year, from: Date()) - 3) 01 01")!
        let endDate = dateFormatter.date(from: "\(Calendar.current.component(.year, from: Date()) + 3) 12 31")!
        
        let configParameters = ConfigurationParameters(startDate: startDate, endDate: endDate, generateOutDates: .tillEndOfRow, firstDayOfWeek: DaysOfWeek.monday)
        return configParameters
    }
}

extension ViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        if let calendarCell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "DateCell", for: indexPath) as? DateCell {
            calendarCell.dateLabel.text = cellState.text
            set(cell: calendarCell, cellState: cellState, hasEvents: true)
            return calendarCell
        }
        return JTAppleCell()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        if let calendarCell = cell as? DateCell {
            calendarCell.dateLabel.text = cellState.text
            set(cell: calendarCell, cellState: cellState, hasEvents: true)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        selectedDateLabel.text = dateFormatter.string(from: date)
        
        let monthDateFormatter = DateFormatter()
        monthDateFormatter.dateFormat = "MMMM"
        
        monthLabel.text = monthDateFormatter.string(from: date).uppercased()
        if let calendarCell = cell as? DateCell {
            set(cell: calendarCell, cellState: cellState, hasEvents: true)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        if let calendarCell = cell as? DateCell {
            set(cell: calendarCell, cellState: cellState, hasEvents: true)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        if cellState.dateBelongsTo == .thisMonth {
            return true
        } else {
            return false
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"

        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale

        let monthDate = visibleDates.monthDates[0].date
        
        monthLabel.text = dateFormatter.string(from: monthDate).uppercased()
    }
}
