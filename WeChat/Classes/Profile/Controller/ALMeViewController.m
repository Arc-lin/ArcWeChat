//
//  ALMeViewController.m
//  WeChat
//
//  Created by Arclin on 16/2/16.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALMeViewController.h"
#import "AppDelegate.h"

@interface ALMeViewController ()

@end

@implementation ALMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (IBAction)logoutBtnClick:(id)sender {
    
    // 注销
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    [appDelegate xmppLogout];

    // 回登录的控制器
    [UIStoryboard showInitialVCWithName:@"Login"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
