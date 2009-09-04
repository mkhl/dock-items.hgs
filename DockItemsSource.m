//
//  DockItemsSource.m
//
//  Copyright (c) 2009  Martin Kuehl <purl.org/net/mkhl>
//  Licensed under the MIT License.
//

#import <Vermilion/Vermilion.h>

static NSString *const kDockBundleIdentifier = @"com.apple.Dock";
static NSString *const kDockItemsKey = @"persistent-others";
static NSString *const kDockItemPathKey = @"tile-data.file-data._CFURLString";

@interface DockItemsSource : HGSMemorySearchSource
- (void)recacheContents;
- (void)recacheContentsAfterDelay:(NSTimeInterval)delay;
- (void)indexItemAtPath:(NSString *)path;
@end

@implementation DockItemsSource

- (id)initWithConfiguration:(NSDictionary *)configuration
{
  self = [super initWithConfiguration:configuration];
  if (self == nil)
    return nil;
  if ([self loadResultsCache])
    [self recacheContentsAfterDelay:10.0];
  else
    [self recacheContents];
  return self;
}

- (void)recacheContents
{
  [self clearResultIndex];
  NSDictionary *settings = [[NSUserDefaults standardUserDefaults]
                            persistentDomainForName:kDockBundleIdentifier];
  for (NSDictionary *item in [settings valueForKey:kDockItemsKey])
    [self indexItemAtPath:[item valueForKeyPath:kDockItemPathKey]];
  [self recacheContentsAfterDelay:60.0];
}

- (void)recacheContentsAfterDelay:(NSTimeInterval)delay
{
  [self performSelector:@selector(recacheContents)
             withObject:nil
             afterDelay:delay];
}

- (void)indexItemAtPath:(NSString *)path
{
  [self indexResult:[HGSResult resultWithFilePath:path
                                           source:self
                                       attributes:nil]];
  NSFileManager *manager = [NSFileManager defaultManager];
  for (NSString *subpath in [manager directoryContentsAtPath:path]) {
    if ([subpath hasPrefix:@"."]) continue;
    subpath = [path stringByAppendingPathComponent:subpath];
    [self indexResult:[HGSResult resultWithFilePath:subpath
                                             source:self
                                         attributes:nil]];
  }
}

@end
