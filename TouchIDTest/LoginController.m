//
//  LoginController.m
//  TouchIDTest
//
//  Created by Jion on 16/2/23.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import "LoginController.h"
#import "ZJTouchID.h"
#import "DBManager.h"

typedef NS_ENUM(NSInteger,LoginType) {
    TouchIDLogin,
    PasswordLogin
};
@interface LoginController ()
{
    BOOL touchID;
    LoginType _loginType;
}
@end

@implementation LoginController
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _passwordField.text = nil;
    [self showsView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _loginBtn.layer.cornerRadius = 4.0;
    _loginBtn.layer.masksToBounds = YES;
    
    
}

- (void)showsView
{
    _loginType = PasswordLogin;
    NSString *name =[[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    if (name) {
        DBManager *queue = [DBManager queueManager];
        NSArray *userArr = [queue queueQueryDataFromTableForm:@"userData" keyAndValue:@{@"name":name}];
        if (userArr.count!=0) {
            touchID = [[[userArr firstObject] valueForKey:@"touchID"] boolValue];
            if (touchID) {
                _loginType = TouchIDLogin;
                _passwordField.hidden = YES;
                _spaceConstraint.constant = 34;
                [_loginBtn setTitle:@"指纹登录" forState:UIControlStateNormal];
                [_loginWayBtn setTitle:@"密码登录" forState:UIControlStateNormal];
            }else{
                _passwordField.hidden = NO;
                _spaceConstraint.constant = 97;
                [_loginBtn setTitle:@"密码登录" forState:UIControlStateNormal];
                [_loginWayBtn setTitle:@"指纹登录" forState:UIControlStateNormal];
            }
            
            
        }
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark--Action
- (IBAction)selectWayAction:(UIButton*)sender {
    if (sender.selected) {
        sender.selected = NO;
        _loginType = TouchIDLogin;
        
        _passwordField.hidden = YES;
        _spaceConstraint.constant = 34;
        
        [_loginBtn setTitle:@"指纹登录" forState:UIControlStateNormal];
        [_loginWayBtn setTitle:@"密码登录" forState:UIControlStateNormal];
    }else{
        sender.selected = YES;
        _loginType = PasswordLogin;
        
        _passwordField.hidden = NO;
         _spaceConstraint.constant = 97;
        
        [_loginBtn setTitle:@"密码登录" forState:UIControlStateNormal];
        [_loginWayBtn setTitle:@"指纹登录" forState:UIControlStateNormal];
    }
}

-(IBAction)loginMethodAction:(id)sender
{
    [self.view endEditing:YES];
    //验证输入信息是否为空或是否合法
    if ([self verificationData]) return;
    
    if (touchID&&_loginType==TouchIDLogin) {
        [ZJTouchID touchIDWithFallbackTitle:@"密码登录" delegate:self success:^{
            DBManager *queue = [DBManager queueManager];
            NSArray *userArr = [queue queueQueryDataFromTableForm:@"userData" keyAndValue:@{@"name":_nameField.text}];
            NSString *password = [[userArr firstObject] valueForKey:@"password"];
            
            [self dataWay:sender Password:password];
        } handlerAction:^{
            //选择密码登录
            [self alertViewAction:sender];
            
        } errorCode:^(NSError *error) {
            
        }];
        
    }else{
        [self dataWay:sender Password:_passwordField.text];
        
    }
    
}

- (void)alertViewAction:(id)sender
{
    
    /*
    [[ZJTouchID shareIntance] alertPasswordViewTitle:@"请输入登录密码" delegate:self completeHandle:^(NSString *inputPwd, BOOL *isYes) {
       
        *isYes = [self checkPassword:inputPwd];
        if (*isYes) {
            [self performSegueWithIdentifier:@"ToSetting" sender:sender];
        }
        
    }];
    */
    
    
    [[ZJTouchID shareIntance] alertPasswordViewTitle:@"提示" subTitle:@"请输入登录密码" delegate:self completeHandle:^(NSString *inputPwd, BOOL *isYes) {
        
        *isYes = [self checkPassword:inputPwd];
        if (*isYes) {
            [self performSegueWithIdentifier:@"ToSetting" sender:sender];
        }
    }];
    
  
    /*
    [[ZJTouchID shareIntance] alertPasswordViewTitle:@"请输入支付密码" subTitle:@"转账" payTotal:1000.00 delegate:self completeHandle:^(NSString *inputPwd, BOOL *isYes) {
        *isYes = [self checkPassword:inputPwd];
        if (*isYes) {
            [self performSegueWithIdentifier:@"ToSetting" sender:sender];
        }
    }];
    */
    
}

- (void)dataWay:(id)sender Password:(NSString*)password
{
    if ([self checkName:_nameField.text Password:password]){
       //保存用户信息
        [[NSUserDefaults standardUserDefaults] setObject:_nameField.text forKey:@"name"];
        DBManager *queue = [DBManager queueManager];
        [queue queueCreateTableForm:@"userData" keyAndAttribute:@{@"name":@"text NOT NULL",@"password":@"text NOT NULL"}];
        NSArray *existArr = [queue queueQueryFromTableForm:@"userData" paramsKey:@"name"];
        if (![existArr containsObject:_nameField.text]) {
            [queue queueInsertData:@{@"name":_nameField.text,@"password":password} ToTableForm:@"userData"];
        }
        
        [self performSegueWithIdentifier:@"ToSetting" sender:sender];
    }
}

#pragma mark--匹配用户
- (BOOL)checkName:(NSString*)name Password:(NSString *)pass
{
    NSString *message = @"该用户不存在";
    DBManager *manager = [DBManager manager];
    NSArray *existUser = [manager queryDataFromTableForm:@"userList" paramsKey:@"name"];
    if ([existUser containsObject:name]) {
        message = nil;
       NSArray *resultArray = [manager queryDataFromTableForm:@"userList" keyAndValue:@{@"name":name}];
        BOOL result = resultArray.count > 0 && [[resultArray[0] objectForKey:@"password"] isEqualToString:pass];
        if (!result) {
            message = @"密码不正确";
        }
    }
    
    
    if (message) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
    
    return !message;
    
}
#pragma mark--判断密码是否正确
-(BOOL)checkPassword:(NSString*)pdw
{
    DBManager *queue = [DBManager queueManager];
    NSArray *userArr = [queue queueQueryDataFromTableForm:@"userData" keyAndValue:@{@"name":_nameField.text}];
    NSString *password = [[userArr firstObject] objectForKey:@"password"];
    if ([password isEqualToString:pdw]) {
        return YES;
    }
    
    return NO;
}

#pragma mark--验证数据
- (BOOL)verificationData
{
    NSString *message = nil;
    DBManager *queue = [DBManager queueManager];
    NSArray *userArr = [queue queueQueryDataFromTableForm:@"userData" keyAndValue:@{@"name":_nameField.text}];
     touchID = [[[userArr firstObject] valueForKey:@"touchID"] boolValue];
    if (!touchID) {
        if (_passwordField.text.length!=6) {
            message = @"请输入6位密码";
        }
        if (_loginType==TouchIDLogin) {
            
            message = @"该账户没有设置指纹登录";
        }

    }else{
        
        if (![[[userArr firstObject] valueForKey:@"name"] isEqualToString:_nameField.text]) {
            if (_loginType==TouchIDLogin) {
                
                message = @"该账户没有设置指纹登录";
            }
        }
    }
    
    if (_nameField.text.length==0) {
        message = @"请输入账号";
    }
    
    if (message) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    }
    
    return message;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //在此传值
    if ([segue.identifier isEqualToString:@"ToRegister"]) {
        
    }
    else if ([segue.identifier isEqualToString:@"ToSetting"])
    {
        
        [self.view endEditing:YES];
    }
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
