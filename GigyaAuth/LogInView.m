//
//  ViewController.m
//  GigyaAuth
//
//  Created by shinoy on 1/20/14.
//  Copyright (c) 2014 shinoy. All rights reserved.
//

#import "LogInView.h"
#import "MainView.h"
#import "UserDataSingleton.h"


@interface LogInView ()
{
    //UserInfo *objUserInfo;
}

@end

@implementation LogInView

//checks whether the user is already in or not. using Gigya session memory.

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //_userInfo =[[NSMutableDictionary alloc]init];
    
    _swtchGender.onTintColor =[UIColor lightGrayColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self resetView];
}

//if the user is already signed in using a provider then this page will redirect to the main page
//to set the main page check the nextView method

-(void)viewDidAppear:(BOOL)animated
{
    if ([[Gigya session] isValid])
    {
        [self nextView];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

///////*****textfield operations
#pragma mark - Textfield methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_txtAge            resignFirstResponder];
    [_txtEmail          resignFirstResponder];
    [_txtName           resignFirstResponder];
    [_txtLastName       resignFirstResponder];
    [_txtReenterEmail   resignFirstResponder];
    
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([textField.textColor isEqual:[UIColor redColor]])
        [textField setTextColor:[UIColor blackColor]];
    
    [textField setValue:[UIColor lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //checking whether the email and the reentered email are same
    
    
    if ( [textField isEqual:_txtReenterEmail] && ![textField.text isEqualToString:@""] &&
        ![_txtEmail.text isEqualToString:@""])
    {
        if (![textField.text isEqualToString:_txtEmail.text])
        {
            [textField setTextColor:[UIColor redColor]];
        }
    }
}

////*** end of text field operations



//This method is used to fetch the user info. and store it in userInfo class
//if details cannot fetch from provider then registration page will fill with the values got from
//provider and use those details for registration

#pragma mark - Getting user information


-(void)getUserInfoToClass
{
    
    GSRequest *request=[GSRequest requestForMethod:@"socialize.getUserInfo"];
    
    [request sendWithResponseHandler:^(GSResponse *response, NSError *error)
     {
         if (!error)
         {
             [UserDataSingleton userSingleton].nickName   = response[ @"nickname"];
             [UserDataSingleton userSingleton].firstName  = response[@"firstName"];
             [UserDataSingleton userSingleton].lastName   = response[ @"lastName"];
             [UserDataSingleton userSingleton].gender     = response[   @"gender"];
             [UserDataSingleton userSingleton].email      = response[    @"email"];
             [UserDataSingleton userSingleton].age        = response[      @"age"];
             
             //when birth year available instead of age, finding age from birth year
             
             if (![UserDataSingleton userSingleton].age && response[@"birthYear"])
             {
                 NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
                 [formatter setDateFormat:@"yyyy"];
                 NSString * year=[formatter stringFromDate:[NSDate date]];
                 NSString * birthYear = response[@"birthYear"];
                 
                 int age=(int)([year integerValue]-[birthYear integerValue]);
                 [UserDataSingleton userSingleton].age=[NSString stringWithFormat:@"%d",age];
                 
                 
             }
             
             if (![UserDataSingleton userSingleton].email     || ![UserDataSingleton userSingleton].nickName  ||
                 ![UserDataSingleton userSingleton].age       || ![UserDataSingleton userSingleton].firstName ||
                 ![UserDataSingleton userSingleton].gender    || ![UserDataSingleton userSingleton].lastName)
             {
                 [self showMessageTitle:@"Sorry"
                            withMessage:@"We are unable to access some of your details."];
                 
                 [self fillRegistration];
                 [self clearSession    ];
                 [UserDataSingleton userSingleton].nickName   = nil;
                 [UserDataSingleton userSingleton].firstName  = nil;
                 [UserDataSingleton userSingleton].lastName   = nil;
                 [UserDataSingleton userSingleton].gender     = nil;
                 [UserDataSingleton userSingleton].email      = nil;
                 [UserDataSingleton userSingleton].age        = nil;
                 
                 
             }
             else
                 /////// if provider give all detials wanted.. next view will display
                 /////// userInfo is not saved.code here to persist user data
                 [self nextView];
             
             
             
         }
         else
         {
             NSLog(@"Error while trying to fetch user details");
         }
         
     }];
    
}
// this will show a table of with three choices facebook, linkedin, foursquare and googleplus.
// user can select one provider. if wanto add other social networking sites just add to "providers" array
// this will redirect to a webpage from there user can login.
// gigya will keep a session memory this can be used to later to login

#pragma mark - Two different way to access user info

-(void)selectFromProviders
{
    if (![Gigya session])
    {
        NSArray *providers = @[ @"facebook",@"googleplus", @"linkedin", @"foursquare"];
        
        [Gigya showLoginProvidersDialogOver:self providers:providers parameters:Nil
                          completionHandler:^(GSUser *user, NSError *error)
         {
             if (!error)
             {
                 //[self getUserInfo];
                 [self getUserInfoToClass];
             }
             else
             {
                 NSLog(@"Cancelled by User");
             }
         }];
    }
    else
    {
        [self showMessageTitle:nil withMessage:[NSString stringWithFormat:
                                                @"You are already signed in using %@",[Gigya session].lastLoginProvider]];
    }
}


//when different providers selcted gigya framework will access the providers account from device,
//if user is already signed in on the device or show sign in page.

-(void)fromSelectedProvider: (NSString *)provider
{
    
    if (![Gigya session])
    {
        [Gigya loginToProvider:provider parameters:Nil completionHandler:^(GSUser *user, NSError *error)
         {
             if (!error)
             {
                 // [self getUserInfo];
                 [self getUserInfoToClass];
             }
             else
                 NSLog(@"Cancelled %@", error);
         }];
    }
    else
    {
        [self showMessageTitle:@"" withMessage:[NSString stringWithFormat:
                                                @"You are already signed in using %@",[Gigya session].lastLoginProvider]];
    }
}


//this function is used to fill the details into registration,
//if the data fetched from different providers are not enough.
//the details copied into the dictionary is copied fields and at the end dictionary is cleared

#pragma mark- Registration form autofill and reset

-(void)fillRegistration
{
    [self resetView];
    
    if ([UserDataSingleton userSingleton].nickName)
    {
        _txtName.textColor          = [UIColor blackColor];
        _txtName.text               = [UserDataSingleton userSingleton].nickName;
    }
    if ([UserDataSingleton userSingleton].firstName)
    {
        _txtName.textColor          = [UIColor blackColor];
        _txtName.text               = [UserDataSingleton userSingleton].firstName;
    }
    if ([UserDataSingleton userSingleton].lastName)
    {
        _txtLastName.textColor      = [UIColor blackColor];
        _txtLastName.text           = [UserDataSingleton userSingleton].lastName;
    }
    if([UserDataSingleton userSingleton].age)
    {
        _txtAge.textColor           = [UIColor blackColor];
        _txtAge.text                = [UserDataSingleton userSingleton].age;
    }
    if ([UserDataSingleton userSingleton].email)
    {   _txtEmail.textColor         = [UIColor blackColor];
        _txtReenterEmail.textColor  = [UIColor blackColor];
        _txtEmail.text              = [UserDataSingleton userSingleton].email;
        _txtReenterEmail.text       = [UserDataSingleton userSingleton].email;
    }
    if ([UserDataSingleton userSingleton].gender)
    {
        if ([[UserDataSingleton userSingleton].gender caseInsensitiveCompare:@"female"] == NSOrderedSame ||
            [[UserDataSingleton userSingleton].gender caseInsensitiveCompare:@"f"]      == NSOrderedSame)
        {
            [_swtchGender setOn:YES];
            _lblGender.text=@"female";
        }
    }
}


//resetting view Component default value
-(void)resetView
{
    _txtName.text               = @"";
    _txtLastName.text           = @"";
    _txtEmail.text              = @"";
    _txtReenterEmail.text       = @"";
    _txtAge.text                = @"";
    _lblGender.text             = @"male";
    
    [_swtchGender setOn:FALSE];
    
}


// when register button is pressed it will check text fields are properly entered or not
// if  any fields are not entered then these fields will shoe red and prompt fill it

#pragma mark - Different button actioins

-(IBAction)btnRegister:(id)sender
{
    [_txtAge            resignFirstResponder];
    [_txtEmail          resignFirstResponder];
    [_txtName           resignFirstResponder];
    [_txtLastName       resignFirstResponder];
    [_txtReenterEmail   resignFirstResponder];
    
    if ([_txtName.text isEqualToString:@""]    || [_txtEmail.text isEqualToString:@""]   ||
        [_txtAge.text isEqualToString:@""]     || [_txtLastName.text isEqualToString:@""]||
        [_txtReenterEmail.text isEqualToString:@""])
    {
        [self showMessageTitle:@"Error" withMessage:@"All fields should be entered"];
        
        if([_txtAge.text   isEqualToString: @"" ])
        {
            [_txtAge becomeFirstResponder];
            [_txtAge setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        }
        
        if([_txtReenterEmail.text isEqualToString: @"" ])
        {
            [_txtReenterEmail becomeFirstResponder];
            [_txtReenterEmail setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        }
        
        if([_txtEmail.text isEqualToString: @"" ])
        {
            [_txtEmail becomeFirstResponder];
            [_txtEmail setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        }
        
        if([_txtLastName.text  isEqualToString: @"" ])
        {
            [_txtLastName becomeFirstResponder];
            [_txtLastName setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
            
        }
        
        if([_txtName.text  isEqualToString: @"" ])
        {
            [_txtName becomeFirstResponder];
            [_txtName setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
        }
    }
    else if (![_txtEmail.text isEqualToString:_txtReenterEmail.text])
    {
        [self showMessageTitle:@"Error" withMessage:@"Email fields should be same"];
    }
    else if (![self validateEmail:_txtEmail.text])
    {
        [self showMessageTitle:@"Error" withMessage:@"Please enter a valid email address"];
        [_txtEmail setTextColor:[UIColor redColor]];
        _txtReenterEmail.text= @"";
    }
    else
    {
        [UserDataSingleton userSingleton].nickName    = _txtName.     text;
        [UserDataSingleton userSingleton].firstName   = _txtName.     text;
        [UserDataSingleton userSingleton].lastName    = _txtLastName. text;
        [UserDataSingleton userSingleton].gender      = _lblGender.   text;
        [UserDataSingleton userSingleton].email       = _txtEmail.    text;
        [UserDataSingleton userSingleton].age         = _txtAge.      text;
        
        //[self showMessageTitle:@"Succes" withMessage:@"Registration successful"];
        [self nextView];
        // code here to persist data in userInfo dictionary and push to next page
        // [self nextView] can be used to push to next page.
        
    }
    
}

// button actions

- (IBAction)btnShowList:(id)sender
{
    //This commented functions can be used to show a list of differet social networking providers
    if (![Gigya session])
     [self selectFromProviders];
     else
     //[self getUserInfo];
     [self getUserInfoToClass];
    
}

- (IBAction)swtchValueChanged:(id)sender
{
    [_txtAge            resignFirstResponder];
    [_txtEmail          resignFirstResponder];
    [_txtName           resignFirstResponder];
    [_txtLastName       resignFirstResponder];
    [_txtReenterEmail   resignFirstResponder];
    
    if ([_swtchGender isOn])
        _lblGender.text=@"female";
    else
        _lblGender.text=@"male";
}

-(IBAction)btnFacebook:(id)sender;
{
    [self fromSelectedProvider:@"facebook"];
}

-(IBAction)btnGoogleplus:(id)sender
{
    [self fromSelectedProvider:@"googleplus"];
}

-(IBAction)btnLinkedin:(id)sender
{
    [self fromSelectedProvider:@"linkedin"];
}

//This is used to present next view controller, import view controller which you wanted to present next.
//find the storyboard name and give a storyboard ID for the next view.

///*****change view controller her****///

#pragma mark- Other useful methods


//This method will clear sesstion
-(void)clearSession
{
    [Gigya logoutWithCompletionHandler:^(GSResponse *response, NSError *error)
     {
         if (!error)
         {
             [Gigya setSessionDelegate:nil];
             //[self dismissViewControllerAnimated:YES completion:nil];
         }
         else
             NSLog(@"error");
     }];
    
}



// this method will push to next view.
-(void)nextView
{
    UIViewController *mainVC=[[UIViewController alloc]init];
    
    mainVC=[[UIStoryboard storyboardWithName:@"Main" bundle:NULL]
            instantiateViewControllerWithIdentifier:@"MainView"];
    
    [self presentViewController:mainVC animated:YES completion:nil];
}


//To check email is valid or not
-(BOOL) validateEmail:(NSString *)emailString
{
    BOOL stricterFilter         = YES;
    NSString *filterString      = @"^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,4})$";
    NSString        *laxString  = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString        *emailRegex = stricterFilter ? filterString : laxString;
    NSPredicate     *emailTest  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailString];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_txtAge            resignFirstResponder];
    [_txtEmail          resignFirstResponder];
    [_txtName           resignFirstResponder];
    [_txtLastName       resignFirstResponder];
    [_txtReenterEmail   resignFirstResponder];
}

//This is used to show alert views
-(void)showMessageTitle: (NSString *) title withMessage:(NSString *) message
{
    UIAlertView * alert=[[UIAlertView alloc]initWithTitle:title message:message
                                                 delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
    
}

@end
