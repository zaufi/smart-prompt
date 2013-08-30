What Is This?
=============

**Smart bash prompt** is a pluggable system to show various context information in a command prompt.

The system consists of two different parts:
- a pluggable engine, which loads _context checkers_ and form the resulting `PS1`
- _context checker_ is a small script to display particular info in a command prompt

Context checkers searched in the following directories:
- `[INSTALL_PREFIX]/libexec/smart-prompt/context-checkers.d`
- `~/.smart-prompt.d`

Context checker is a simple script aimed to do the two things:
- check if current context suitable to display smth extra
- add extra info to the `PS1`

Context checkers should be named in the following format:

    NNname.sh

where `NN` is a numeric value of a loading priority.


Context Checker Details
-----------------------

TBD

Limitations
-----------

* Nowadays I don't care about colorless terminals...
