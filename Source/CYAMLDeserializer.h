//
//  CYAMLDeserializer.h
//  TouchCode
//
//  Created by Jonathan Wight on 5/10/06.
//  Copyright 2011 toxicsoftware.com. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//     1. Redistributions of source code must retain the above copyright notice, this list of
//        conditions and the following disclaimer.
//
//     2. Redistributions in binary form must reproduce the above copyright notice, this list
//        of conditions and the following disclaimer in the documentation and/or other materials
//        provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY JONATHAN WIGHT ``AS IS'' AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JONATHAN WIGHT OR
//  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//  The views and conclusions contained in the software and documentation are those of the
//  authors and should not be interpreted as representing official policies, either expressed
//  or implied, of toxicsoftware.com.

#import <Foundation/Foundation.h>

@interface CYAMLDeserializer : NSObject

@property (readwrite, nonatomic, assign) BOOL assumeSingleDocument;

+ (instancetype)deserializer;

- (void)registerHandlerForTag:(NSString *)inTag block:(id (^)(id, NSError *__autoreleasing *))inBlock;
- (void)registerDefaultHandlers;

- (id)deserializeData:(NSData *)inData error:(NSError *__autoreleasing *)outError;
- (id)deserializeString:(NSString *)inString error:(NSError *__autoreleasing *)outError;
- (id)deserializeURL:(NSURL *)inURL error:(NSError *__autoreleasing *)outError;
- (id)deserializeFilename:(NSString *)inURL bundle:(NSBundle *)inBundle error:(NSError *__autoreleasing *)outError;

// Hooks for subclasses to control which classes are used for mapping and sequences.
- (id)makeMappingObject;
- (id)finalizeMappingObject:(id)inObject;
- (id)makeSequenceObject;
- (id)finalizeSequenceObject:(id)inObject;

@end
