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

## How to define your own tag types:

You can create your own tag type:

    [self registerHandlerForTag:@"url" block:^(id inValue, NSError **outError) {
        return([NSURL urlWithString:inValue]);
        }];

## Oh fuck not more NSNulls?

Yes. Get over it. If you don't want NSNull in your code don't expose them in your data.

A simple macro like the following should make it easy to deal with:

    #define NULLIFY(x) (x) == NULL || (x) == [NSNull null] ? NULL : (x)
    
If it would make you feel better you could call it NILLIFY instead. You already have my contempt anyway.

## No really I must never see an NSNull in my code because I am a poor programmer and I love to send messages to objects without any idea what their actual type is

    [Fine][#9]

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