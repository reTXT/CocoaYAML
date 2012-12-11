//
//  CYAMLDeserializer.m
//  LayoutTest
//
//  Created by Jonathan Wight on 12/8/12.
//  Copyright (c) 2012 toxicsoftware. All rights reserved.
//

#import "CYAMLDeserializer.h"

#include <yaml.h>

typedef enum {
	Mode_Stream,
	Mode_Document,
	Mode_Sequence,
	Mode_Mapping,
	} EMode;

static id EventLoop(CYAMLDeserializer *deserializer, yaml_parser_t *parser, int depth, EMode mode, id container, NSError **outError);
static id ValueForScalar(CYAMLDeserializer *deserializer, const yaml_event_t *inEvent, NSError **outError);

@interface CYAMLDeserializer()
@property (readwrite, nonatomic, assign) yaml_parser_t *parser;
@property (readwrite, nonatomic, strong) NSMutableDictionary *objectsForAnchors;
@property (readwrite, nonatomic, strong) NSMutableDictionary *tagHandlers;
@end

#pragma mark -

@implementation CYAMLDeserializer

- (id)init
    {
    if ((self = [super init]) != NULL)
        {
        _assumeSingleDocument = YES;
		_tagHandlers = [NSMutableDictionary dictionary];

		[self registerDefaultHandlers];
        }
    return self;
    }

- (void)registerHandlerForTag:(NSString *)inTag block:(id (^)(id, NSError **))inBlock
	{
	self.tagHandlers[inTag] = [inBlock copy];
	}

- (void)registerDefaultHandlers
	{
	[self registerHandlerForTag:[NSString stringWithUTF8String:YAML_NULL_TAG] block:^(id inValue, NSError **outError) {
		return([NSNull null]);
		}];
	[self registerHandlerForTag:[NSString stringWithUTF8String:YAML_BOOL_TAG] block:^(id inValue, NSError **outError) {
		return(@([inValue boolValue]));
		}];
	[self registerHandlerForTag:[NSString stringWithUTF8String:YAML_STR_TAG] block:^(id inValue, NSError **outError) {
		return(inValue);
		}];
	[self registerHandlerForTag:[NSString stringWithUTF8String:YAML_INT_TAG] block:^(id inValue, NSError **outError) {
		return(@([inValue integerValue]));
		}];
	[self registerHandlerForTag:[NSString stringWithUTF8String:YAML_FLOAT_TAG] block:^(id inValue, NSError **outError) {
		return(@([inValue doubleValue]));
		}];

	[self registerHandlerForTag:@"tag:yaml.org,2002:binary" block:^(id inValue, NSError **outError) {
		return(inValue);
		}];
	}

- (id)deserializeData:(NSData *)inData error:(NSError **)outError
	{
	self.objectsForAnchors = [NSMutableDictionary dictionary];

	_parser = malloc(sizeof(*_parser));
	yaml_parser_initialize(_parser);

	yaml_parser_set_input_string(_parser, [inData bytes], [inData length]);

	id theRootObject = [self deserialize:outError];

	yaml_parser_delete(_parser);
	free(_parser);

	if (self.assumeSingleDocument == YES)
		{
		return(theRootObject[0]);
		}
	else
		{
		return(theRootObject);
		}
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
	NSError *theError = NULL;
	NSMutableArray *theDocuments = [NSMutableArray array];
	EventLoop(self, _parser, 0, Mode_Stream, theDocuments, &theError);
	if (theError != NULL)
		{
		if (outError != NULL)
			{
			*outError = theError;
			}
		return(NULL);
		}
	return(theDocuments);
	}

#pragma mark -

- (NSError *)currentError
	{
	NSError *theError = [NSError errorWithDomain:@"libyaml" code:_parser->error userInfo:@{
		NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%s", _parser->problem],
		@"offset": @(_parser->offset),
		}];
	return(theError);
	}

@end

