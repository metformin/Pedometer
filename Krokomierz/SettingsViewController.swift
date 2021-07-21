//
//  SettingsViewController.swift
//  Krokomierz
//
//  Created by Darek on 12/01/2021.
//

import UIKit
import PopupDialog


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SendPickerDataProtocol {
    func pickerData(data: Double?) {
        guard let newGoal = data else{return}
        changeGoalStepsAmount(newGoalSteps: newGoal)

    }
    
    @IBOutlet var tableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! settingsCell
        
        cell.settingCellMainLabel.text = "CEL DZIENNY"
        cell.settingCellDescLabel.text = (String(goalSteps) + " kroków")
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        showPopUp()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        
    }
    func showPopUp(){

        // Create a custom view controller
        let ratingVC = customPopUpViewController(nibName: "CustomPopUp", bundle: nil)

        // Create the dialog
        let popup = PopupDialog(viewController: ratingVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: true,
                                panGestureDismissal: false)
        
        // Create first button
        let buttonOne = CancelButton(title: "Anuluj", height: 60) {
        }

        // Create second button
        let buttonTwo = DefaultButton(title: "Zapisz", height: 60) {
            changeGoalStepsAmount(newGoalSteps: ratingVC.pickedValue)
            goalSteps = getGoalStepsAmount()
            self.tableView.reloadData()
        }

        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])

        // Present dialog
        present(popup,animated: true, completion: nil)

    }

    
}

class settingsCell: UITableViewCell{
    @IBOutlet var settingCellMainLabel: UILabel!
    @IBOutlet var settingCellDescLabel: UILabel!
    
}

