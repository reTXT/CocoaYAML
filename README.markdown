# CocoaYAML

Yet another ([open source][]) Objective-C [yaml][] library. _Important_: [Deserialization only][#4] for now.

Based on [libyaml][] for parsing. Supports many [tag types][] including the base-64 encoded [binary][] tag type.

Don't forget to get the submodules when cloning this project.

    git submodule --init --recursive

## How to use

This repository comes with an Xcode project that builds a iOS static library. Include the project and the relevent .h files and then link the static library. I assume you're not an idiot and know how to do that. For idiots I'll consider setting up a [Cocoapods][#7] project.

    #import "CYAMLDeserializer.h"

    CYAMLDeserializer *theDeserializer = [[CYAMLDeserializer alloc] init];
    id theObject = [theDeserializer deserializeData:theData error:NULL];
    
## But what about documents?

By default CocoaYAML assumes that your YAML file contains a single logical document. The deserialize methods will return the contents of that document. If you want to access all documents then do the following:

    CYAMLDeserializer *theDeserializer = [[CYAMLDeserializer alloc] init];
    theDeserializer.assumeSingleDocument = NO;
    id theObject = [theDeserializer deserializeData:theData error:NULL];

## How to define your own tag types:

You can create your own tag type:

    [self registerHandlerForTag:@"!url" block:^(id inValue, NSError **outError) {
        return([NSURL URLWithString:inValue]);
        }];
        
You can use the '!url' tag to create NSURLs.

    link: !url http://example.com/

## Oh fuck not more NSNulls?

Yes. Get over it. If you don't want to handle NSNull objects in your code you need to make sure your data doesn't contain yaml null objects.

## Can't you just make them go away? I'm delicate!

If I remove NSNull objects then the Objective-C representation won't totally match the YAML representation. Going from YAML -> Objective-C -> YAML would be a lossy operation.

A simple macro like the following should make it easy to deal with:

    #define NULLIFY(x) (x) == NULL || (x) == [NSNull null] ? NULL : (x)
    
If it would make you feel better you could call it NILLIFY instead. You already have my contempt anyway.

## No really I must never see an NSNull in my code because I am a poor programmer and I love to send messages to objects without any idea what their actual type is

[Fine][#9]

## This NSNull thing is a pet peeve of yours isn't it?

Yes.

## Yuck whitespace is important in YAML? What is this python?

Yes, it can make editing a chore. Make sure you have your text editor set to use whitespace for tabs, and use a 2 character tab width. Using the following tagline at the top of your text file might help (does with BBEdit)

    # -*- tab-width: 2; indent-tabs-mode: nil; coding: utf-8; mode: yaml; -*-

## Other Objective-C YAML projects

This wouldn't be an Objective-C data deserializer if there weren't at least four other implementations.

* https://github.com/mirek/YAML.framework
* https://github.com/marvelph/Yaml
* http://www.cybergarage.org/twiki/bin/view/Main/YamlForObjC
* https://github.com/indeyets/syck/tree/master/ext/cocoa/src/

   [yaml]: http://yaml.org
   [#4]: https://github.com/schwa/CocoaYAML/issues/4
   [open source]: https://github.com/schwa/CocoaYAML/blob/master/LICENSE.txt
   [libyaml]: http://pyyaml.org/wiki/LibYAML
   [binary]: http://yaml.org/type/binary.html
   [tag types]: http://yaml.org/type/
   [#7]: https://github.com/schwa/CocoaYAML/issues/8
   [#9]: https://github.com/schwa/CocoaYAML/issues/9