//
//  WGW_Logging.h
//  Whatgoeswith-Backend
//
//  Created by Paul Shapiro on 12/20/15.
//  Copyright © 2015 Lunarpad Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>



#if (DEBUG == 1)

#define DDLogInfo(...) NSLog(@"%@", [NSString stringWithFormat:@"[DEV_ONLY] 💬 %@", [NSString stringWithFormat:__VA_ARGS__]])
#define DDLogError(...) NSLog(@"%@", [NSString stringWithFormat:@"[DEV_ONLY] ❌ Error:\t%@", [NSString stringWithFormat:__VA_ARGS__]])
#define DDLogErrorString(...) NSLog(@"%@", [NSString stringWithFormat:@"[DEV_ONLY] ❌ Error:\t%@", __VA_ARGS__])
#define DDLogWarn(...) NSLog(@"%@", [NSString stringWithFormat:@"[DEV_ONLY] ⚠️ Warning:\t%@", [NSString stringWithFormat:__VA_ARGS__]])
#define DDLogWarnString(...) NSLog(@"%@", [NSString stringWithFormat:@"[DEV_ONLY] ⚠️ Warning:\t%@", __VA_ARGS__])
#define DDLogDo(...) NSLog(@"%@", [NSString stringWithFormat:@"[DEV_ONLY] 🔁 %@", [NSString stringWithFormat:__VA_ARGS__]])
#define DDLogRead(...) NSLog(@"%@", [NSString stringWithFormat:@"[DEV_ONLY] 🔍 %@", [NSString stringWithFormat:__VA_ARGS__]])
#define DDLogWrite(...) NSLog(@"%@", [NSString stringWithFormat:@"[DEV_ONLY] 📝 %@", [NSString stringWithFormat:__VA_ARGS__]])
#define DDLogComplete(...) NSLog(@"%@", [NSString stringWithFormat:@"[DEV_ONLY] ✅ %@", [NSString stringWithFormat:__VA_ARGS__]])
#define DDLogProfile(...) NSLog(@"%@", [NSString stringWithFormat:@"[DEV_ONLY] ⌚ %@", [NSString stringWithFormat:__VA_ARGS__]])
#define DDLogDel(...) NSLog(@"%@", [NSString stringWithFormat:@"[DEV_ONLY] ➤ %@", [NSString stringWithFormat:__VA_ARGS__]])
#define DDLogProxied(...) NSLog(@"%@", [NSString stringWithFormat:@"[DEV_ONLY] ⚡️ %@", [NSString stringWithFormat:__VA_ARGS__]])
#define DDLogNetworking(...) NSLog(@"%@", [NSString stringWithFormat:@"[DEV_ONLY] 📡 %@", [NSString stringWithFormat:__VA_ARGS__]])
#define DDLogTodo(...) NSLog(@"%@", [NSString stringWithFormat:@"[DEV_ONLY] 📌 TODO in [%@/%@]:\n%@", self, NSStringFromSelector(_cmd), [NSString stringWithFormat:__VA_ARGS__]])

#else

#define DDLogInfo(...) ((void)0)
#define DDLogError(...) ((void)0)
#define DDLogErrorString(...) ((void)0)
#define DDLogWarn(...) ((void)0)
#define DDLogWarnString(...) ((void)0)
#define DDLogDo(...) ((void)0)
#define DDLogRead(...) ((void)0)
#define DDLogWrite(...) ((void)0)
#define DDLogComplete(...) ((void)0)
#define DDLogProfile(...) ((void)0)
#define DDLogDel(...) ((void)0)
#define DDLogProxied(...) ((void)0)
#define DDLogNetworking(...) ((void)0)
#define DDLogTodo(...) ((void)0)

#endif
