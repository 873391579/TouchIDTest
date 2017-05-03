//
//  RegisterController.m
//  TouchIDTest
//
//  Created by Jion on 16/2/23.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import "RegisterController.h"
#import "DBManager.h"

@interface RegisterController ()

@end

@implementation RegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)registerOKAction:(id)sender {
    
    if (![self verificationData]) {
        [self checkName:_nameField.text Password:_passwordField.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark--匹配用户
- (void)checkName:(NSString*)name Password:(NSString*)password
{
    DBManager *manager = [DBManager manager];
    //密码若为整形则： @"password":@"integer NOT NULL"
    [manager createtableForm:@"userList" keyAndAttribute:@{@"name":@"text NOT NULL",@"password":@"text NOT NULL"}];
   NSArray *existUser = [manager queryDataFromTableForm:@"userList" paramsKey:@"name"];
    if ([existUser containsObject:_nameField.text]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"该用户已存在" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert animated:YES completion:^{
            
        }];

    }else{
         [manager insertData:@{@"name":_nameField.text,@"password":_passwordField.text} ToTableForm:@"userList"];
    }
   
}


#pragma mark--验证数据
- (BOOL)verificationData
{
    NSString *message = nil;
    NSCharacterSet *whiteNewChars = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *username = [_nameField.text stringByTrimmingCharactersInSet:whiteNewChars];
    NSString *password = [_passwordField.text stringByTrimmingCharactersInSet:whiteNewChars];
    NSString *repeatPassword = [_repeatPassword.text stringByTrimmingCharactersInSet:whiteNewChars];
    if (![password isEqualToString:repeatPassword]) {
        message = @"两次输入密码不同";
    }
    if (repeatPassword.length!=6) {
        message = @"确认密码不正确";
    }
    
    if (password.length!=6) {
        message = @"请输入6位密码";
    }
    if (username.length==0) {
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

//- (void)checkName:(NSString*)name Password:(NSString*)password
//{
//    NSUserDefaults *storeDefaults = [NSUserDefaults standardUserDefaults];
//    if (![storeDefaults objectForKey:@"users"]) {
//        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
//        [storeDefaults setValue:dictionary forKey:@"users"];
//
//    }
//    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:[storeDefaults objectForKey:@"users"]];
//    if ([data.allKeys containsObject:name]) {
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"该用户已存在" preferredStyle:UIAlertControllerStyleAlert];
//        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//        }]];
//        [self presentViewController:alert animated:YES completion:^{
//
//        }];
//        return;
//    }
//    //为了安全的话，可对密码进行MD5加密
//    [data setValue:password forKey:name];
//    [storeDefaults setValue:data forKey:@"users"];
//
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
