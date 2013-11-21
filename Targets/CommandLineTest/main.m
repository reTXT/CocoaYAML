//
//  main.m
//  CocoaYAML
//
//  Created by Jonathan Wight on 12/10/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CYAMLDeserializer.h"

int main(int argc, const char * argv[])
	{
	@autoreleasepool
		{
		CYAMLDeserializer *theDeserializer = [[CYAMLDeserializer alloc] init];
		[theDeserializer registerHandlerForTag:@"!url" block:^(id inValue, NSError **outError) {
			return([NSURL URLWithString:inValue]);
			}];

		NSError *theError = NULL;
		NSURL *theURL = [NSURL fileURLWithPath:@"Samples/test2.yaml"];
		NSLog(@"%@", theURL);
		id theObject = [theDeserializer deserializeURL:theURL error:&theError];
		NSLog(@"Error: %@", theError);
		NSLog(@"Object: %@", theObject);
		NSLog(@"Object: %@", NSStringFromClass([theObject class]));
		}
    return 0;
	}

