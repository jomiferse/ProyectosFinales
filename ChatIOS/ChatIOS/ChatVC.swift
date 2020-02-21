import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import QuartzCore

class ChatVC: UIViewController,UITextFieldDelegate {

    @IBOutlet var bottomConst: NSLayoutConstraint!
    @IBOutlet var txtMsg: UITextField!
    @IBOutlet var tblChat: UITableView!
    
    var dict:NSDictionary!
    let arrMsg = NSMutableArray()
    let arrMsgin = NSMutableArray()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomConst.constant = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.fetchMessages()
        self.startTimer()
    }
    
    var participantId: String?
    var username: String?
    
    var groupKey: String? {
        didSet {
            if let key = groupKey {
                fetchMessages()
                FirebaseDataHelper.instance.chatRef.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let data = snapshot.value as? Dictionary<String, AnyObject> {
                        if let title = data["name"] as? String {
                            self.title = title
                            self.username = title
                        }
                        if let toId = data["uid"] as? String {
                            self.participantId = toId
                        }
                        
                        self.startTimer()
                    }
                })
                
            }
        }
    }
    
    
    func fetchMessages() {
        
        FirebaseDataHelper.instance.messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists()
            {
                if let msgPost = snapshot.value as? Dictionary<String,AnyObject>
                {
                    for(key, value) in msgPost {
                        
                        let dict = NSMutableDictionary()
                        dict.setObject(key, forKey:"messageChildById" as NSCopying)
                        dict.setObject(value, forKey:"value" as NSCopying)
                        self.arrMsgin.add(dict)
                        
                        let dict2 = NSMutableDictionary()
                        dict2.setObject(value["fromUserId"] as Any, forKey: "fromUserId" as NSCopying)
                        dict2.setObject(value["text"] as Any, forKey: "text" as NSCopying)
                        dict2.setObject(value["timestamp"] as Any, forKey: "timestamp" as NSCopying)
                        dict2.setObject(value["name"] as Any, forKey: "name" as NSCopying)
                        
                        self.arrMsg.add(dict2)
                        self.tblChat.reloadData()
                        self.tblChat.separatorStyle = .none
                        self.scrollToBottom()
                        
                    }
                }
                print("self.arrUserList")
            }
            
        })
        
        
    }
    
    
    func receivefetchcompare(dic: NSMutableDictionary) -> Bool {
        
        for childById in (self.arrMsgin as NSMutableArray as! [NSMutableDictionary]) {
            print(dic.object(forKey: "messageChildById") as Any)
            print(childById.object(forKey: "messageChildById") as Any)
            
            let a = dic.object(forKey: "messageChildById") as! String
            let b = childById.object(forKey: "messageChildById") as! String
            
            if a == b {
                return true
            }
        }
        return false
        
    }
    
    func fetchappendMessages() {
        
        FirebaseDataHelper.instance.messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.exists()
            {
                if let msgPost = snapshot.value as? Dictionary<String,AnyObject>
                {
                    for(key, value) in msgPost {
                        
                        let dict = NSMutableDictionary()
                        dict.setObject(key, forKey:"messageChildById" as NSCopying)
                        dict.setObject(value, forKey:"value" as NSCopying)
                        
                        if self.receivefetchcompare(dic: dict) {
                            print("receivefetchcompare true = ", self.receivefetchcompare(dic: dict))
                        }
                        else {
                            print("receivefetchcompare false = ", self.receivefetchcompare(dic: dict))
                            self.arrMsgin.add(dict)
                            
                            let dict2 = NSMutableDictionary()
                            dict2.setObject(value["fromUserId"] as Any, forKey: "fromUserId" as NSCopying)
                            dict2.setObject(value["text"] as Any, forKey: "text" as NSCopying)
                            dict2.setObject(value["timestamp"] as Any, forKey: "timestamp" as NSCopying)
                            dict2.setObject(value["name"] as Any, forKey: "name" as NSCopying)
                            self.arrMsg.add(dict2)
                            self.tblChat.reloadData()
                            self.tblChat.separatorStyle = .none
                            self.scrollToBottom()
                        }
                        print("\n")
                        

                    }
                }
                print("self.arrUserList")
            }
            
        })
        
        
    }


    @IBAction func btnActionMsgSend(_ sender: Any) {
        if (txtMsg.text == "" || txtMsg.text == " ") {
            let alert = UIAlertController(title: "Alert", message: "Please type a Message", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else{

            let ref = FirebaseDataHelper.instance.messageRef.childByAutoId()
            guard let fromUserId = FirebaseDataHelper.instance.currentUserUid else {
                return
            }
            
            let data: Dictionary<String, AnyObject> = [
                "fromUserId": fromUserId as AnyObject,
                "text": txtMsg.text! as AnyObject,
                "timestamp": NSNumber(value: Date().timeIntervalSince1970),
                "name" : self.username! as AnyObject
            ]
            
            ref.updateChildValues(data) { (err, ref) in
                guard err == nil else {
                    print(err as Any)
                    return
                }
                
                let dict = NSMutableDictionary()
                dict.setObject(ref.key as Any, forKey:"messageChildById" as NSCopying)
                dict.setObject(data, forKey:"value" as NSCopying)
                self.arrMsgin.add(dict)
                
                let dict2 = NSMutableDictionary()
                dict2.setObject(data["fromUserId"] as Any, forKey: "fromUserId" as NSCopying)
                dict2.setObject(data["text"] as Any, forKey: "text" as NSCopying)
                dict2.setObject(data["timestamp"] as Any, forKey: "timestamp" as NSCopying)
                dict2.setObject(data["name"] as Any, forKey: "name" as NSCopying)
                
                self.arrMsg.add(dict2)
                self.txtMsg.text = nil
                self.tblChat.reloadData()
                self.txtMsg.text = " "
            
            }
            
        }
    }
   
    
    @objc func update(){
        
        print("update")
        
        self.fetchappendMessages()
    }
    
    func stopTimer(){
        self.timer?.invalidate()
        self.timer = nil
    }
    
    
    
    func getCurrentTimeStamp() -> String {
            return "\(Double(NSDate().timeIntervalSince1970 * 1000))"
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.arrMsg.count-1, section: 0)
            self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            bottomConst.constant = (keyboardSize.height) * -1.0
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            bottomConst.constant = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtMsg.resignFirstResponder()
        return true
    }
    
    var timer:Timer?
    var count = 0
    
    func startTimer(){
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
   
    
}
extension ChatVC: UITableViewDataSource, UITableViewDelegate{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMsg.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dict1 = arrMsg.object(at: indexPath.row) as! NSDictionary
        
        if((String(describing: dict1.object(forKey: "fromUserId")!)) == FirebaseDataHelper.instance.currentUserUid){
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "Cell2") as! Chat2TableViewCell
            cell2.lblSender.text = (dict1.object(forKey: "text") as! String)
            cell2.lblSender.backgroundColor = UIColor(red: 221/255, green: 234/255, blue: 253/255, alpha: 1)
            cell2.lblSender.font = UIFont.systemFont(ofSize: 20)
            cell2.lblSender.textColor = UIColor(displayP3Red: 20/255, green: 20/255, blue: 20/255, alpha: 1)
            cell2.lblSender?.layer.masksToBounds = true
            cell2.lblSender.layer.cornerRadius = 7
            return cell2
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! ChatTableViewCell
            cell.lblReceiver.text = (dict1.object(forKey: "text") as! String)
            cell.lblReceiver.backgroundColor = UIColor.lightGray
            cell.lblReceiver.font = UIFont.systemFont(ofSize: 20)
            cell.lblReceiver.textColor = UIColor(red: 22/255, green: 22/255, blue: 23/255, alpha: 1)
            cell.lblReceiver?.layer.masksToBounds = true
            cell.lblReceiver.layer.cornerRadius = 7
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
