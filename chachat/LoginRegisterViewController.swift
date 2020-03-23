//
//  LoginRegisterViewController.swift
//  chachat
//
//  Created by Amr Adel on 3/20/20.
//  Copyright © 2020 Patatas. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginRegisterViewController: UIViewController {
    //Amrao
    @IBOutlet weak var usersLabel: UILabel!
    var users: [DataSnapshot]! = [DataSnapshot]()

    var ref: DatabaseReference!
    private var _refHandle: DatabaseHandle!

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginRegisterViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        ConfigureDatabase()
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func loginClicked(_ sender: UIButton) {
        if((emailTextField.text!.count) < 5){
            emailTextField.backgroundColor = UIColor.red
            return
        }else{
            emailTextField.backgroundColor = UIColor.white

        }
        
        if((passwordTextField.text!.count) < 5){
            passwordTextField.backgroundColor = UIColor.red
            return
            }
        else{
            passwordTextField.backgroundColor = UIColor.white

        }
        
        let email = emailTextField.text
        let password = passwordTextField.text
        
        Auth.auth().signIn(withEmail: email!, password: password!, completion: {(user, error) in
            if let error = error {
                Utilities().ShowAlert(title: "Error", message: error.localizedDescription, vc: self )
                print(error.localizedDescription)
                return
            }
            print("signed In!")
            self.dismiss(animated: true, completion: nil)

         })
        
       
    }
    
    @IBAction func registerClicked(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Register", message: "Please Confirm Password", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "password"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
            let passConfirm = alert.textFields![0] as UITextField
            if(passConfirm.text!.isEqual(self.passwordTextField.text!)){
                
                //Registration Begins
                let email = self.emailTextField.text
                let password = self.passwordTextField.text
                self.SendUser(data: email!)
                Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
                    if let error = error{
                        Utilities().ShowAlert(title: "Error", message: error.localizedDescription, vc: self )
                        print(error.localizedDescription)
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
                }
            }
            else{
                Utilities().ShowAlert(title: "Error", message: "Password not the same", vc: self) }
        }))
   
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func forgetClicker(_ sender: UIButton) {
        if(!emailTextField.text!.isEmpty){
            let email = self.emailTextField.text
            
            Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
                if let error = error {
                    Utilities().ShowAlert(title: "Error", message: error.localizedDescription, vc: self)
                    return
                }
                Utilities().ShowAlert(title: "Success", message: "Please Check ur Email", vc: self)
            }
        }
    }
    
    //Amrao
    func SendUser(data: String){
        let packet = data
        self.ref.child("users").childByAutoId().setValue(packet)
        
    }
    
    func ConfigureDatabase(){
        ref = Database.database().reference()
        _refHandle = self.ref.child("users").observe(.childAdded, with: {(snapshot) -> Void in
            self.users.append(snapshot)
            self.usersLabel.text = "Number of Registered Users:  \(String(self.users.count))"
            //self.tableView.insertRows(at: [IndexPath(row: self.messages.count-1, section: 0)], with: .automatic)
        })
        
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
