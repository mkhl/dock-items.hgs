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
@end

@implementation DockItemsSource

- (id)initWithConfiguration:(NSDictionary *)configuration
{
  self = [super initWithConfiguration:configuration];
  if (self == nil)
    return nil;
  if (![self loadResultsCache]) {
    [self recacheContents];
  } else {
    [self performSelector:@selector(recacheContents)
               withObject:nil
               afterDelay:10.0];
  }
  return self;
}

- (void)recacheContents
{
  [self clearResultIndex];
  NSDictionary *settings = [[NSUserDefaults standardUserDefaults]
                            persistentDomainForName:kDockBundleIdentifier];
  for (NSDictionary *item in [settings valueForKey:kDockItemsKey]) {
    NSString *path = [item valueForKeyPath:kDockItemPathKey];
    [self indexResult:[HGSResult resultWithFilePath:path
                                             source:self
                                         attributes:nil]];
  }
  [self performSelector:@selector(recacheContents)
             withObject:nil
             afterDelay:60.0];
}

@end
