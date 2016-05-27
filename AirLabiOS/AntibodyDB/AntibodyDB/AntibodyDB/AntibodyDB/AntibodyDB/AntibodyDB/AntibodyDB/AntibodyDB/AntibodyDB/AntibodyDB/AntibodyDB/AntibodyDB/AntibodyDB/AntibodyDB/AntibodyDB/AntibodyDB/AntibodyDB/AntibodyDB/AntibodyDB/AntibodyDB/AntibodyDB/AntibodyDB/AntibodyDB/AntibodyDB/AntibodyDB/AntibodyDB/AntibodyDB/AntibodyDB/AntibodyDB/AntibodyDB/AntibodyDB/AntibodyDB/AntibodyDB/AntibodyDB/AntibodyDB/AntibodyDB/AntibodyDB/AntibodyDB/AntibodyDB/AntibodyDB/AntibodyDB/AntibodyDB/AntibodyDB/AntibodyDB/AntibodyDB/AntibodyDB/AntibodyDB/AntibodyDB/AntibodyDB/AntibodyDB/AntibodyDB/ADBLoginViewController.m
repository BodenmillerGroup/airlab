//
//  ADBLoginViewController.m
//  AntibodyDB
//
//  Created by Raul Catena on 5/20/14.
//  Copyright (c) 2014 CatApps. All rights reserved.
//

#import "ADBLoginViewController.h"
#import "Person.h"
#import "ZGroupPerson.h"
#import "Group.h"

@interface ADBLoginViewController ()

@property (nonatomic, strong) NSData *data;

@end

@implementation ADBLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIBarButtonItem *sep = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        sep.width = 40;
        self.navigationItem.leftBarButtonItems = @[[[UIBarButtonItem alloc]initWithTitle:@"Create account" style:UIBarButtonItemStyleBordered target:self action:@selector(changedAction:)], sep, [[UIBarButtonItem alloc]initWithTitle:@"Forgot password" style:UIBarButtonItemStyleBordered target:self action:@selector(forgot)]];
    }
    return self;
}

-(void)changedAction:(UIBarButtonItem *)sender{
    if(sender.tag == 0){
        sender.tag = 1;
        self.buttonLogin.tag = 1;
        [sender setTitle:@"Go to log in"];
        [self.buttonLogin setTitle:@"Create account" forState:UIControlStateNormal];
    }else{
        sender.tag = 0;
        self.buttonLogin.tag = 0;
        [sender setTitle:@"Create an account"];
        [self.buttonLogin setTitle:@"Log in" forState:UIControlStateNormal];
    }
    self.confirmPassword.hidden = !(BOOL)sender.tag;
}

-(void)forgot{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Your email" message:@"We will send you a new randomly generated password to your email address" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 0;
    [alert show];
}

-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView{
    if (alertView.tag == 0) {
        UITextField *textF = [alertView textFieldAtIndex:0];
        return [General checkEmailIsValid:textF.text]? YES:NO;
    }
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1 && alertView.tag == 0) {
        self.email.text = [alertView textFieldAtIndex:0].text;
        [[ADBAccountManager sharedInstance]requestNewPassword:self.email.text];
    }
    if (buttonIndex == 1 && alertView.tag == 1) {
        ADBAskGroupViewController *ask = [[ADBAskGroupViewController alloc]init];
        [self showModalWithCancelButton:ask fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
    }
    if (buttonIndex == 2 && alertView.tag == 1) {
        ADBAddGroupViewController *ask = [[ADBAddGroupViewController alloc]init];
        ask.delegate = self;
        [self showModalWithCancelButton:ask fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
    }
}

-(void)didAddGroup{
    [self dismissModalOrPopover];
    [General showOKAlertWithTitle:@"Wait a few minutes and login again to start managing your group" andMessage:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"AirLab";
    [General addBorderToButton:self.buttonLogin withColor:[UIColor redColor]];
    //self.email.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"NSUD_EMAIL_LOGIN"];//@"raulcatena@gmail.com";
    //self.password.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"NSUD_PASSWORD_LOGIN"];//@"9wEHPXc";
    [self.buttonLogin addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logedIn:) name:@"NSNC_LOGEDIN" object:_data];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(created:) name:@"NSNC_CREATED" object:_data];
    self.confirmPassword.hidden = YES;
    //Cute Brain buttons
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"NSUD_EMAIL_LOGIN"])
    [self.brainEmail setSelected:YES];
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"NSUD_PASSWORD_LOGIN"])
    [self.brainPassword setSelected:YES];
    [self.brainEmail setBackgroundImage:[UIImage imageNamed:@"brainorange.png"] forState:UIControlStateSelected];
    [self.brainPassword setBackgroundImage:[UIImage imageNamed:@"brainorange.png"] forState:UIControlStateSelected];
}

