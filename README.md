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

The Ruby interface has an additional benefit of accepting and returning any objects instead of strings.
Also, if you'd like a custom formatter for them, you can pass it as a second option (the default one calls `#to_s`):

```ruby
Ansi::Selector.select(objects, ->(object) { "❤❤❤#{object}❤❤❤" })
```


## Keyboard

* Up and down arrows, `j/k`, or `Ctrl+N/P` to navigate.
* `Space` to toggle in multi select mode.
* `Return` to choose.
* `Ctrl+C` or `q` to quit.
