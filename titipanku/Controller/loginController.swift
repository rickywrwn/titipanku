//
//  loginController.swift
//  titipanku
//
//  Created by Ricky Wirawan on 27/03/18.
//  Copyright © 2018 Ricky Wirawan. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import Alamofire
import SwiftyJSON

class loginController: UIViewController , GIDSignInUIDelegate , FBSDKLoginButtonDelegate, GIDSignInDelegate {
    var cekLogged : Bool = UserDefaults.standard.bool(forKey: "logged")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.window?.rootViewController?.dismiss(animated: true, completion: nil)
            (appDelegate.window?.rootViewController as? UINavigationController)?.popToRootViewController(animated: true)
            
            print("logout")
            
        }
        // Do any additional setup after loading the view, typically from a nib.
        GIDSignIn.sharedInstance().uiDelegate = self
        setupLayout()
       
        //google sign in
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        //print("TESTING = \(cekLogged)")
        
        //cek sudah login
        if  cekLogged == true{
            handleSegueFacebook()
        }
    }
    
    //facebook login
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Log out facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        
//        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id, name, email"]).start{
//            (connection, result, err) in
//            
//            if err != nil{
//                print("failed to start graph request", err)
//                return
//            }
//            print(result)
//        }
        let accesTokenFB = FBSDKAccessToken.current()
        guard let accessTokenFBString = accesTokenFB?.tokenString else {return}
        let credentialFB = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        Auth.auth().signIn(with: credentialFB) { (user, errfb) in
            if let errfb = errfb {
                print("firebase fb error", errfb)
                return
            }
            // User is signed in
            let userfb = Auth.auth().currentUser
            print("firebase FB sukses", userfb?.email)
            let parameters: Parameters = ["email": userfb?.email, "action" : "facebook"]
            Alamofire.request("http://titipanku.xyz/api/Login.php",method: .post, parameters: parameters)
            self.handleSegueFacebook()
        }
    }
    //akhir facebook login
    
    //google sign in
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let err = error {
            print("Login Failed : ", err)
            return
        }
        print("Login Google Success", user)
        
        //firebase
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Firebase error", error)
                return
            }
            guard let uid = user?.email else {return}
            print("Firebase sukses", uid)
            let parameters: Parameters = ["email": uid, "action" : "google"]
            Alamofire.request("http://titipanku.xyz/api/Login.php", method: .post, parameters: parameters)
            //Alamofire.request("http://localhost/titipankuu/Login.php", method: .post, parameters: parameters)
            self.handleSegueFacebook()
        }
    }
    //end google sign in
    
    
    @objc func handleSegueRegister(){
        perform(#selector(showRegisterPage), with: nil, afterDelay: 0.01)
    }
    
    @objc func showRegisterPage(){
        let register = registerController()
        present(register, animated: true, completion: {
            //perhaps we'll do something here later
        })
    }
    
    //pindah ke home setelah login
    @objc func handleSegueFacebook(){
        perform(#selector(showHome), with: nil, afterDelay: 0.01)
    }
    
    @objc func showHome(){
        self.dismiss(animated: true)
    }
    // end
    
    //sign out firebase
    @objc private func handleSignOut(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("Firebase Signout")
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    //login
    @objc func handleLogin(){
        let parameters: Parameters = ["email": usernameTextField.text!,"password": passwordTextField.text!, "action" : "login"]
        Alamofire.request("http://titipanku.xyz/api/Login.php",method: .get, parameters: parameters).responseJSON {
            response in
            
            //mencetak JSON response
            if let json = response.result.value {
                print("JSON: \(json)")
            }
            
            //mengambil json
            let json = JSON(response.result.value)
            let cekSukses = json["success"].intValue
            let pesan = json["message"].stringValue
            
            if cekSukses != 1 {
                let alert = UIAlertController(title: "Message", message: pesan, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
                
                self.present(alert, animated: true)
            }else{
                let alert = UIAlertController(title: "Message", message: pesan, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                UserDefaults.standard.set(true, forKey:"logged")
                UserDefaults.standard.set(self.usernameTextField.text!, forKey:"loggedEmail")
                UserDefaults.standard.synchronize()
                print(self.usernameTextField.text!)
                    
                self.showHome()
            }))
                
                self.present(alert, animated: true)
            }
            
            //            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
            //                print("Data: \(utf8Text)") // original server data as UTF8 string
            //            }
        }
    }
    
    //tampilan
    let usernameTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.borderStyle = .roundedRect
        textField.placeholder = "Email"
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let passwordTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let loginButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleLogin), for: UIControlEvents.touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    let registerButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Register", for: .normal)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleSegueRegister), for: UIControlEvents.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let googleSignInButton : GIDSignInButton = {
        let signInButton = GIDSignInButton(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        return signInButton
    }()
    
    let facebookSignInButton : FBSDKLoginButton = {
        let fbSignInButton = FBSDKLoginButton(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        fbSignInButton.translatesAutoresizingMaskIntoConstraints = false
        // fbSignInButton.delegate = self
        fbSignInButton.readPermissions = ["email"]
        return fbSignInButton
    }()
    
    let googleSignOutButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Out !", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .red
        button.addTarget(self, action: #selector(handleSignOut), for: UIControlEvents.touchDown)
        button.setTitleColor(.gray, for: .normal)
        return button
    }()
    
    
    
    private func setupLayout(){
        view.backgroundColor = .white
        
        //usernameTextField
        view.addSubview(usernameTextField)
        usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usernameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        usernameTextField.font = UIFont.systemFont(ofSize: 25)
        usernameTextField.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        usernameTextField.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        usernameTextField.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 200).isActive = true
        
        //passwordTextField
        view.addSubview(passwordTextField)
        passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        passwordTextField.font = UIFont.systemFont(ofSize: 25)
        passwordTextField.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        passwordTextField.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        passwordTextField.topAnchor.constraint(greaterThanOrEqualTo: usernameTextField.bottomAnchor, constant: 30).isActive = true
        
        //loginButton
        view.addSubview(loginButton)
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        loginButton.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 120).isActive = true
        loginButton.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 120).isActive = true
        loginButton.topAnchor.constraint(greaterThanOrEqualTo: passwordTextField.bottomAnchor, constant: 30).isActive = true
        
        //registerButton
        view.addSubview(registerButton)
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        registerButton.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 120).isActive = true
        registerButton.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 120).isActive = true
        registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 15).isActive = true
        
        //googleSignInButton
        view.addSubview(googleSignInButton)
        googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        googleSignInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        googleSignInButton.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 120).isActive = true
        googleSignInButton.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 120).isActive = true
        googleSignInButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 15).isActive = true
 
        //fbSignInButton
        view.addSubview(facebookSignInButton)
        facebookSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        facebookSignInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        facebookSignInButton.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 120).isActive = true
        facebookSignInButton.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 120).isActive = true
        facebookSignInButton.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 15).isActive = true
        
        //googleSignOutButton
        view.addSubview(googleSignOutButton)
        googleSignOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        googleSignOutButton.topAnchor.constraint(equalTo: facebookSignInButton.bottomAnchor, constant: 30).isActive = true
        
       

    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
