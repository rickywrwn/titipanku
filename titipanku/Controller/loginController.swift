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
//import FBSDKLoginKit
import Alamofire
import SwiftyJSON
import FacebookLogin
import FacebookCore

//, FBSDKLoginButtonDelegate
class loginController: UIViewController ,GIDSignInUIDelegate {
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
        setupLayout()
       
        //google sign in
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        
        //print("TESTING = \(cekLogged)")
        
        //cek sudah login
        if  cekLogged == true{
            handleSegueFacebook()
        }
        
        //cek fesbuk login
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
            print(accessToken)
        }
    }
    func signInWillDispatch(signIn: GIDSignIn!, error: NSError!) {
        print("dispatch")
    }
    
    // Present a view that prompts the user to sign in with Google
    func signIn(signIn: GIDSignIn!,
                presentViewController viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func signIn(signIn: GIDSignIn!,
                dismissViewController viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //facebook login
//    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
//        print("Log out facebook")
//    }
    
//    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
//        if error != nil {
//            print(error)
//            return
//        }
//        
////        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id, name, email"]).start{
////            (connection, result, err) in
////            
////            if err != nil{
////                print("failed to start graph request", err)
////                return
////            }
////            print(result)
////        }
//        let accesTokenFB = FBSDKAccessToken.current()
//        guard let accessTokenFBString = accesTokenFB?.tokenString else {return}
//        let credentialFB = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//        
//        Auth.auth().signIn(with: credentialFB) { (user, errfb) in
//            if let errfb = errfb {
//                print("firebase fb error", errfb)
//                return
//            }
//            // User is signed in
//            let userfb = Auth.auth().currentUser
//            print("firebase FB sukses", userfb?.email)
//            if let email = userfb?.email , let name = userfb?.displayName{
//                let parameters: Parameters = ["email": userfb?.email, "action" : "facebook"]
//                Alamofire.request("http://titipanku.xyz/api/Login.php",method: .get, parameters: parameters).responseJSON {
//                    response in
//                    
//                    //mencetak JSON response
//                    if let json = response.result.value {
//                        print("JSON: \(json)")
//                    }
//                    
//                    //mengambil json
//                    let json = JSON(response.result.value)
//                    let cekSukses = json["success"].intValue
//                    let pesan = json["message"].stringValue
//                    
//                    if cekSukses != 1 {
//                        
//                    }else{
//                    }
//                }
//            }
//            
//            
//        }
//    }
    //akhir facebook login
    
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
        
        self.hideKeyboardWhenTappedAround()
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
        let frame = CGRect(x: 50, y: 50, width: 30, height: 30)
        
        let size = CGSize(width: 30, height: 30)
        self.view.endEditing(true)
        
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
    
    @objc func loginButtonClicked() {
        let loginManager = LoginManager()
        
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self, completion:{
            loginResult in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("Logged in!")
                print(accessToken)
                
                if(AccessToken.current != nil){
                    let req = GraphRequest(graphPath: "me", parameters: ["fields": "email,first_name,last_name,gender,picture"], accessToken: AccessToken.current, httpMethod: GraphRequestHTTPMethod(rawValue: "GET")!)
                    req.start({ (connection, result) in
                        switch result {
                        case .failed(let error):
                            print(error)
                            
                        case .success(let graphResponse):
                            if let responseDictionary = graphResponse.dictionaryValue {
                                print(responseDictionary)
                                let firstNameFB = responseDictionary["first_name"] as? String
                                let lastNameFB = responseDictionary["last_name"] as? String
                                let socialIdFB = responseDictionary["id"] as? String
                                let emailFB = responseDictionary["email"] as? String
                                let genderFB = responseDictionary["gender"] as? String
                                let pictureUrlFB = responseDictionary["picture"] as? [String:Any]
                                let photoData = pictureUrlFB!["data"] as? [String:Any]
                                let photoUrl = photoData!["url"] as? String
                                print(firstNameFB, lastNameFB, socialIdFB, genderFB, photoUrl)
                                
                                let full = firstNameFB! + " " + lastNameFB!
                                if let emails = emailFB, let name : String = full{
                                    let parameters: Parameters = ["email": emails,"name":name, "action" : "facebook"]
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
                                            
                                        }else{
                                        }
                                    }
                                }
                            }
                        }
                    })
                }
            }
        } )

    }
    //tampilan
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleToFill
        iv.image = UIImage.init(named: "logotrans")
        iv.layer.masksToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let usernameTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.borderStyle = .bezel
        textField.placeholder = "Email"
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        textField.textAlignment = .center
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let passwordTextField : UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        textField.placeholder = "Password"
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.black.cgColor
        textField.textAlignment = .center
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let loginButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Login", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor(hex: "#3867d6")
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleLogin), for: UIControlEvents.touchDown)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    let registerButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.setTitle("Register", for: .normal)
        button.backgroundColor = UIColor(hex: "#3867d6")
        button.setTitleColor(UIColor.white, for: .normal)
        
        // Handle clicks on the button
        
        button.addTarget(self, action: #selector(handleSegueRegister), for: UIControlEvents.touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let googleSignInButton : GIDSignInButton = {
        let signInButton = GIDSignInButton(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
        signInButton.translatesAutoresizingMaskIntoConstraints = false
        return signInButton
    }()
    
    let facebookButton : UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        button.backgroundColor = UIColor(hex: "#3867d6")
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle("Login Facebook", for: .normal)
        button.addTarget(self, action: #selector(loginButtonClicked), for: UIControlEvents.touchUpInside)

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
//    let facebookSignInButton : FBSDKLoginButton = {
//        let fbSignInButton = FBSDKLoginButton(frame: CGRect(x: 0, y: 0, width: 150, height: 30))
//        fbSignInButton.translatesAutoresizingMaskIntoConstraints = false
//        // fbSignInButton.delegate = self
//        fbSignInButton.readPermissions = ["email"]
//        return fbSignInButton
//    }()
    
    
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
        view.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 250).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        imageView.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        
        //usernameTextField
        view.addSubview(usernameTextField)
        usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        usernameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        usernameTextField.font = UIFont.systemFont(ofSize: 25)
        usernameTextField.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        usernameTextField.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        usernameTextField.topAnchor.constraint(greaterThanOrEqualTo: imageView.bottomAnchor, constant: 0).isActive = true
        
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
        loginButton.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        loginButton.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        loginButton.topAnchor.constraint(greaterThanOrEqualTo: passwordTextField.bottomAnchor, constant: 50).isActive = true
        
        //registerButton
        view.addSubview(registerButton)
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        registerButton.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        registerButton.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 15).isActive = true
        
        //googleSignInButton
        view.addSubview(googleSignInButton)
        googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        googleSignInButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        googleSignInButton.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        googleSignInButton.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        googleSignInButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 15).isActive = true
 
        //fbSignInButton
        view.addSubview(facebookButton)
        facebookButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        facebookButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        facebookButton.leftAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leftAnchor, constant: 60).isActive = true
        facebookButton.rightAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.rightAnchor, constant: 60).isActive = true
        facebookButton.topAnchor.constraint(equalTo: googleSignInButton.bottomAnchor, constant: 15).isActive = true
        
        //googleSignOutButton
        view.addSubview(googleSignOutButton)
        googleSignOutButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        googleSignOutButton.topAnchor.constraint(equalTo: facebookButton.bottomAnchor, constant: 30).isActive = true
        
       googleSignOutButton.isHidden = true

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
