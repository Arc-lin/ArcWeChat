//
//  ALAccount.h
//  WeChat
//
//  Created by Arclin on 16/2/16.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALAccount : NSObject

/**
 *  登录的用户名
 */
@property (nonatomic,copy) NSString *loginUser;
/**
 *  登录的密码
 */
@property (nonatomic,copy) NSString *loginPwd;
/**
 *  注册的用户名
 */
@property (nonatomic,copy) NSString *registerUser;
/**
 *  注册的密码
 */
@property (nonatomic,copy) NSString *registerPwd;

/**
 *  判断用户是否登录
 */
@property (nonatomic,assign,getter=isLogin)BOOL login;

+(instancetype)shareAccount;

/**
 *  保存最新的登录用户数据到沙盒里面去
 */
- (void)saveToSandBox;

/**
 *  服务器的域名
 */
@property (nonatomic,copy,readonly) NSString *domain;

/**
 *  服务器的ip
 */
@property (nonatomic,copy,readonly) NSString *host;

/**
 *  服务器的端口号
 */
@property (nonatomic,assign,readonly) int port;

@end
