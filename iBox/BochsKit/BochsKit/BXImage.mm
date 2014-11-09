//
//  BXImage.mm
//  BochsKit
//
//  Created by Alsey Coleman Miller on 11/8/14.
//  Copyright (c) 2014 Bochs. All rights reserved.
//

#import "BXImage.h"

@implementation BXImage

int main(int, char *[]);

+(void)createImageWithURL:(NSURL *)url sizeInMB:(NSUInteger)sizeInMB completion:(void (^)(BOOL success))completion
{
    // execute on background operation queue
    [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
        
        // number of arguments
        int argc = 5;
        
        char *argv[] = {(char *)"-q", (char *)"-hd", (char *)"-mode=flat", (char *)url.path.UTF8String, (char *)[NSString stringWithFormat:@"-size=%ld", (unsigned long)sizeInMB].UTF8String};
        
        int exitCode = main(argc, argv);
        
        completion(!exitCode);
        
    }];
}

+(NSUInteger)numberOfCylindersForImageWithSizeInMB:(NSUInteger)sizeInMB
{
    return ((int)sizeInMB) * 1024.0 * 1024.0 / 16.0 / 63.0 / 512.0;
}

@end
