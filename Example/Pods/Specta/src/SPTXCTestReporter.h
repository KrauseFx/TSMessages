#import "SPTReporter.h"

/**
 *  Reporter that produces output identical to XCode's default output. Useful when integrating with 3rd-party tools that
 *  may not like SPTNestedReporter's indented output.
 */
@interface SPTXCTestReporter : SPTReporter

@end
