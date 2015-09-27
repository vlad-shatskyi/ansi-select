## Installation

    $ gem install ansi-select


## Usage

There are two options:

* A standalone executable. Lines passed to STDIN will form your options. The result will be printed to STDOUT.

```bash
echo some words to choose from | tr ' ' '\n' | ansi-select
cd $(ls -d */ | ansi-select) # Go to a visually selected subdirectory.
git checkout $(git branch | ansi-select) # The same, but with git branches.
```

* A Ruby library.

```ruby
require "ansi/select"

answer = Ansi::Select.new(["some", "words", "to", "choose", "from"]).select
print "You chose #{answer}."
```

The Ruby interface has an additional benefit of accepting any objects that respond
to `#to_s` and returning one of them instead of a string.


## Keyboard

You can use up and down keys or j/k for navigation, and space or return key for choosing an option.


## TODO

* Support multi-select.
