//
//  customPopUpViewController.swift
//  Krokomierz
//
//  Created by Darek on 15/01/2021.
//


import UIKit

class weightDialogViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    let userDef = UserDef()
    var pickerData: [Int]!
    var pickedValue: Double?
    let minNum = 30
    let maxNum = 200
    
    @IBOutlet weak var pickerView: UIPickerView!
    //weak var delegate: SendPickerDataProtocol?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        switch component {
        case 0:
            return NSAttributedString(string: String(pickerData[row]), attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        case 1:
            return NSAttributedString(string: String("kg"), attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        default:
            return nil
        }
        

    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return pickerData.count
        case 1:
            return 1
        default:
            return 0 
        }

    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerData[row])"
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //delegate?.pickerData(data: Double(pickerData[row]))
        pickedValue = Double(pickerData[row])
    }
    convenience init(){
        self.init()
        //pickedValue = userDef.getGoalStepsAmount()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.delegate = self
        pickerView.dataSource = self

        pickerData = Array(stride(from: minNum, to: maxNum + 1, by: 1))
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc func endEditing() {
        view.endEditing(true)
    }

}


//extension RatingViewController: UITextFieldDelegate {
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        endEditing()
//        return true
//    }
//}
