//
//  ApplicationsWatcher.h
//  Objektiv
//
//  FSEvents watcher for the Applications folders, replacing CDEvents.
//

#import <Foundation/Foundation.h>

@interface ApplicationsWatcher : NSObject

- (instancetype)initWithPaths:(NSArray<NSString *> *)paths handler:(dispatch_block_t)handler;
- (void)stop;

@end
