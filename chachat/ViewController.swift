//
//  ViewController.swift
//  chachat
//
//  Created by Amr Adel on 3/19/20.
//  Copyright © 2020 Patatas. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    

    @IBOutlet weak var textField: UITextField!
    var messages: [DataSnapshot]! = [DataSnapshot]()
    
    var ref: DatabaseReference!
    private var _refHandle: DatabaseHandle!
    
    
    @IBOutlet weak var Sender: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        if(Auth.auth().currentUser == nil){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "firebaseLoginViewController")
            self.navigationController?.present(vc!, animated: true, completion: nil)
        }
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        let messageSnap: DataSnapshot = self.messages[indexPath.row]
        let message = messageSnap.value as! Dictionary<String, String>
        if let text = message[Constants.MessagesFields.text] as String?{
            cell.textLabel?.text = text
        }
        if let subText = message[Constants.MessagesFields.sender] {
            cell.detailTextLabel?.text = "Sender: \(subText)  Date: \(message[Constants.MessagesFields.dateTime]!)"
        }

        return cell
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.textField.delegate = self
        ConfigureDatabase()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIResponder.keyboardWillShowNotification, object: self.view.window)
        
    }
    
//    @objc func keyboardWillShow(_ sender: NSNotification){
//        let userInfo: [NSObject:AnyObject]  = (sender ).userInfo! as [NSObject : AnyObject]
//        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.cgRectValue().size
//
//        let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.cgRectValue().size
//        if keyboardSize.height == offset.height {
//            if self.view.frame.origin.y  == 0 {
//                UIView.animate(withDuration: 0.15, animations: {
//                    self.view.frame.origin.y -= keyboardSize.height
//                })
//            }
//        }
//        else{
//            UIView.animate(withDuration: 0.15, animations: {
//                self.view.frame.origin.y -= keyboardSize.height - offset.height
//
//            })
//        }
//
//    }
    
     //Delete Messages ..
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let Removmsg = messages[indexPath.row]
            print("Removed Msg ", Removmsg.key)
            messages.remove(at: indexPath.row)
            self.ref.child("messages").child(Removmsg.key).removeValue()

            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.text?.count == 0){
            return true
        }
        let data = [Constants.MessagesFields.text: textField.text! as String]
        SendMessage(data: data)
        print("Ended Editing!")
        self.view.endEditing(true)
        self.textField.text = ""
        return true
    }
    
    
    func SendMessage(data: [String: String]){
        let userLogged  = Auth.auth().currentUser?.email!
        //Sender.text = userLogged
        var packet = data
        packet[Constants.MessagesFields.dateTime] = Utilities().GetDate()
        packet[Constants.MessagesFields.sender] = userLogged
        self.ref.child("messages").childByAutoId().setValue(packet)
        
    }
    
    
    deinit {
        self.ref.child("messages").removeObserver(withHandle: _refHandle)
    }
    
    func ConfigureDatabase(){
        ref = Database.database().reference()
        _refHandle = self.ref.child("messages").observe(.childAdded, with: {(snapshot) -> Void in
            self.messages.append(snapshot)
            self.tableView.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: .automatic)
        })
        
        
    }
    
    @IBAction func LogOutBtn(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
               do{
                   try firebaseAuth.signOut()
                print("Signed Out")

                if let storyboard = self.storyboard {
                    let vc = storyboard.instantiateViewController(withIdentifier: "firebaseLoginViewController") as! LoginRegisterViewController
                    self.present(vc, animated: false, completion: nil)
                }
               
                
               }
               catch let signOutError as NSError {
                   print("Error signing out!")
               }
               
    }

}