static id EventLoop(CYAMLDeserializer *deserializer, yaml_parser_t *parser, int depth, EMode mode, id container, NSError **outError)
	{
	id theResult = NULL;
	id theKey = NULL;
	NSError *theError = NULL;
	BOOL theDoneFlag = NO;

	while (theDoneFlag == NO && theError == NULL)
		{
		yaml_event_t theEvent;
		if (!yaml_parser_parse(parser, &theEvent))
			{
			theError = [NSError errorWithDomain:@"libyaml" code:parser->error userInfo:@{
				NSLocalizedDescriptionKey: [NSString stringWithUTF8String:parser->problem],
				@"offset": @(parser->offset),
				}];

			if (outError != NULL)
				{
				*outError = theError;
				}
			return(NULL);
			}

		id theObject = NULL;
		NSString *theAnchor = NULL;

#if 0
		NSLog(@"% 2d %@ %@ %@ %p", depth,
			[@[@"stream",@"document",@"sequence",@"mapping"][mode] stringByPaddingToLength:10 withString:@" " startingAtIndex:0],
			[@[@"no",@"stream_start",@"stream_end",@"doc_start",@"doc_end",@"alias",@"scalar",@"seq_start",@"seq_end",@"map_start",@"map_end"][theEvent.type] stringByPaddingToLength:10 withString:@" " startingAtIndex:0],
			NSStringFromClass([container class]),
			container
			);
#endif

		switch (theEvent.type)
			{
			case YAML_NO_EVENT: // 0
				{
				theError = [NSError errorWithDomain:@"CocoaYAML" code:-1 userInfo:@{
					NSLocalizedDescriptionKey: @"Received unexpected YAML_NO_EVENT.",
					@"offset": @(parser->offset),
					}];
				}
				break;
			case YAML_STREAM_START_EVENT: // 1
				{
				if (mode != Mode_Stream)
					{
					theError = [NSError errorWithDomain:@"CocoaYAML" code:-1 userInfo:@{
						NSLocalizedDescriptionKey: @"Received unexpected YAML_STREAM_START_EVENT.",
						@"offset": @(parser->offset),
						}];
					}
				}
				break;
			case YAML_STREAM_END_EVENT: // 2
				{
				if (mode != Mode_Stream)
					{
					theError = [NSError errorWithDomain:@"CocoaYAML" code:-1 userInfo:@{
						NSLocalizedDescriptionKey: @"Received unexpected YAML_STREAM_END_EVENT.",
						@"offset": @(parser->offset),
						}];
					}
				else
					{
					theDoneFlag = YES;
					}
				}
				break;
			case YAML_DOCUMENT_START_EVENT: // 3
				{
				if (mode != Mode_Stream)
					{
					theError = [NSError errorWithDomain:@"CocoaYAML" code:-1 userInfo:@{
						NSLocalizedDescriptionKey: @"Received unexpected YAML_DOCUMENT_START_EVENT.",
						@"offset": @(parser->offset),
						}];
					}
				else
					{
					theObject = EventLoop(deserializer, parser, depth+1, Mode_Document, container, &theError);
					}
				}
				break;
			case YAML_DOCUMENT_END_EVENT: // 4
				{
				if (mode != Mode_Document)
					{
					theError = [NSError errorWithDomain:@"CocoaYAML" code:-1 userInfo:@{
						NSLocalizedDescriptionKey: @"Received unexpected YAML_DOCUMENT_END_EVENT.",
						@"offset": @(parser->offset),
						}];
					}
				else
					{
					theDoneFlag = YES;
					}
				}
				break;
			case YAML_ALIAS_EVENT: // 5
				{
				NSString *theAnchor = [NSString stringWithUTF8String:(const char *)theEvent.data.alias.anchor];
				theObject = deserializer.objectsForAnchors[theAnchor];
				if (theObject == NULL)
					{
					theError = [NSError errorWithDomain:@"CocoaYAML" code:-1 userInfo:@{
						NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Could not find tagged object with anchor %@", theAnchor],
						@"offset": @(parser->offset),
						}];
					}
				}
				break;
			case YAML_SCALAR_EVENT: // 6
				{
				theObject = ValueForScalar(deserializer, &theEvent, &theError);
				if (theEvent.data.scalar.anchor != NULL)
					{
					theAnchor = [NSString stringWithUTF8String:(const char *)theEvent.data.scalar.anchor];
					}
				}
				break;
			case YAML_SEQUENCE_START_EVENT: // 7
				{
				NSMutableArray *theArray = [NSMutableArray array];
				EventLoop(deserializer, parser, depth + 1, Mode_Sequence, theArray, &theError);
				theObject = theArray;
				if (theEvent.data.sequence_start.anchor != NULL)
					{
					theAnchor = [NSString stringWithUTF8String:(const char *)theEvent.data.sequence_start.anchor];
					}
				}
				break;
			case YAML_SEQUENCE_END_EVENT: // 8
				{
				if (mode != Mode_Sequence)
					{
					theError = [NSError errorWithDomain:@"CocoaYAML" code:-1 userInfo:@{
						NSLocalizedDescriptionKey: @"Received unexpected YAML_SEQUENCE_END_EVENT.",
						@"offset": @(parser->offset),
						}];
					}
				else
					{
					theDoneFlag = YES;
					}
				}
				break;
			case YAML_MAPPING_START_EVENT: // 9
				{
				NSMutableDictionary *theDictionary = [NSMutableDictionary dictionary];
				EventLoop(deserializer, parser, depth + 1, Mode_Mapping, theDictionary, &theError);
				theObject = theDictionary;
				if (theEvent.data.mapping_start.anchor != NULL)
					{
					theAnchor = [NSString stringWithUTF8String:(const char *)theEvent.data.mapping_start.anchor];
					}
				}
				break;
			case YAML_MAPPING_END_EVENT: // 10
				{
				if (mode != Mode_Mapping)
					{
					theError = [NSError errorWithDomain:@"CocoaYAML" code:-1 userInfo:@{
						NSLocalizedDescriptionKey: @"Received unexpected YAML_MAPPING_END_EVENT.",
						@"offset": @(parser->offset),
						}];
					}
				theDoneFlag = YES;
				}
				break;
			default:
				{
				theError = [NSError errorWithDomain:@"CocoaYAML" code:-1 userInfo:@{
					NSLocalizedDescriptionKey: @"Received unknown event type.",
					@"offset": @(parser->offset),
					}];
				}
				break;
			}

		yaml_event_delete(&theEvent);

		if (theError)
			{
			if (outError)
				{
				*outError = theError;
				}
			return(NULL);
			}

		if (theObject)
			{
			if (theAnchor)
				{
				deserializer.objectsForAnchors[theAnchor] = theObject;
				}

			if (mode == Mode_Sequence || mode == Mode_Stream || mode == Mode_Document)
				{
				NSCParameterAssert(container);
				NSCParameterAssert([container isKindOfClass:[NSMutableArray class]]);
				[container addObject:theObject];
				}
			else if (mode == Mode_Mapping)
				{
				NSCParameterAssert(container);
				NSCParameterAssert([container isKindOfClass:[NSMutableDictionary class]]);
				if (theKey == NULL)
					{
					theKey = theObject;
					}
				else
					{
					container[theKey] = theObject;
					theKey = NULL;
					}
				}
			else
				{
				NSCParameterAssert(NO);
				}
			}
		}

	return(theResult);
	}

