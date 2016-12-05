//
//  ViewController.swift
//  SwiftyForms
//
//  Created by banxi1988 on 12/05/2016.
//  Copyright (c) 2016 banxi1988. All rights reserved.
//

import UIKit
import SwiftyForms

class LoginForm: BaseForm{
  
  let mobileField = TextField(name: "mobile", label: "手机号")
  let passwordField = PasswordField(
    name: "password",
    label: "密码",
    validators: [.length(min: 6, max: 20, message: nil)]
  )
  let remerberField = BooleanField(name:"记住我?")
  
  func validate() -> Bool{
    let fields: [Any] = [mobileField, passwordField, remerberField]
    return validate(fields: fields)
  }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

