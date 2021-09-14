//
//  SettingsViewController.swift
//  Krokomierz
//
//  Created by Darek on 12/01/2021.
//

import UIKit
import PopupDialog
import Combine


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let viewModel = SettingsViewModel()
    var subscriptions = Set<AnyCancellable>()

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet var tableView: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath) as! settingsCell
        
        switch indexPath.row{
        case 0:
            cell.settingCellMainLabel.text = "Cel dzienny"
            cell.settingCellDescLabel.text = (String(viewModel.goalSteps.value) + " kroków")
        case 1:
            cell.settingCellMainLabel.text = "Płeć"
            switch viewModel.userSex.value {
            case .man:
                cell.settingCellDescLabel.text = "Mężczyzna"
            case .woman:
                cell.settingCellDescLabel.text = "Kobieta"
            }
        case 2:
            cell.settingCellMainLabel.text = "Waga"
            cell.settingCellDescLabel.text = (String(viewModel.userWeight.value) + " kg")
        case 3:
            cell.settingCellMainLabel.text = "Powiadomienia"
            cell.settingCellDescLabel.text = ">"
        default:
            break
        }

        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        switch indexPath.row{
        case 0:
            showGoalStepsPopUp()
        case 1:
            showSexPopUp()
        case 2:
            showWeightPopUp()
        case 3:
            showNotificationSettings()
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        mainView.setGradientBackground(view: mainView)
        
        viewModel.fetchGoalStepsAmount()
        viewModel.fetchUserWeight()
        
        viewModel.goalSteps
            .sink { _ in
                self.tableView.reloadData()
            }.store(in: &subscriptions)
        viewModel.userWeight
            .sink { _ in
                self.tableView.reloadData()
            }.store(in: &subscriptions)
        viewModel.userSex
            .sink { _ in
                self.tableView.reloadData()
            }.store(in: &subscriptions)


    }
    @objc private func showSexPopUp(){
        let sexActionSheet = UIAlertController(title: "Płeć", message: "Podaj swoją płec. Tej informacji używamy do obliczania spalonych kalorii.", preferredStyle: UIAlertController.Style.actionSheet)
        
        //Woman:
        let womanAction = UIAlertAction(title: "Kobieta", style: UIAlertAction.Style.default) { action in
            print("Wybrano: \(action)")
            self.viewModel.changeUserSex(userSex: .woman)
            self.viewModel.fetchUserSex()

        }
        //Man:
        let manAction = UIAlertAction(title: "Meżczyzna", style: UIAlertAction.Style.default) { action in
            print("Wybrano: \(action)")
            self.viewModel.changeUserSex(userSex: .man)
            self.viewModel.fetchUserSex()

        }
        // cancel action button
        let cancelAction = UIAlertAction(title: "Wróc", style: UIAlertAction.Style.cancel) { (action) in
            print("Cancel action button tapped")
        }
        
        sexActionSheet.addAction(womanAction)
        sexActionSheet.addAction(manAction)
        sexActionSheet.addAction(cancelAction)
        
        self.present(sexActionSheet, animated: true, completion: nil)
    }
    func showWeightPopUp(){
        // Create a custom view controller
        let ratingVC = weightDialogViewController(nibName: "weightDialogView", bundle: nil)

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
            self.viewModel.changeUserWeight(newUserWeight: ratingVC.pickedValue ?? 30)
            self.viewModel.fetchUserWeight()
            self.tableView.reloadData()
        }

        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])

        // Present dialog
        present(popup,animated: true, completion: nil)

    }
    func showGoalStepsPopUp(){

        // Create a custom view controller
        let ratingVC = stepsAmountDialogViewController(nibName: "stepsAmountDialogView", bundle: nil)

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
            self.viewModel.changeGoalSetupAmount(newGoalSteps: ratingVC.pickedValue ?? 500)
            self.viewModel.fetchGoalStepsAmount()
            self.tableView.reloadData()
        }

        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])

        // Present dialog
        present(popup,animated: true, completion: nil)

    }
    func showNotificationSettings(){

        // Create a custom view controller
        let ratingVC = notificationDialogViewController(nibName: "notificationDialogView", bundle: nil)

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
            switch ratingVC.notificationSegment.selectedSegmentIndex{
            case 0:
                self.viewModel.getPendingNotification()
                break
            case 1:
                self.viewModel.turnOnNotification()
                break
            default:
                break
            }
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

