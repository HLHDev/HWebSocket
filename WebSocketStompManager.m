//
//  WebSocketStompManager.m
//  ZHYSYouShuiApp
//
//  Created by H&L on 2020/3/3.
//  Copyright © 2020 Loveff. All rights reserved.
//

#import "WebSocketStompManager.h"
#import "WebsocketStompKit.h"

@interface WebSocketStompManager () <STOMPClientDelegate>

@property (nonatomic, strong) STOMPClient *client;
@property (nonatomic, assign) NSInteger indexCount;

@end

@implementation WebSocketStompManager

+ (instancetype)sharedManager {
    static WebSocketStompManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[WebSocketStompManager alloc] init];
        
    });
    return manager;
}

- (void)connectScoketWithTicket:(NSString *)ticker {
    _ticketString = ticker;
    self.indexCount = 0;
    if (self.client) {
        [self.client disconnect];
        self.client = nil;
    }
    
    NSURL *websocketUrl = [NSURL URLWithString:HOST_URL_Scoket/*@"ws://192.168.1.231:9998/ipoa/stomp/websocket"*/];
    STOMPClient *client = [[STOMPClient alloc] initWithURL:websocketUrl webSocketHeaders:@{} useHeartbeat:YES];
    self.client = client;
    WS(weakSelf);
    [client connectWithHeaders:@{@"X-Websocket-Ticket":ticker} completionHandler:^(STOMPFrame *connectedFrame, NSError *error) {
        if (error) {
            DDLogInfo(@"connectScoket_error%@", error);
            return;
        }
        if (weakSelf.successConnected) {
            weakSelf.successConnected(YES);
        }
        NSString *urlPath = [NSString stringWithFormat:@"/topic/v1/tickets/%@/device-status",ticker];
        [client subscribeTo:urlPath messageHandler:^(STOMPMessage *message) {
            if (weakSelf.result) {
                weakSelf.result(message.body, urlPath);
            }
        }];
    }];
    
    
    
    client.delegate = self;
}

- (void)sendMessageGiveServerWithMessage:(NSString *)message {
    if (self.client) {
        [self.client sendTo:@"/websocket/device" body:message];
    } else {
        [self reConnectScoket];
    }
    
}

- (void)disConnectScoket {
    [self.client disconnect];
    self.client = nil;
    DDLogInfo(@"disConnectScoket");
}

- (void)reConnectScoket {
    [[WebSocketStompManager sharedManager] connectScoketWithTicket:self.ticketString];
}

// 与后台断开连接的回调方法
- (void)websocketDidDisconnect:(NSError *)error {
    WS(weakSelf);
    //在这里处理断开连接之后的逻辑，比如是否需要重新连接
    
//    [self disConnectScoket];
    
    if (self.indexCount == 0) {
        self.indexCount = 1;
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (weakSelf.client) {
                [weakSelf disConnectScoket];
            }
        });
        NSLog(@"与服务器首次断开连接");
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.disConnect(YES);
        });
    }
    NSLog(@"与断开连接");
}

// 注：webscokcet在进入后台之后就断开连接了，如果在进入前台时j根据情况判断是否需要重连



@end
