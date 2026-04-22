<!--
SPDX-FileCopyrightText: 2024 Alex Turbov <i.zaufi@gmail.com>
SPDX-License-Identifier: GPL-3.0-or-later
-->

What Is This?
=============

**Smart bash prompt** is a pluggable system for showing various pieces of context
in a command prompt. The initial idea was to create an extensible engine to
have a dynamically changing command prompt instead of a ~~boring~~
static one, capable of displaying auxiliary information depending on a particular
location and/or condition.

For example, if you are in a Git working copy, your command prompt will look like this:

    zaufi@gentop〉 /work/GitHub/smart-prompt〉 :master〉 $

For `/boot`, it will look like

    zaufi@gentop〉 /boot〉 3.10.9-gentoo-z1〉 3 days, 13:15〉

For `/usr/src/linux`

    zaufi@gentop〉 /usr/src/linux〉 -> linux-3.10.10-gentoo〉

and so on...


The system consists of two different parts:

- a pluggable engine that loads _context checkers_ and forms the resulting `PS1`;
- a _context checker_ is a small script that displays particular information in a
  command prompt depending on conditions.


`bash` Bindings
---------------

Besides changing the command prompt, this package also provides some
_keyboard macros_ for `bash`. Most of them are targeted to KDE's `konsole`,
but one may easily change key codes for any other terminal. To get the key code
for a particular combination, press `Ctrl+V` in a bash prompt, then press the desired
key sequence. The other way is to run `read` and press whatever you want.


How To Install
--------------

As you may notice, [`cmake`](http://cmake.org) is needed to install
(or create a source tarball of) this package.

    tar -xf smart-prompt-X.Y.Z.tar.gz && \
    cd smart-prompt-X.Y.Z && \
    mkdir -p build && \
    cd build && \
    cmake .. && \
    sudo cmake --install .

But to work, it doesn't require **any** other dependencies, except `bash`
(and some tools detected at configure time), because it is written using pure
`bash`, nothing else ;-)

**Note**: To make the `bash` bindings work, do not forget to append
`$include /etc/smart-prompt.inputrc` to `/etc/inputrc` or `~/.inputrc`.


Configuring
-----------

There is a system-wide config file at `/etc/smart-prompt.conf` and a user one at
`~/.config/smart-promptrc`. And finally, the user may override some settings
depending on the current terminal in the `~/.config/smart-promptrc.${TERM}`
file.

What follows is a non-comprehensive list of options declared in the system-wide config file.

Almost every segment in a prompt has a color setting. To get the configuration
variable responsible for a segment, set `SP_DEBUG=1` to get
some "debugging" information.


Context Checker Details
-----------------------

Context checkers are searched in the following directories:

- `[INSTALL_PREFIX]/libexec/smart-prompt/context-checkers.d`
- `~/.config/smart-prompt.d`

A context checker is a simple script intended to do two things:

- check whether the current context is suitable for displaying extra information;
- add some additional information to `PS1`.


Context checkers should be named in the following format:

    NNname.sh

where `NN` is the numeric loading priority.

A typical context checker consists of two functions:

- a predicate to decide whether some auxiliary information should be displayed. It must return
  a numeric code, where `0` stands for _true_ and anything else stands for _false_. It
  **must** be named according to the following format: `_NN_some_name`, where
  `NN` is the same as, or close to, the number in the file name. This is needed to preserve
  the order in which checkers will be applied.
- the second function should `printf` (it can use `echo` as well, but I do not
  recommend that because of some limitations) any auxiliary information it wants to put into
  `PS1`. It can use colors (ANSI escape sequences). See a particular context
  checker for details; most of them are trivial and straightforward.

Finally, a checker module should **register** the provided functions. To do so, near
the end of any checker module, you may find the following:

    function _NN_some_name() { return ... }

    function _show_some_aux_info()
    {
        printf "something"
    }

    SMART_PROMPT_PLUGINS[_NN_some_name]=_show_some_aux_info

`SMART_PROMPT_PLUGINS` is a global associative array where the _key_ is a
predicate to check, and the _value_ is a function to execute.

A context checker can (re)use helper functions (API) defined in `smart-prompt-functions.sh`.


Limitations
-----------

- Nowadays I don't care about colorless terminals...

TODO
----

- Make prompt segments configurable per directory. For example, it could be an
  XML file rendered (and cached) into a final bash script to display prompt;

- Add cache to some segments and dirs;

- Themes.


Known Limitations
-----------------

- Nowadays I do not really use prompts with non-default background colors.
