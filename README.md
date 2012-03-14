# My base dotfiles

## Description
These are my personal dotfiles, which I manage with the help of git
and a nice tool called [dotfiles].  This is the base dotfiles
repository  which contains what I want to have available in a basic 
shell environment.

## Whats included

( notice: draft )

###  Bash
Bash is a great shell and available in most *nix based OSes. I belive
that my configuration requires bash 4 but I'm not sure.

Among other things:
 * [Minimalistic but feature packed prompt][prompt-article]
 * Small collection of aliases -  [.bashrc]
 * Extra tab completions - [.bash.d]
 * ...
 * ...

### Configuration for tools
 * tmux
 * tig
 * ack

### Utility scripts 
A bunch of scripts in [.bin].
Both general scripts and for git.



 [.bashrc]: blob/master/.bashrc ".bashrc"
 [.bash.d]: tree/master/.bash.d/ "bash.d/"
 [.bin]: tree/master/.bin/ ".bin/"

 [prompt-article]:  http://datamaskinen.medeltiden.org/tools/bash-prompt-v2.html "My bash prompt revisited"

## Installation 

Install the [dotfiles] package, either using `pip` (recommended) or 
`easy_install`. Maybe with some help of `sudo`.

    pip install dotfiles

Create some directory where to store multiple dotfiles repositories.
   
    mkdir -p ~/repos/dotfiles
   
Clone this repository into that directory.
   
    git clone https://github.com/thomasf/dotfiles-thomasf-base ~/repos/dotfiles/base
   
And symlink it's contents into your home directory.

    dotfiles -s -R ~/repos/dotfiles/base
     
Also check out `dotfiles -h` or the [dotfiles]
manual for more information on the hows and whats of that tool.




[dotfiles]: https://github.com/jbernard/dotfiles "dotfiles"
