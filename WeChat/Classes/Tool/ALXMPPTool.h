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
    XMPPResultTypeLoginFailure  // 登录失败
}XMPPResultType;

/**
 *  与服务器交互的结果
 */
typedef void (^XMPPResultBlock)(XMPPResultType);

@interface ALXMPPTool : NSObject

singleton_interface(ALXMPPTool)

/**
 *  XMPP用户登录
 */
- (void)xmppLogin:(XMPPResultBlock)resultBlock;

/**
 *  用户注销
 */
- (void)xmppLogout;

@end
