## XmlComparer

... as the name suggests, compares xml documents. It just compares structure, not order, and ignores blanks.

### REQUIREMENTS

Nokogiri

    sudo gem install nokogiri
 
### Basic Usage

    XmlComparer.new.compare(reference_xml_string_or_io, sample_xml_string_or_io)

compare returns true if the documents are equal and false otherwise.

### Options

#### show_messages

    XmlComparer.new(:show_messages => true)

Prints out further information about what is different. e.g.

    comparer = XmlComparer.new(:show_messages => true)
    comparer.compare("<bla><node></node></bla>", "<bla></bla>")

prints to the console:

Following nodes are missing:
<node/>

#### custom_matcher

    XmlComparer.new(:custom_matcher => &block)

Can take a block that will be used for each node to compare them. Good to define soft rules e.g. when comparing documents with ids that are generated.

e.g.

    target = "<bla><id>2</id></bla>"
    sample = "<bla><id>1</id></bla>"
    comparer = XmlComparer.new(:custom_matcher => lambda {|node|
    node.parent.name == "id" && node.text.match(/\d+/)})
    comparer.compare(target, sample) => true

### License

The MIT License

Copyright (c) 2009:

* Thilo Utke (thilo[at]upstream-berlin[dot]com)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.