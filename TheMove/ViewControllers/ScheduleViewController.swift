//
//  ScheduleViewController.swift
//  TheMove
//
//  Created by User 2 on 4/8/19.
//  Copyright © 2019 User 2. All rights reserved.
//

import UIKit
import DropDown


class ScheduleViewController: UIViewController,UITextViewDelegate {

    @IBOutlet weak var dateAndTimeField: UITextField!
    
    @IBOutlet weak var messageBtn: UIButton!
    @IBOutlet weak var msgView: UITextView!
    let DatePickerView: UIDatePicker = UIDatePicker()
    
    @IBOutlet weak var messageFiled: UITextField!
    let amountDropDown = DropDown()
    
    var hotelName : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.navigationItem.title = "Schedule"
        
        messageBtn.contentHorizontalAlignment = .left
        SetLeftSIDEImage(TextField: dateAndTimeField, ImageName: "")
        
        DatePickerView.datePickerMode = UIDatePicker.Mode.dateAndTime
        self.DatePickerView.minimumDate = Date()
        dateAndTimeField.inputView = DatePickerView

        DatePickerView.addTarget(self, action: #selector(handleDatePicker), for: UIControl.Event.valueChanged)

        dateAndTimeField.returnKeyType = UIReturnKeyType.done
        
        self.addDoneButtonOnKeyboard()
        
        msgView.delegate = self
        msgView.text = "Tell Us Something"
        msgView.textColor = UIColor.lightGray
        
        msgView.layer.borderColor = UIColor.black.cgColor
        
        msgView.layer.borderWidth = 1.0
        
        
        messageBtn.layer.borderColor = UIColor.black.cgColor
        
        messageBtn.layer.borderWidth = 1.0
        
        amountDropDown.anchorView = messageBtn
        
        amountDropDown.bottomOffset = CGPoint(x: 0, y: messageBtn.bounds.height)
        
        // By default, the dropdown will have its origin on the top left corner of its anchor view
        // So it will come over the anchor view and hide it completely
        // If you want to have the dropdown underneath your anchor view, you can do this:
     //  amountDropDown.bottomOffset = CGPoint(x: 0, y: 10)
        
        // You can also use localizationKeysDataSource instead. Check the docs.
        amountDropDown.dataSource = [
            "a relaxing dinner With you",
            "a relaxing dinner With all  My friends"
        
        ]
        
        // Action triggered on selection
        amountDropDown.selectionAction = { [weak self] (index, item) in
            self?.messageBtn.setTitle(item, for: .normal)
        }
 
    }
    @IBAction func messageBtnAction(_ sender: Any) {
        
        amountDropDown.show()
        
        
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .long
        timeFormatter.timeStyle = .short
        
        dateAndTimeField.text = timeFormatter.string(from: sender.date)
    }
    
    @objc func done (){
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .long
        timeFormatter.timeStyle = .short
        
        dateAndTimeField.text = timeFormatter.string(from: DatePickerView.date)
        
        dateAndTimeField.resignFirstResponder()
    }

    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.done))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.dateAndTimeField.inputAccessoryView = doneToolbar
        
    }
   
    func SetLeftSIDEImage(TextField: UITextField, ImageName: String){
        
        let leftImageView = UIImageView()
        leftImageView.contentMode = .scaleAspectFit
        
        let leftView = UIView()
        
        leftView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        leftImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 25)
        TextField.leftViewMode = .always
        TextField.leftView = leftView
        
        let image = UIImage(named: ImageName)
        leftImageView.image = image

        
        leftView.addSubview(leftImageView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            
            textView.text = "Placeholder text ..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"  // Recognizes enter key in keyboard
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    @IBAction func sendIngBtnAction(_ sender: Any) {
        
        if dateAndTimeField.text != "" && (messageBtn.titleLabel?.text != "Message" || msgView.text != ""){
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SendToFriendListViewController") as? SendToFriendListViewController
        
        if  messageBtn.titleLabel?.text != "Message " {
           
            if let text = messageBtn.titleLabel?.text {
                vc?.messageStr = dateAndTimeField.text! + " \(text)"
            }
            
          
        }else{
            if let text = msgView.text {
                
              vc?.messageStr = dateAndTimeField.text! + "  \(text)"
                
                }
            
            }
       
        self.navigationController?.pushViewController(vc!, animated: true)
        
        }else{
            
            self.alert(message: "Please Fill the Details", title: "Oops")
        }
    }
}
