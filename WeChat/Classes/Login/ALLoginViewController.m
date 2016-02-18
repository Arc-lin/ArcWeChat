//
//  ALLoginViewController.m
//  WeChat
//
//  Created by Arclin on 16/2/15.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALLoginViewController.h"


@interface ALLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pswField;

@end

@implementation ALLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)loginBtnClicked:(id)sender {
    
    // 1.判断有没有输入用户名和密码
    if (self.userField.text.length == 0 || self.pswField.text.length == 0) {
        ALLog(@"请求输入用户名和密码");
        return;
    }
    
    // 给用户提示
    [MBProgressHUD showMessage:@"正在登陆ing..."];
    
    // 2.登录服务器
    // 2.1 把用户名和密码保存到沙盒
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:self.userField.text forKey:@"user"];
//    [defaults setObject:self.pswField.text forKey:@"pwd"];
//    [defaults synchronize]; // 同步到磁盘
    // 2.1 把用户和密码先放在Account单例
    [ALAccount shareAccount].loginUser = self.userField.text;
    [ALAccount shareAccount].loginPwd = self.pswField.text;
    
    // 2.2 调用AppDelegate的xmppLogin方法
    // 怎么把appdelegate的登录结果告诉ALLoginViewController控制器
    // 》代理
    // 》block
    // 》通知
    
    // block会对self进行强引用
    __weak typeof(self) selfVc = self;
    // 自己写的block，有强引用的时候，使用弱引用，系统block，基本可以不理
    
    // 设置标识
    [ALXMPPTool sharedALXMPPTool].registerOperation = NO;
    
    [[ALXMPPTool sharedALXMPPTool] xmppLogin:^(XMPPResultType resultType) {
        
        [selfVc handleXMPPResultType:resultType];
        
    }];
    
}

#pragma mark 处理结果
- (void)handleXMPPResultType:(XMPPResultType)resultType{
    
    // 回到主线程更新UI
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
        if (resultType == XMPPResultTypeLoginSuccess) {
            ALLog(@"登录成功");
            // 3.登录成功切换到主界面
//            [self changeToMain];
            [UIStoryboard showInitialVCWithName:@"Main"];
            
            // 设置当前登录状态
            [ALAccount shareAccount].login = YES;
            
            // 保存登录账户信息到沙盒
            [[ALAccount shareAccount] saveToSandBox];
            
        }else{
            ALLog(@"登录失败");
            [MBProgressHUD showError:@"用户名或者密码不正确"];
        }
    });
  
}

#pragma mark 切换到主界面
- (void)changeToMain
{
//   // 1. 获取Main.storyboard的第一个控制器
//    id vc =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
//    
//    // 2. 切换window的根控制器
//    [UIApplication sharedApplication].keyWindow.rootViewController = vc;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