static id ValueForScalar(CYAMLDeserializer *deserializer, const yaml_event_t *inEvent, NSError **outError)
	{
	id theValue = NULL;
	NSString *theString = [[NSString alloc] initWithUTF8String:(const char *)inEvent->data.scalar.value];
	NSString *theTag = NULL;
	const yaml_scalar_style_t theStyle = inEvent->data.scalar.style;

	if (inEvent->data.scalar.tag != NULL)
		{
		theTag = [NSString stringWithUTF8String:(const char *)inEvent->data.scalar.tag];
		}

	if (theTag == NULL)
		{
		if (theStyle == YAML_SINGLE_QUOTED_SCALAR_STYLE || theStyle == YAML_DOUBLE_QUOTED_SCALAR_STYLE || theStyle == YAML_LITERAL_SCALAR_STYLE)
			{
			theTag = @YAML_STR_TAG;
			}
		}

	if (theTag == NULL)
		{
		// The NSRegularExpression class is currently only available in the Foundation framework of iOS 4
		NSError *error = NULL;
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^-?\\d+$" options:0 error:&error];
		NSUInteger numberOfMatches = [regex numberOfMatchesInString:theString options:0 range:NSMakeRange(0, [theString length])];
		if (numberOfMatches == 1)
			{
			theTag = @YAML_INT_TAG;
			}
		}

	if (theTag == NULL)
		{
		// The NSRegularExpression class is currently only available in the Foundation framework of iOS 4
		NSError *error = NULL;
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^(-?[1-9]\\d*(\\.\\d*)?(e[-+]?[1-9][0-9]+)?|0|inf|-inf|nan)$" options:0 error:&error];
		NSUInteger numberOfMatches = [regex numberOfMatchesInString:theString options:0 range:NSMakeRange(0, [theString length])];
		if (numberOfMatches == 1)
			{
			theTag = @YAML_FLOAT_TAG;
			}
		}

	if (theTag != NULL)
		{
		id (^theHandler)(NSString *, NSError **) = deserializer.tagHandlers[theTag];
		if (theHandler)
			{
			theValue = theHandler(theString, outError);
			}
		else
			{
			if (outError)
				{
				*outError = [NSError errorWithDomain:@"TODO" code:-1 userInfo:@{
					NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Unhandled tag type: %@ (value: %@)", theTag, theString],
					@"offset": @(deserializer.parser->offset),
					}];
				}
			return(NULL);
			}
		}

	if (theValue == NULL)
		{
		NSDictionary *theConstantTags = @{
			@"true": [NSNumber numberWithBool:YES],
			@"false": [NSNumber numberWithBool:NO],
			@"yes": [NSNumber numberWithBool:YES],
			@"no": [NSNumber numberWithBool:NO],
			@"null": [NSNull null],
			@".inf": @(INFINITY),
			@"-.inf": @(-INFINITY),
			@"+.inf": @(INFINITY),
			@".nan": @(NAN),
			};
		theValue = theConstantTags[[theString lowercaseString]];
		}

	if (theValue == NULL)
		{
		theValue = theString;
		}

#if 0
	NSLog(@"%@ %d %@ %@ %@", theTag, theStyle, theString, theValue, NSStringFromClass([theValue class]));
#endif

	return(theValue);
	}


