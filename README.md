<!--
SPDX-FileCopyrightText: 2024 Alex Turbov <i.zaufi@gmail.com>
SPDX-License-Identifier: GPL-3.0-or-later
-->

What Is This?
=============

**Smart bash prompt** is a pluggable system to show various context information
in a command prompt. The initial idea was to create an extensible engine to
have a dynamically changing command prompt instead of a ~~boring~~
static one, capable of displaying some aux info depending on a particular
location and/or condition.

For example, if you are in Git working copy, your command prompt will look like this:

    zaufi@gentop〉 /work/GitHub/smart-prompt〉 :master〉 $

for `/boot` it'll be like

    zaufi@gentop〉 /boot〉 3.10.9-gentoo-z1〉 3 days, 13:15〉

for my `/usr/src/linux`

    zaufi@gentop〉 /usr/src/linux〉 -> linux-3.10.10-gentoo〉

and so on...


The system consists of two different parts:

- a pluggable engine, which loads _context checkers_ and forms the resulting `PS1`;
- a _context checker_ is a small script to display particular info in a command
  prompt depending on conditions.


`bash` Bindings
---------------

Except for changing a command prompt, this package also provides some
_keyboard macros_ for `bash`. Most of them are targeted to KDE's `konsole`,
but one may easily change key codes for any other terminal. To get a key code
for a particular combination, press `Ctrl+V` in a bash prompt, then a desired
key sequence. The other way is to run `read` and press whatever you want.


How To Install
--------------

As one may notice [`cmake`](http://cmake.org) is needed to install
(or make source tarball of) this package.

    tar -xf smart-prompt-X.Y.Z.tar.gz && \
    cd smart-prompt-X.Y.Z && \
    mkdir -p build && \
    cd build && \
    cmake .. && \
    sudo cmake --install .

But to work, it doesn't require **any** other dependencies, except `bash`
(and some tools detected at configure stage) -- cuz it is written using pure
`bash`, nothing else ;-)

**Note**: To make `bash` bindings to work do not forget to append
`$include /etc/smart-prompt.inputrc` to `/etc/inputrc` or `~/.inputrc`.


Configuring
-----------

There is a system-wide config file `/etc/smart-prompt.conf` and the user one
`~/.config/smart-promptrc`. And finally, the user may override some settings
depending on the current terminal in the `~/.config/smart-promptrc.${TERM}`
file.

The non-comprehensive list of options declared in the system-wide config file.

Almost every segment in a prompt has the color setting. To get the configuration
variable responsible for the segment one can set `SP_DEBUG=1` variable to get
some "debugging" information.


Context Checker Details
-----------------------

Context checkers are searched in the following directories:

- `[INSTALL_PREFIX]/libexec/smart-prompt/context-checkers.d`
- `~/.config/smart-prompt.d`

Context checker is a simple script aimed to do the two things:

- check if the current context is suitable to display some extra info;
- add some additional info to the `PS1`.


Context checkers should be named in the following format:

    NNname.sh

where `NN` is a numeric value of a loading priority.

Typical context checker consists of two functions:

- predicate to decide whether some aux info should be displayed. It must return
  numeric code, where `0` stands for _true_ and _false_ is everything else. It
  **must** be named according to the following format: `_NN_some_name`, where
  `NN` same (or close to) as the number in the file name. This needed to preserve
  order in which checkers will be applied/tried.
- the second function should `printf` (it can do `echo` as well, but I don't
  recommend this due to some limitations) any aux info, it wants to put to
  `PS1`. It can use colors (ANSI escape sequences). See particular context
  checker for details (most of them are trivial and straightforward).

Finally, a checker module should **register** provided functions. To do so, near
the end of any checker module, you may find the following:

    function _NN_some_name() { return ... }

    function _show_some_aux_info()
    {
        printf "smth"
    }

    SMART_PROMPT_PLUGINS[_NN_some_name]=_show_some_aux_info

`SMART_PROMPT_PLUGINS` is a global associative array, where the _key_ is a
predicate to check, and the _value_ is a function to execute.

Context checker can (re)use helper functions (API) defined in `smart-pointer-functions.sh`.


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

- Nowadays I don't really use (care 'bout) prompts w/ non-default background color.
