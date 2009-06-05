# PinMAME Library or libpinmame

## Building

### Windows

#### Installing dependencies

Grab a copy of [Cygwin](http://www.cygwin.com). Make sure that you select the following packages for installation.

* libffi
* ruby
* gcc
* mingw-libz

With this much installed you should be able to run `make` in the root of the directory. This will build `libpinmame.dll`. But you won't be able to use [Ruby FFI](http://kenai.com/projects/ruby-ffi) to make calls into the library. Since this is how most future work will be developed, you need to get your ruby environment up and running.

#### Configuring Ruby
 
You need to use ruby from [Cygwin](http://www.cygwin.com) in order to use it to make calls into `libpinmame`. So the first thing that you need to do is install [RubyGems](http://rubygems.org/).

1. Grab the [RubyGems source](http://rubyforge.org/frs/?group_id=126)
2. Unzip with `tar -zxvf rubygems-X.X.X.tgz`
3. Switch to the RubyGems directory
4. Run `/usr/bin/ruby setup.rb`. Note this needs to be run from a [Cygwin](http://www.cygwin.com) console window.
5. Run `/usr/bin/gem update --system`.
6. Run `/usr/bin/gem install rake`.

Now you have a working copy of [Ruby](http://www.ruby-lang.org) with [RubyGems](http://rubygems.org/) support. Congrats!

#### Installing Ruby FFI Gem

This part is really easy. Just run `/usr/bin/gem install ffi`. That's it. Wasn't that easy?

#### Testing the setup

Now you should be able to run `/usr/bin/ruby test.rb`. If you see `0` on the next line then it worked.