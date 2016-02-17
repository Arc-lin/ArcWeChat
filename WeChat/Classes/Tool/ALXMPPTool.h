//
//  ALXMPPTool.h
//  WeChat
//
//  Created by Arclin on 16/2/17.
//  Copyright © 2016年 sziit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"

typedef enum{
    XMPPResultTypeLoginSuccess, // 登录成功
    XMPPResultTypeLoginFailure,  // 登录失败
    XMPPResultTypeRegisterSuccess, // 注册成功
    XMPPResultTypeRegisterFailure // 注册失败
}XMPPResultType;

/**
 *  与服务器交互的结果
 */
typedef void (^XMPPResultBlock)(XMPPResultType);

@interface ALXMPPTool : NSObject

singleton_interface(ALXMPPTool)

/**
 *  标识 连接到服务器 到底是 "登录连接" 还是 "注册连接"
 *  NO 代表登录操作  Yes 代表注册操作
 */
@property (nonatomic,assign,getter=isRegisterOperation) BOOL registerOperation;

/**
 *  XMPP用户登录
 */
- (void)xmppLogin:(XMPPResultBlock)resultBlock;

/**
 *  XMPP用户注册
 */
- (void)xmppRegister:(XMPPResultBlock)resultBlock;

/**
 *  用户注销
 */
- (void)xmppLogout;

@end
