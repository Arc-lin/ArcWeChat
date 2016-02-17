//
//  ALRegisterViewController.m
//  WeChat
//
//  Created by Arclin on 16/2/17.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALRegisterViewController.h"

@interface ALRegisterViewController ()

- (IBAction)cancelBtnClick:(id)sender;
- (IBAction)registerBtnClick:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *userfField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;

@end

@implementation ALRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)cancelBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)registerBtnClick:(id)sender {
    
    // 注册
    // 保存注册的用户名和密码
    [ALAccount shareAccount].registerUser = self.userfField.text;
    [ALAccount shareAccount].registerPwd = self.pwdField.text;
    
    [MBProgressHUD showMessage:@"正在注册中"];
    // 调用注册的方法
    __weak typeof (self) selfVc = self;
    [ALXMPPTool sharedALXMPPTool].registerOperation = YES;
    [[ALXMPPTool sharedALXMPPTool] xmppRegister:^(XMPPResultType resultType) {
        [selfVc handleXMPPResult:resultType];
    }];
}

- (void)handleXMPPResult:(XMPPResultType)resultType
{
    // 在主线程工作
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // 1. 隐藏提示
        [MBProgressHUD hideHUD];
        
        // 2. 提示注册成功
        if (resultType == XMPPResultTypeRegisterSuccess) {
            
            [MBProgressHUD showMessage:@"注册成功，回到登录界面"];
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }else{
            [MBProgressHUD showError:@"用户名重复"];
        }
        
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
