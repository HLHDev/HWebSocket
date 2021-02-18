//
//  WebSocketStompManager.h
//  ZHYSYouShuiApp
//
//  Created by H&L on 2020/3/3.
//  Copyright © 2020 Loveff. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ScoketResult)(id result, NSString *subscribe);

typedef void(^DisConnectResult)(BOOL disConnect);

typedef void(^DisConnectSuccess)(BOOL successConnect);

@interface WebSocketStompManager : NSObject

+ (instancetype)sharedManager;

// 建立连接
- (void)connectScoketWithTicket:(NSString *)ticker;

// 断开连接
- (void)disConnectScoket;

// 重新连接
- (void)reConnectScoket;

- (void)sendMessageGiveServerWithMessage:(NSString *)message;

@property (nonatomic, copy) ScoketResult result;
@property (nonatomic, copy) DisConnectResult disConnect;
@property (nonatomic, copy) DisConnectSuccess successConnected;
@property (nonatomic, assign) NSInteger errorCount;
@property (nonatomic, copy) NSString *ticketString;

@end

NS_ASSUME_NONNULL_END
