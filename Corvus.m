//
//  Corvus.m
//
//  Created by Jonas Schmid on 04/04/14.
//  Copyright (c) 2014 schmid. All rights reserved.
//

#import "Corvus.h"

#import "SentryClient.h"

@implementation Corvus

static Corvus *sharedInstance;

+ (void)initialize {
  sharedInstance = [Corvus new];
}

+ (Corvus *)sharedInstance {
  return sharedInstance;
}

- (void)logMessage:(DDLogMessage *)logMessage {
  NSString *logMsg = logMessage->_message;

  if (_logFormatter) {
    logMsg = [_logFormatter formatLogMessage:logMessage];
  }

  if (logMsg) {

    SentryLog sentryLogLevel = .None;
    switch (logMessage->_flag) {
    case DDLogFlagError:
      sentryLogLevel = .Error;
      break;

    case DDLogFlagWarning:
      sentryLogLevel = .Debug;
      break;

    case DDLogFlagInfo:
      sentryLogLevel = .Debug;
      break;

    case DDLogFlagDebug:
      sentryLogLevel = .Debug;
      break;

    case DDLogFlagVerbose:
      sentryLogLevel = .Debug;
      break;

    default:
      break;
    }

// TODO switch to building the Event object so we can attach a stacktrace
    [[SentryClient sharedClient] message:logMsg
                                   level:sentryLogLevel
//                                        method:[logMessage->_function UTF8String]
//                                          file:[logMessage->_fileName UTF8String]
//                                          line:logMessage->_line];
  }
}

@end
