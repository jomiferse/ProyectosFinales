import UIKit

class ViewController: UIViewController , UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if textField.isFirstResponder {
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if textField.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var newText: NSString = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        
        if newText.length < 1 {
            
            
        } else {
            
        }
        return true
    }
    
    
    
    @IBAction func tabAction(_ sender: Any) {
        let newText: NSString = textField.text! as NSString
        if newText.length < 1 {
            print("put in the Display Name")
        }
        else {
            
        }
        
    }
    
    
    var pickOption = ["josemi", "luis", "maria"]
    
    var dic1 : Dictionary<String, String> = ["name":"José Miguel", "email":"josemi@correo.com", "uid":"v77OGwTwIZPUBNuvAnYK8J7xUjG3"]
    var dic2 : Dictionary<String, String> = ["name":"Luis", "email":"luis@correo.com", "uid":"H2wo9qEoCoeFnmTmqYsFEOQDNSM2"]
    var dic3 : Dictionary<String, String> = ["name":"María", "email":"maria@correo.com", "uid":"UtKakRYjIcUpP8QwoDe4QpaMK2m2"]
    
    var arrDic = NSMutableDictionary()
    
    
    var pickerView: UIPickerView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        
        pickerView = UIPickerView()
        pickerView.delegate = self
        
        textField.inputView = pickerView
        arrDic.setValue(dic1, forKey: "josemi")
        arrDic.setValue(dic2, forKey: "luis")
        arrDic.setValue(dic3, forKey: "maria")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickOption.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickOption[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = pickOption[row]
        
        switch row {
        case 0:
            FirebaseDataHelper.instance.signIn(email: "josemi@correo.com", password: "123456") {
                self.openChattingView("josemi")
            }
            break;
            
        case 1:
            FirebaseDataHelper.instance.signIn(email: "luis@correo.com", password: "123456") {
                self.openChattingView("luis")
            }
            break;
            
        case 2:
            FirebaseDataHelper.instance.signIn(email: "maria@correo.com", password: "123456") {
                self.openChattingView("maria")
            }
            break;
            
        default:
            break;
        }
        
        self.view.endEditing(true)
    }
    
    func openChattingView(_ name: String) {
        
        let rdic : Dictionary<String, String> = self.arrDic.object(forKey: name) as! Dictionary<String, String>
        
        let ref = FirebaseDataHelper.instance.chatRef.child(FirebaseDataHelper.instance.currentUserUid!)
        
        let data: Dictionary<String, AnyObject> = [
            "name": rdic["name"] as AnyObject,
            "uid": rdic["uid"] as AnyObject,
            "email": rdic["email"] as AnyObject
        ]
        print(ref.key as Any)
        ref.updateChildValues(data) { (err, ref) in
            guard err == nil else {
                print(err as Any)
                return
            }
            
            let data2: Dictionary<String, AnyObject> = [
                "name": rdic["name"] as AnyObject,
                "uid": rdic["uid"] as AnyObject
            ]
            
            let ref2 = FirebaseDataHelper.instance.groupRef.childByAutoId()
            ref2.updateChildValues(data2) { (err, ref3) in
                guard err == nil else {
                    print(err as Any)
                    return
                }
                
                print(ref.key as Any)
                let vc = UIStoryboard(name: "ChatSB",bundle:nil).instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
                vc.groupKey = ref.key
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
