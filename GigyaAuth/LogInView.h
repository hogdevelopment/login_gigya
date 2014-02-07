//
//  ViewController.h
//  GigyaAuth
//
//  Created by shinoy on 1/20/14.
//  Copyright (c) 2014 shinoy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GigyaSDK/Gigya.h>


@interface LogInView : UIViewController<GSSessionDelegate, UIAlertViewDelegate,UITextFieldDelegate>


//@property (nonatomic, strong) NSMutableDictionary * userInfo;

@property (weak, nonatomic) IBOutlet UITextField  * txtName;

@property (weak, nonatomic) IBOutlet UITextField  * txtLastName;

@property (weak, nonatomic) IBOutlet UITextField  * txtEmail;

@property (weak, nonatomic) IBOutlet UITextField  * txtReenterEmail;

@property (weak, nonatomic) IBOutlet UITextField  * txtAge;

@property (weak, nonatomic) IBOutlet UILabel      * lblGender;

@property (weak, nonatomic) IBOutlet UISwitch     * swtchGender;

@property (weak, nonatomic) IBOutlet UIButton     * btnRegistrater;

//Actions
-(IBAction)swtchValueChanged:(id)sender;

-(IBAction)btnRegister      :(id)sender;

-(IBAction)btnShowList      :(id)sender;

-(IBAction)btnFacebook      :(id)sender;

-(IBAction)btnGoogleplus    :(id)sender;

-(IBAction)btnLinkedin       :(id)sender;

@end
