//
//  ALAccount.m
//  WeChat
//
//  Created by Arclin on 16/2/16.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import "ALAccount.h"

#define kUserKey @"user"
#define kPwdKey @"pwd"
#define kLoginKey @"login"

@implementation ALAccount

+ (instancetype)shareAccount
{
    return [[self alloc] init];
}

#pragma mark 分配内存创建对象   单例模式
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    NSLog(@"%s",__func__);
    static ALAccount *account;
    // 为了线程安全
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(account == nil){
            account = [super allocWithZone:zone];
        }
    });
    return account;
}

-(void)saveToSandBox
{
    // 保存user psw login
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.user forKey:kUserKey];
    [defaults setObject:self.pwd forKey:kPwdKey];
    [defaults setBool:self.login forKey:kLoginKey];
    [defaults synchronize];
    
}

@end
