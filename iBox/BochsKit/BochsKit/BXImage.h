//
//  BXImage.h
//  BochsKit
//
//  Created by Alsey Coleman Miller on 11/8/14.
//  Copyright (c) 2014 Bochs. All rights reserved.
//

#import <Foundation/Foundation.h>

// BXImage main funtion
int BXImageMain(int argc, char *argv[]);

@interface BXImage : NSObject

+(BOOL)createImageWithURL:(NSURL *)url sizeInMB:(NSUInteger)sizeInMB heads:(NSUInteger)heads cylinders:(NSUInteger)cylinders tracksPerSector:(NSUInteger)tracksPerSector;

@end
