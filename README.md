![](https://dl.dropboxusercontent.com/spa/dlqheu39w0arg9q/gvpg7_fw.png)

## Installation

    $ gem install ansi-select


## Usage

There are two options:

* A standalone executable. Lines passed to STDIN will form your options. The result will be printed to STDOUT.

```bash
echo some words to choose from | tr ' ' '\n' | ansi-select

cd $(ls -d */ | ansi-select) # Go to a visually selected subdirectory.
git checkout $(git branch | ansi-select) # The same, but with git branches.

rm -r $(ls | ansi-select --multi) # Delete all the selected files.
```

* A Ruby library.

```ruby
require "ansi/selector"

beverage = Ansi::Selector.select(["coffee", "tee"])

puts "Would you like some additions?"
additions = Ansi::Selector.multi_select(["sugar", "cream", "milk"])

print "Here's your #{beverage}. "
print "We've also added #{additions.join(', ')}." if additions.present?
```

The Ruby interface has an additional benefit of accepting any objects that respond
to `#to_s` and returning one of them instead of a string.


## Keyboard

* Up and down arrows or `j`/`k` to move around.
* Return to choose.
* Space to toggle in multi select mode.
* Ctrl-c or `q` to quit.
