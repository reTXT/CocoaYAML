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
		NSError *theError = NULL;
		id theObject = [theDeserializer deserializeURL:[NSURL fileURLWithPath:@"/Users/schwa/Desktop/CocoaYAML/Samples/test1.yaml"] error:&theError];
		NSLog(@"Error: %@", theError);
		NSLog(@"Object: %@", theObject);
		}
    return 0;
	}

