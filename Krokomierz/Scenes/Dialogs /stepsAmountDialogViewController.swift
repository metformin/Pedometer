//
//  customPopUpViewController.swift
//  Krokomierz
//
//  Created by Darek on 15/01/2021.
//


import UIKit

class stepsAmountDialogViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    let userDef = UserDef()
    var pickerData: [Int]!
    var pickedValue: Double?
    
    @IBOutlet weak var pickerView: UIPickerView!
    //weak var delegate: SendPickerDataProtocol?
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: String(pickerData[row]), attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
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
        let minNum = 500
        let maxNum = 50000
        pickerData = Array(stride(from: minNum, to: maxNum + 1, by: 500))
        
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
