//
//  CYAMLDeserializer.h
//  LayoutTest
//
//  Created by Jonathan Wight on 12/8/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CYAMLDeserializer : NSObject

@property (readwrite, nonatomic, assign) BOOL assumeSingleDocument;

- (id)deserializeData:(NSData *)inData error:(NSError **)outError;
- (id)deserializeString:(NSString *)inString error:(NSError **)outError;
- (id)deserializeURL:(NSURL *)inURL error:(NSError **)outError;

@end
