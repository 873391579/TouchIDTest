//
//  SettingController.m
//  TouchIDTest
//
//  Created by Jion on 16/2/23.
//  Copyright © 2016年 Youjuke. All rights reserved.
//

#import "SettingController.h"
#import "ZJTouchID.h"
#import "CheckController.h"
#import "DBManager.h"
#import "ImageCollectionVC.h"

@interface SettingController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *swich;
@property (nonatomic,strong)NSMutableArray *dataArray;
@end

@implementation SettingController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadData];
}
- (void)loadData
{
    DBManager *manager = [DBManager manager];
    _dataArray =[NSMutableArray arrayWithArray:[manager queryAllDataFromTableForm:@"userList"]];
    DBManager *queue = [DBManager queueManager];
    NSString *name = [[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    NSArray *userArr = [queue queueQueryDataFromTableForm:@"userData" keyAndValue:@{@"name":name}];
    if (userArr.count>0) {
        _swich.on = [[[userArr firstObject] objectForKey:@"touchID"] boolValue];
        
    }
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    // Do any additional setup after loading the view.
    [self set3DTouch];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
#warning iOS8 - 分割线样式
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
//    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    
    _tableView.separatorEffect = blurEffect;
    
    // 注册
    
//    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellIdentifier"];
//    [_tableView setEditing:YES animated:YES];
    
}
#pragma mark --UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:15.0];
    }
    NSDictionary *userDic = _dataArray[indexPath.row];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"name"] isEqualToString:userDic[@"name"]]) {
        
        cell.textLabel.textColor = [UIColor redColor];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"账户名：%@",userDic[@"name"]];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"密码:%@",userDic[@"password"]];
    
    
    return cell;
}

#pragma mark 设置可以进行编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //默认可以编译
    return YES;
}
/*
#pragma mark 设置编辑的样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.row%2==0) {
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
      return UITableViewCellEditingStyleInsert;
    }
    
    
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
*/
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [_dataArray removeObjectAtIndex:indexPath.row];
//        // Delete the row from the data source.
//        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

 
/*
#pragma mark 设置可以移动
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return YES;
}
#pragma mark 处理移动的情况
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath

{
    // 1. 更新数据
    
    id vlaue = _dataArray[sourceIndexPath.row];
    
    [_dataArray removeObject:vlaue];
    
    [_dataArray insertObject:vlaue atIndex:destinationIndexPath.row];
    
    // 2. 更新UI
    [tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    
}
*/


#warning iOS8 -

#pragma mark 在滑动手势删除某一行的时候，显示出更多的按钮
- (NSArray*)tableView:(UITableView*)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
     NSDictionary *userDic = _dataArray[indexPath.row];
    NSString *name =[[NSUserDefaults standardUserDefaults] objectForKey:@"name"];
    // 添加一个删除按钮
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        NSLog(@"点击了删除");
        
        if ([name isEqualToString:userDic[@"name"]]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"删除后将无法登录" preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
                [self reloadtable:indexPath];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self deleteDataFromTable:indexPath dic:userDic];

                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"name"];
                [self.navigationController popToRootViewControllerAnimated:YES];
                
            }]];
            [self presentViewController:alert animated:YES completion:^{
                
            }];
            
        }else{
            
            [self deleteDataFromTable:indexPath dic:userDic];
        }
    }];
    
    // 添加一个置顶按钮
    
    UITableViewRowAction *topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"置顶" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        NSLog(@"点击了置顶");
        
        // 1. 更新数据
        
        [_dataArray removeObjectAtIndex:indexPath.row];
        [_dataArray insertObject:userDic atIndex:0];
        //交换对象
//        [_dataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:0];
        // 2. 更新UI
        
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
        
        [tableView moveRowAtIndexPath:indexPath toIndexPath:firstIndexPath];
        [self performSelector:@selector(reloadtable:) withObject:indexPath afterDelay:0.3];
        
    }];
    topRowAction.backgroundColor = [UIColor blueColor];
    
    // 添加一个修改密码按钮
    
    UITableViewRowAction *moreRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"修改密码" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        NSLog(@"点击了修改密码");
        [self alertViewAction:userDic];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
        
    }];
    
    moreRowAction.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    
    // 将设置好的按钮放到数组中返回
    if ([userDic[@"name"] isEqualToString:name]) {
         return @[deleteRowAction, topRowAction, moreRowAction];
    }
    else{
        return @[deleteRowAction,topRowAction];
    }
    
}

- (void)reloadtable:(id)indexPath
{
    [_tableView reloadData];
}
- (void)deleteDataFromTable:(NSIndexPath*)indexPath dic:(NSDictionary*)userDic
{
    // 1. 更新数据
    [_dataArray removeObjectAtIndex:indexPath.row];
    
    // 2. 更新UI
    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    //3.修改本地数据库
    
    DBManager *queue = [DBManager queueManager];
    [queue queueDeleteData:@{@"name":userDic[@"name"]} fromTable:@"userData"];
    
    //4.修改后台数据库
    DBManager *manager = [DBManager manager];
    [manager deleteData:@{@"name":userDic[@"name"]} fromTable:@"userList"];
}

- (void)alertViewAction:(NSDictionary*)sender
{
    [[ZJTouchID shareIntance] alertPasswordViewTitle:@"请输入新密码" delegate:self completeHandle:^(NSString *inputPwd, BOOL *isYes) {
        //3.修改本地数据库
        DBManager *queue = [DBManager queueManager];
        [queue queueUpdate:@{@"password":inputPwd} where:@{@"name":sender[@"name"]} fromTable:@"userData"];
        
        //4.修改后台数据库
        DBManager *manager = [DBManager manager];
        [manager update:@{@"password":inputPwd} where:@{@"name":sender[@"name"]}fromTable:@"userList"];
        [self loadData];
        
    }];
}


#pragma mark--action
- (IBAction)touchIDSetting:(UISwitch*)sender {
    
    [ZJTouchID touchIDWithDelegate:self success:^{
        [self performSegueWithIdentifier:@"ToCheck" sender:sender];
       
    } errorCode:^(NSError *error) {
        [sender setOn:!sender.on animated:YES];
    }];
    
}


- (IBAction)loginoutAction:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)multipleSelectedImage:(id)sender {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    ImageCollectionVC *imageCollection = [[ImageCollectionVC alloc] initWithCollectionViewLayout:layout];
    imageCollection.title = @"图片多选";
    [self.navigationController pushViewController:imageCollection animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)set3DTouch{
#if  __IPHONE_9_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        
        if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            // 如果实现了3dtouch手势,最好禁用长按手势
            [self registerForPreviewingWithDelegate:(id)self sourceView:self.view];
            
            
        }
        else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"不支持3DTouch" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        }
 
    }
    
#endif
}
#if __IPHONE_9_0 <= __IPHONE_OS_VERSION_MAX_ALLOWED
#pragma mark--3DTouch代理
//点击进入预览模式
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    NSLog(@"触摸点坐标：%@",NSStringFromCGPoint(location));
    CheckController *check = [CheckController new];
    //预显示的尺寸
    check.preferredContentSize = CGSizeMake(320, 500);
    //源尺寸
    previewingContext.sourceRect = self.view.frame;
    
    //返回预览控制器
    return check;
}

//继续按压进入
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self showViewController:viewControllerToCommit sender:self];
}

#endif


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UISwitch *swich = (UISwitch*)sender;
    CheckController *check =(CheckController*)[segue destinationViewController];
    check.on = swich.on;
}


@end