-(void)logedIn:(NSNotification *)notification{
    
    //OFFLINE
    if (!notification.userInfo) {
        [General showOKAlertWithTitle:@"You need to be online to log in" andMessage:@"You can afterwards work offline, once successfully logged in"];
        return;
    }
    
    //ONLINE
    Person *person = [[ADBAccountManager sharedInstance]currentUser];
    NSDictionary *userDic = [notification userInfo];
    int code = [(NSNumber *)[userDic valueForKey:@"signal"]intValue];
    switch (code) {
        case -1://Something wrong after callback
            {
                [General showOKAlertWithTitle:@"Error" andMessage:@"There was an error login in, please try again"];
            }
            break;
        case 0://Tutto bene with user but not in any group
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"You don't belong to any group" message:@"Do you want to join an exisiting group or create a new one to start working?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Request to join group", @"Create my own group", nil];
                alert.tag = 1;
                [alert show];
            }
            break;
        case 1://Tutto bene with user and active in one group only
            {
                [General showOKAlertWithTitle:[NSString stringWithFormat:@"Hi %@", person.perEmail] andMessage:[NSString stringWithFormat:@"Welcome to %@", [[(ZGroupPerson *)person.groupPersons.allObjects.lastObject group]grpName]]];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                [[IPFetchObjects getInstance]addPeopleFromLabFromServerWithBlock:^{}];
            }
            break;
        case 2://Tutto bene with user and active in one group only
            {
                [General showOKAlertWithTitle:[NSString stringWithFormat:@"Your membership to %@ is still pending activation", [(ZGroupPerson *)person.groupPersons.allObjects.lastObject group].grpName] andMessage:nil];
            }
            break;
        case 3://Tutto bene and more than one group
            {
                ADBChooseGroupViewController *choose = [[ADBChooseGroupViewController alloc]initWithNibName:nil bundle:nil andGroups:person.groupPersons];
                choose.delegate = self;
                [self showModalWithCancelButton:choose fromVC:self withPresentationStyle:UIModalPresentationFormSheet];
            }
            break;
            
        default:
            break;
    }
    NSError *error;
    NSArray *returned = [NSJSONSerialization JSONObjectWithData:[[notification userInfo]valueForKey:@"json"] options:NSJSONReadingMutableContainers error:&error];
    if(error)[General logError:error];
    if(returned.count == 0 && notification.userInfo){
        return;
    }
}


-(void)created:(NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    int code = [(NSNumber *)[dict valueForKey:@"signal"]intValue];
    switch (code) {
        case 0:
            [General showOKAlertWithTitle:@"Email not available" andMessage:@"The email address has already been registered"];
            break;
            
        default:
            [General showOKAlertWithTitle:@"You will soon receive an email which the activation details" andMessage:nil];
            break;
    }
}

-(void)didChooseGroupPerson:(ZGroupPerson *)groupPerson{
    groupPerson.zetIsCurrent = [NSNumber numberWithBool:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }];
    [General saveContextAndRoll];
    
    [[ADBAccountManager sharedInstance]checkNeedErase];
    [[IPFetchObjects getInstance]addPeopleFromLabFromServerWithBlock:^{}];
}

-(void)cancel{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)remember{
    if(_brainEmail.selected){
        [[NSUserDefaults standardUserDefaults]setValue:self.email.text forKey:@"NSUD_EMAIL_LOGIN"];
    }else{
        [[NSUserDefaults standardUserDefaults]setValue:nil forKey:@"NSUD_EMAIL_LOGIN"];
    }
    if(_brainPassword.selected){
        [[NSUserDefaults standardUserDefaults]setValue:self.password.text forKey:@"NSUD_PASSWORD_LOGIN"];
    }else{
        [[NSUserDefaults standardUserDefaults]setValue:nil forKey:@"NSUD_PASSWORD_LOGIN"];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void)action{
    //TODO check email valid
    [self remember];
    if(self.buttonLogin.tag == 0){
        [[ADBAccountManager sharedInstance]logInWithEmail:self.email.text andPassword:self.password.text];
    }else{
        [[ADBAccountManager sharedInstance]createAccountWithEmail:self.email.text andPassword:self.password.text];
    }
}

-(void)toogleBrain:(UIButton *)sender{
    if(sender.tag == 0)sender.tag = 1;
    if(sender.tag == 1)sender.tag = 0;
    [sender setSelected:!sender.selected];
}

@end
