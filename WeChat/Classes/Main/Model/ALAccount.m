//
//  ALAccount.m
//  WeChat
//
//  Created by Arclin on 16/2/16.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALAccount.h"

#define kUserKey @"loginUser"
#define kPwdKey @"loginPwd"
#define kLoginKey @"login"

static NSString *domain = @"arclin.local";
static NSString *host = @"127.0.0.1";
static int port = 5222; 

@implementation ALAccount

+ (instancetype)shareAccount
{
    return [[self alloc] init];
}

#pragma mark 分配内存创建对象   单例模式
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static ALAccount *account;
    // 为了线程安全
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        account = [super allocWithZone:zone];
        
        // 从沙盒获取上次的用户登录信息
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        account.loginUser = [defaults objectForKey:kUserKey];
        account.loginPwd = [defaults objectForKey:kPwdKey];
        account.login = [defaults boolForKey:kLoginKey];
        
    });
    return account;
}

-(void)saveToSandBox
{
    // 保存user psw login
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.loginUser forKey:kUserKey];
    [defaults setObject:self.loginPwd forKey:kPwdKey];
    [defaults setBool:self.login forKey:kLoginKey];
    [defaults synchronize];
    
}

- (NSString *)domain
{
    return domain;
}

- (NSString *)host
{
    return host;
}

- (int)port
{
    return port;
}
@end
