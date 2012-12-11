//
//  Unit_Tests.m
//  Unit Tests
//
//  Created by Jonathan Wight on 12/10/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "Unit_Tests.h"

#import "CYAMLDeserializer.h"

@implementation Unit_Tests

//- (void)setUp
//{
//    [super setUp];
//    
//    // Set-up code here.
//}
//
//- (void)tearDown
//{
//    // Tear-down code here.
//    
//    [super tearDown];
//}

- (void)testExample
	{
	CYAMLDeserializer *theDeserializer = [[CYAMLDeserializer alloc] init];
	NSError *theError = NULL;
	id theResult = NULL;

	id theYAML = NULL;
	id theExpectedResult = NULL;

	// #########################################################################

	theYAML = @"3.14";
	theExpectedResult = @(3.14);
	theResult = [theDeserializer deserializeString:theYAML error:&theError];
	STAssertEqualObjects(theResult, theExpectedResult, NULL);

	// #########################################################################

	theYAML = @"0.0";
	theExpectedResult = @(0.0);
	theResult = [theDeserializer deserializeString:theYAML error:&theError];
	STAssertEqualObjects(theResult, theExpectedResult, NULL);

	// #########################################################################


//	theYAML = @".0";
//	theExpectedResult = @(0.0);
//	theResult = [theDeserializer deserializeString:theYAML error:&theError];
//	STAssertEqualObjects(theResult, theExpectedResult, NULL);

	}

@end
