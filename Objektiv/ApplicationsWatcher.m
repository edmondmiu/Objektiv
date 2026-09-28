//
//  ApplicationsWatcher.m
//  Objektiv
//

#import "ApplicationsWatcher.h"
#import <CoreServices/CoreServices.h>

@implementation ApplicationsWatcher {
    FSEventStreamRef stream;
    dispatch_block_t handler;
    NSSet<NSString *> *roots;
}

static void ApplicationsWatcherCallback(ConstFSEventStreamRef streamRef, void *info, size_t count,
                                        void *paths, const FSEventStreamEventFlags flags[],
                                        const FSEventStreamEventId ids[])
{
    // Only react to apps appearing or disappearing at the top level,
    // not to changes inside app bundles (e.g. browser self-updates).
    ApplicationsWatcher *watcher = (__bridge ApplicationsWatcher *)info;
    char **eventPaths = paths;
    for (size_t i = 0; i < count; i++) {
        NSString *path = [@(eventPaths[i]) stringByStandardizingPath];
        if ([watcher->roots containsObject:path]) {
            if (watcher->handler) watcher->handler();
            return;
        }
    }
}

- (instancetype)initWithPaths:(NSArray<NSString *> *)paths handler:(dispatch_block_t)aHandler
{
    self = [super init];
    if (self) {
        handler = [aHandler copy];
        NSMutableSet *standardized = [NSMutableSet set];
        for (NSString *path in paths) [standardized addObject:[path stringByStandardizingPath]];
        roots = standardized;
        FSEventStreamContext context = { 0, (__bridge void *)self, NULL, NULL, NULL };
        // Directory-level events with a 2s latency: one refresh per install/removal burst.
        stream = FSEventStreamCreate(NULL, ApplicationsWatcherCallback, &context,
                                     (__bridge CFArrayRef)paths, kFSEventStreamEventIdSinceNow,
                                     2.0, kFSEventStreamCreateFlagNone);
        if (stream) {
            FSEventStreamSetDispatchQueue(stream, dispatch_get_main_queue());
            FSEventStreamStart(stream);
        }
    }
    return self;
}

- (void)stop
{
    if (!stream) return;
    FSEventStreamStop(stream);
    FSEventStreamInvalidate(stream);
    FSEventStreamRelease(stream);
    stream = NULL;
}

- (void)dealloc
{
    [self stop];
}

@end
