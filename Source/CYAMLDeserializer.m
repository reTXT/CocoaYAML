//
//  CYAMLDeserializer.m
//  LayoutTest
//
//  Created by Jonathan Wight on 12/8/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CYAMLDeserializer.h"

#include <yaml.h>

static id ValueForScalar(const yaml_event_t *inEvent, NSError **outError);

@interface CYAMLDeserializer()
@property (readwrite, nonatomic, assign) yaml_parser_t *parser;
@end

#pragma mark -

@implementation CYAMLDeserializer

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        _assumeSingleDocument = YES;
        }
    return self;
    }

- (id)deserializeData:(NSData *)inData error:(NSError **)outError
	{
	_parser = malloc(sizeof(*_parser));
	yaml_parser_initialize(_parser);

	yaml_parser_set_input_string(_parser, [inData bytes], [inData length]);

	id theRootObject = [self deserialize:outError];

	yaml_parser_delete(_parser);
	free(_parser);

	return(theRootObject);
	}

- (id)deserializeString:(NSString *)inString error:(NSError **)outError;
	{
	NSData *theData = [inString dataUsingEncoding:NSUTF8StringEncoding];
	if (theData == NULL)
		{
		return(NULL);
		}
	return([self deserializeData:theData error:outError]);
	}

- (id)deserializeURL:(NSURL *)inURL error:(NSError **)outError
	{
	NSData *theData = [NSData dataWithContentsOfURL:inURL options:0 error:outError];
	if (theData == NULL)
		{
		return(NULL);
		}
	return([self deserializeData:theData error:outError]);
	}

#pragma mark -

- (id)deserialize:(NSError *__autoreleasing *)outError
	{
	id theRootObject = NULL;

	BOOL theDoneFlag = NO;
	while (!theDoneFlag)
		{
		yaml_event_t theEvent;

		/* Get the next event. */
		if (!yaml_parser_parse(_parser, &theEvent))
			{
			if (outError)
				{
				*outError = [NSError errorWithDomain:@"TODO" code:-10 userInfo:NULL];
				}
			return(NULL);
			}

		switch (theEvent.type)
			{
			case YAML_STREAM_START_EVENT:
				break;
			case YAML_STREAM_END_EVENT:
				{
				theDoneFlag = YES;
				}
				break;
			case YAML_DOCUMENT_START_EVENT:
				{
				theRootObject = [self processDocuments:outError];
				if (theRootObject == NULL)
					{
					return(NULL);
					}
				}
				break;
			case YAML_SCALAR_EVENT:
				{
				theRootObject = ValueForScalar(&theEvent, outError);
				if (theRootObject == NULL)
					{
					return(NULL);
					}
				}
				break;
			case YAML_SEQUENCE_START_EVENT:
				{
				theRootObject = [self processSequence:outError];
				if (theRootObject == NULL)
					{
					return(NULL);
					}
				}
				break;
			case YAML_MAPPING_START_EVENT:
				{
				theRootObject = [self processMapping:outError];
				if (theRootObject == NULL)
					{
					return(NULL);
					}
				}
				break;
			default:
				{
				if (outError)
					{
					*outError = [NSError errorWithDomain:@"TODO" code:-1 userInfo:NULL];
					}
				return(NULL);
				}
			}

		/* The application is responsible for destroying the event object. */
		yaml_event_delete(&theEvent);
		}

	if (self.assumeSingleDocument)
		{
		theRootObject = theRootObject[0];
		}

	return(theRootObject);
	}

- (NSArray *)processDocuments:(NSError **)outError
	{
	NSMutableArray *theArray = [NSMutableArray array];

	BOOL theDoneFlag = NO;
	while (!theDoneFlag)
		{
		yaml_event_t theEvent;

		/* Get the next event. */
		if (!yaml_parser_parse(_parser, &theEvent))
			{
			if (outError)
				{
				*outError = [NSError errorWithDomain:@"TODO" code:-11 userInfo:NULL];
				}
			return(NULL);
			}

		id theObject = NULL;

		switch (theEvent.type)
			{
			case YAML_DOCUMENT_END_EVENT:
				{
				theDoneFlag = YES;
				}
				break;
			case YAML_SCALAR_EVENT:
				theObject = ValueForScalar(&theEvent, outError);
				if (theObject == NULL)
					{
					return(NULL);
					}
				break;
			case YAML_SEQUENCE_START_EVENT:
				{
				theObject = [self processSequence:outError];
				if (theObject == NULL)
					{
					return(NULL);
					}
				}
				break;
			case YAML_MAPPING_START_EVENT:
				{
				theObject = [self processMapping:outError];
				if (theObject == NULL)
					{
					return(NULL);
					}
				}
				break;
			default:
				{
				if (outError)
					{
					*outError = [NSError errorWithDomain:@"TODO" code:-2 userInfo:NULL];
					}
				return(NULL);
				}
			}

		yaml_event_delete(&theEvent);

		if (theObject)
			{
			[theArray addObject:theObject];
			}
		}
	return(theArray);
	}


#pragma mark -

