//
//  ViewController.swift
//  iChat
//
//  Created by Marta Miozga on 26/09/2024.
//

import UIKit
import ProgressHUD


class LogViewController: UIViewController {
    
    //MARK: - IBOUtlets
    
    //labels
    
    @IBOutlet weak var EmailLabelOutlet: UILabel!
    @IBOutlet weak var passwordLabelOutlet: UILabel!
    @IBOutlet weak var repeatPassLabelOutlet: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    //textFields
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPassTextField: UITextField!
    
    //Buttons
    
    @IBOutlet weak var forgotPassButton: UIButton!
    @IBOutlet weak var resendEmailButton: UIButton!
    @IBOutlet weak var LogInButton: UIButton!
    @IBOutlet weak var SignUpButton: UIButton!
    
    
    //Views
    
    @IBOutlet weak var repeatPassView: UIView!
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUILogin(login: true)
        setUpText()
        setTapBacground()
        
        // Wyłączanie sugestii silnych haseł
            disableStrongPasswordSuggestions()
    }
    //MARK: - Vars
    
    var isLogin = true
    
    //MARK: - IBActions
    
    @IBAction func resendEmailPressed(_ sender: Any) {
        if checkDataInput(type: "password"){
            resendVerifyEmail()
        }else {
        
            ProgressHUD.showFailed("Email is required")
        }
    }
    
    @IBAction func LoginButtonPress(_ sender: Any) {
        if checkDataInput(type: isLogin ? "login" : " register"){
            isLogin ? loginUser() : registerUser()
        }else {
            ProgressHUD.showFailed("All Fields are required")
        }
    }
    
    @IBAction func forgotPassPressed(_ sender: Any) {
        if checkDataInput(type: "password"){
        resetPassword()
        }else {
            ProgressHUD.showFailed("Email is required")
        }
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        updateUILogin(login: sender.titleLabel?.text == "Login")
        isLogin.toggle()
    }
    
    //MARK: - SET UP
    
    private func setUpText(){
        emailTextField.addTarget(self, action: #selector(textFieldChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldChange(_:)), for: .editingChanged)
        repeatPassTextField.addTarget(self, action: #selector(textFieldChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldChange(_ textField: UITextField){
        updatePlaceholderLabels(textField: textField)
    }
    
  
    private func setTapBacground(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TapBackground))
        view.addGestureRecognizer(tapGesture)
    }
    
    //MARK: -  Animations
  
    @objc func TapBackground(){
        view.endEditing(false)
    }
    
    private func updateUILogin(login: Bool){
        LogInButton.setImage(UIImage(named: login ? "LoginButton" : "RegisterButton"), for: .normal)
        SignUpButton.setTitle(login ? "SignUp" : "Login", for: .normal)
        signUpLabel.text = login ? " Don't have an account? " : " Have an account?"
        
        UIView.animate(withDuration: 0.5){
            self.repeatPassTextField.isHidden = login
            self.repeatPassLabelOutlet.isHidden = login
            self.repeatPassView.isHidden = login
        }
    }
    
    private func updatePlaceholderLabels(textField: UITextField){
        switch textField {
        case emailTextField:
            EmailLabelOutlet.text = textField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabelOutlet.text = textField.hasText ? "Password" : ""
        default:
            repeatPassLabelOutlet.text = textField.hasText ? "Repeat Password" : ""
        }
    }
    
    //MARK: - Helpers
   
    private func checkDataInput(type: String) -> Bool{
        switch type {
        case "login":
            return emailTextField.text != "" && passwordTextField.text != ""
        case "registration:":
            return emailTextField.text != "" && passwordTextField.text != "" && repeatPassTextField.text != ""
        default:
            return emailTextField.text != ""
        }
    }
    
    private func registerUser(){
        if passwordTextField.text == repeatPassTextField.text! {
            DatabaseUserFeedback.shared.registerUserBy(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
                if error == nil {
                    ProgressHUD.showSuccess("Verification email sent")
                    self.signUpLabel.isHidden = false
                }else {
                    ProgressHUD.showFailed(error!.localizedDescription)
                }
            }
        }
        else {
            ProgressHUD.showFailed("The passwords don't match !")
        }
    }
    
    private func loginUser(){
        DatabaseUserFeedback.shared.loginUserByEmail(email: emailTextField.text!, password: passwordTextField.text!) {(error, isEmailVerified) in
            if  error == nil {
                if isEmailVerified{
                    self.goToApp()
                }else {
                    ProgressHUD.showFailed("Please verify email")
                    self.resendEmailButton.isHidden = false
                }
            } else {
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
    private func resetPassword(){
        DatabaseUserFeedback.shared.resetPassword(email: emailTextField.text!) {
            (error) in
            
            if error == nil {
                ProgressHUD.showFailed("Reset link send to email")
            }else{
                ProgressHUD.showFailed(error!.localizedDescription)
            }
        }
    }
    
    private func resendVerifyEmail(){
        DatabaseUserFeedback.shared.resendVerifyEmail(email: emailTextField.text!) {
            (error) in
            if error == nil {
                ProgressHUD.showFailed("New verification email sent.")
            }else{
                ProgressHUD.showFailed(error!.localizedDescription)
            }
            
        }
        
    }
    
    private func disableStrongPasswordSuggestions() {
        passwordTextField.textContentType = .none
        repeatPassTextField.textContentType = .none
        
        passwordTextField.isSecureTextEntry = true
            repeatPassTextField.isSecureTextEntry = true

            passwordTextField.autocorrectionType = .no
            passwordTextField.autocapitalizationType = .none
            passwordTextField.smartInsertDeleteType = .no

            repeatPassTextField.autocorrectionType = .no
            repeatPassTextField.autocapitalizationType = .none
            repeatPassTextField.smartInsertDeleteType = .no
    }
    
    //MARK: - Navigation
    private func goToApp(){
        
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "MainApp") as! UITabBarController
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil )
    }
}
