# CocoaYAML

Yet another ([open source][]) Objective-C [yaml][] library. _Important_: [Deserialization only][#4] for now.

Based on [libyaml][] for parsing. Supports many [tag types][] including the base-64 encoded [binary][] tag type.

Don't forget to get the submodules when cloning this project.

    git submodule --init --recursive

## How to use

This repository comes with an Xcode project that builds a iOS static library. Include the project and the relevent .h files and then link the static library. I assume you're not an idiot and know how to do that. For idiots I'll consider setting up a Cocoapods project.

    #import "CYAMLDeserializer.h"

    CYAMLDeserializer *theDeserializer = [[CYAMLDeserializer alloc] init];
    id theObject = [theDeserializer deserializeData:theData error:NULL];

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