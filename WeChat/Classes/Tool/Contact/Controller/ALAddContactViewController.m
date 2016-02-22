//
//  ALAddContactViewController.m
//  WeChat
//
//  Created by Arclin on 16/2/22.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALAddContactViewController.h"
#import "ALContactViewController.h"

@interface ALAddContactViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ALAddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark 添加好友
- (IBAction)addContactBtnClick:(id)sender {
    
    // 删除subscription为none的好友
    ALContactViewController *conVc = [[ALContactViewController alloc] init];
    [conVc deleteNoneContact];
    
    // 获取用户输入的好友名称
    NSString *user = self.textField.text;
    
    // 1.不能添加自己为好友
    if ([user isEqualToString:[ALAccount shareAccount].loginUser]) {
        [self showMsg:@"不能添加自己为好友"];
        return;
    }
    // 2.已经存在的好友无需添加
    XMPPJID *userJid = [XMPPJID jidWithUser:user domain:[ALAccount shareAccount].domain resource:nil];
    
    BOOL userExists = [[ALXMPPTool sharedALXMPPTool].rosterStorage userExistsWithJID:userJid xmppStream:[ALXMPPTool sharedALXMPPTool].xmppStream];
    if (userExists) {
        [self showMsg:@"好友已经存在"];
        return;
    }
    // 3.添加好友(订阅)
    [[ALXMPPTool sharedALXMPPTool].roster subscribePresenceToUser:userJid];
    
    [self.navigationController popViewControllerAnimated:YES];
    /* 添加好友存在的问题
        1. 添加不存在的好友，通讯录里面也显示了好友 
        解决办法（服务器端） 1. 服务器可以拦截好友添加的请求，如当前数据库没有好友，不要返回信息
        解决办法（客户端）2. 过滤数据库的subscription字段查询请求  none 对方没有同意添加好友  to 发给对方的请求 from 别人发来的请求 both 双方互为好友
     */
}

- (void)showMsg:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil,nil];
    [alertView show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
