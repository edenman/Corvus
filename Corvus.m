//
//  Corvus.m
//
//  Created by Jonas Schmid on 04/04/14.
//  Copyright (c) 2014 schmid. All rights reserved.
//

#import "Corvus.h"

@import SentrySwift;

@implementation Corvus

static Corvus *sharedInstance;

+ (void)initialize {
  sharedInstance = [Corvus new];
}

+ (Corvus *)sharedInstance {
  return sharedInstance;
}

- (Stacktrace *)buildStacktrace {
  NSArray<NSString *> *symbols = [NSThread callStackSymbols];
  NSMutableArray<Frame *> *frames = [NSMutableArray array];
  for (int c = 0; c < symbols.count; c++) {
    // TODO parse the actual symbols[c] string, if we're able to get the real ones
    // TODO as opposed to the worker thread stack we get here :(
    [frames addObject:[[Frame alloc] initWithFile:symbols[c]
                                         function:@"Foo"
                                           module:@"Bar"
                                             line:123]];
  }
  NSArray<Frame *> *immutableFrames = [NSArray arrayWithArray:frames];
  return [[Stacktrace alloc] initWithFrames:immutableFrames];
}

- (void)logMessage:(DDLogMessage *)logMessage {
  NSString *logMsg = logMessage->_message;

  if (_logFormatter) {
    logMsg = [_logFormatter formatLogMessage:logMessage];
  }

  Stacktrace *stacktrace = nil;
  if (logMsg) {

    SentryLog sentryLogLevel = SentryLogNone;
    switch (logMessage->_flag) {
    case DDLogFlagError:
      sentryLogLevel = SentryLogError;
      stacktrace = [self buildStacktrace];
      break;

    case DDLogFlagWarning:
      sentryLogLevel = SentryLogDebug;
      break;

    case DDLogFlagInfo:
      sentryLogLevel = SentryLogDebug;
      break;

    case DDLogFlagDebug:
      sentryLogLevel = SentryLogDebug;
      break;

    case DDLogFlagVerbose:
      sentryLogLevel = SentryLogDebug;
      break;

    default:
      break;
    }

    Event *event = [[Event alloc] init:logMsg
                             timestamp:[NSDate date]
                                 level:sentryLogLevel
                                logger:nil
                               culprit:nil
                            serverName:nil
                               release:nil
                                  tags:nil
                               modules:nil
                                 extra:nil
                           fingerprint:nil
                                  user:nil
                             exception:nil
                            stacktrace:stacktrace
                      appleCrashReport:nil];
    [[SentryClient shared] captureEvent:event];
  }
}

@end