- (NSDictionary *)processMapping:(NSError **)outError
	{
	NSMutableDictionary *theDictionary = [NSMutableDictionary dictionary];

	id theKey = NULL;

	BOOL theDoneFlag = NO;
	while (!theDoneFlag)
		{
		yaml_event_t theEvent;

		/* Get the next event. */
		if (!yaml_parser_parse(_parser, &theEvent))
			{
			if (outError)
				{
				*outError = [NSError errorWithDomain:@"TODO" code:-12 userInfo:NULL];
				}
			return(NULL);
			}

		id theObject = NULL;

		switch (theEvent.type)
			{
			case YAML_SCALAR_EVENT:
				{
				theObject = ValueForScalar(&theEvent, outError);
				if (theObject == NULL)
					{
					return(NULL);
					}
				}
				break;
			case YAML_SEQUENCE_START_EVENT:
				{
				theObject = [self processSequence:outError];
				if (theObject == NULL)
					{
					return(NULL);
					}
				}
				break;
			case YAML_MAPPING_START_EVENT:
				{
				theObject = [self processMapping:outError];
				if (theObject == NULL)
					{
					return(NULL);
					}
				}
				break;
			case YAML_MAPPING_END_EVENT:
				{
				theDoneFlag = YES;
				}
				break;
			default:
				{
				if (outError)
					{
					*outError = [NSError errorWithDomain:@"TODO" code:-3 userInfo:NULL];
					}
				return(NULL);
				}
			}

		yaml_event_delete(&theEvent);

		if (theKey == NULL)
			{
			theKey = theObject;
			}
		else
			{
			theDictionary[theKey] = theObject;
			theKey = NULL;
			}
		}
	return(theDictionary);
	}

- (NSArray *)processSequence:(NSError **)outError
	{
	NSMutableArray *theArray = [NSMutableArray array];

	BOOL theDoneFlag = NO;
	while (!theDoneFlag)
		{
		yaml_event_t theEvent;

		/* Get the next event. */
		if (!yaml_parser_parse(_parser, &theEvent))
			{
			if (outError)
				{
				*outError = [NSError errorWithDomain:@"TODO" code:-13 userInfo:NULL];
				}
			return(NULL);
			}

		id theObject = NULL;

		switch (theEvent.type)
			{
			case YAML_SCALAR_EVENT:
				{
				theObject = ValueForScalar(&theEvent, outError);
				if (theObject == NULL)
					{
					return(NULL);
					}
				}
				break;
			case YAML_SEQUENCE_START_EVENT:
				{
				theObject = [self processSequence:outError];
				if (theObject == NULL)
					{
					return(NULL);
					}
				}
				break;
			case YAML_SEQUENCE_END_EVENT:
				{
				theDoneFlag = YES;
				}
				break;
			case YAML_MAPPING_START_EVENT:
				{
				theObject = [self processMapping:outError];
				if (theObject == NULL)
					{
					return(NULL);
					}
				}
				break;
			default:
				{
				if (outError)
					{
					*outError = [NSError errorWithDomain:@"TODO" code:-4 userInfo:NULL];
					}
				return(NULL);
				}
				break;
			}

		yaml_event_delete(&theEvent);

		if (theObject)
			{
			[theArray addObject:theObject];
			}
		}
	return(theArray);
	}

@end

static id ValueForScalar(const yaml_event_t *inEvent, NSError **outError)
	{
	id theValue = NULL;
	NSString *theString = [[NSString alloc] initWithUTF8String:(const char *)inEvent->data.scalar.value];
	switch (inEvent->data.scalar.style)
		{
		case YAML_PLAIN_SCALAR_STYLE:
			{
			if (inEvent->data.scalar.tag == NULL)
				{
				NSDictionary *theConstantTags = @{
					@"true": [NSNumber numberWithBool:YES],
					@"false": [NSNumber numberWithBool:NO],
					@"null": [NSNull null],
					};
				theValue = theConstantTags[theString];
				if (theValue != NULL)
					{
					break;
					}

				// The NSRegularExpression class is currently only available in the Foundation framework of iOS 4
				NSError *error = NULL;
				NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^-?\\d+$" options:0 error:&error];
				NSUInteger numberOfMatches = [regex numberOfMatchesInString:theString options:0 range:NSMakeRange(0, [theString length])];
				if (numberOfMatches == 1)
					{
					theValue = @([theString integerValue]);
					break;
					}

				// The NSRegularExpression class is currently only available in the Foundation framework of iOS 4
				regex = [NSRegularExpression regularExpressionWithPattern:@"^(-?[1-9]\\d*(\\.\\d*)?(e[-+]?[1-9][0-9]+)?|0|inf|-inf|nan)$" options:0 error:&error];
				numberOfMatches = [regex numberOfMatchesInString:theString options:0 range:NSMakeRange(0, [theString length])];
				if (numberOfMatches == 1)
					{
					theValue = @([theString doubleValue]);
					break;
					}

				theValue = theString;
				break;
				}
			else
				{
				NSCParameterAssert(NO);
				}
			}
			break;
		case YAML_SINGLE_QUOTED_SCALAR_STYLE:
		case YAML_DOUBLE_QUOTED_SCALAR_STYLE:
			{
			theValue = theString;
			}
			break;
		case YAML_ANY_SCALAR_STYLE:
		case YAML_LITERAL_SCALAR_STYLE:
		case YAML_FOLDED_SCALAR_STYLE:
			NSLog(@"########  UNKNOWN STYLE: %d", inEvent->data.scalar.style);
			NSCParameterAssert(NO);
			break;
		}

	return(theValue);
	}


