# CocoaYAML

Yet another ([open source][]) Objective-C [yaml][] library. _Important_: [Deserialization only][#4] for now.
Based on [libyaml][] for parsing. Supports many [tag types][] including the base-64 encoded [binary][] tag type.

Don't forget to get the submodules when cloning this project.

    git submodule --init --recursive
  
   [yaml]: http://yaml.org
   [#4]: https://github.com/schwa/CocoaYAML/issues/4
   [open source]: https://github.com/schwa/CocoaYAML/blob/master/LICENSE.txt
   [libyaml]: http://pyyaml.org/wiki/LibYAML
   [binary]: http://yaml.org/type/binary.html
   [tag types]: http://yaml.org/type/