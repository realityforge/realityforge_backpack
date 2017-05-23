# Zim

Zim is a really simple tool used to perform mechanical transformation of multiple code bases. The workflow
typically involves cloning or updating source code from git repositories, modification and committing of
source code in the local repositories, verification of changes and finally pushing changes back to remote
repositories.

## Configuration

Zim will be doing lots of resetting, committing and pushing of changes, so it is imperative to use a separate base
directory, not your development working directories. It is recommended to create a `_zim.rb` file in your Zim project
directory and add a line specifying your base directory:

    Zim::Config.base_directory = File.expand_path('~/Code/zim_base_directory')

## Running

Get some help:

    $ ./zim --help

Get a list of commands:

    $ ./zim

## Source Tree Sets

Zim has a number of Source Tree Sets, which specify groups of Git repositories. To add new repositories, edit the
`./zim_config.rb` file in the Zim project directory.

You can specify which Source Tree Set to operator over using the `-s` or `--source-tree-set` command line parameter. If
unspecified, the changes will be applied to the default source tree set which happens to be `'DEPI'`.

## Base commands

Zim can do many of the git commands such as clone, fetch, reset, pull and push, but it operators over
all the repositories in your Source Tree Set.

So a good way to start is to clone into your new base directory:

    $ ./zim --verbose --source-tree-set GITHUB clone

There are also some useful composite commands such as clean, which does a [clone, fetch, reset, goto_master, pull]
basically getting ready to apply some patches.

Also `standard_update` is useful for updating `domgen` and `dbt` plus doing some general cleaning of whitespace issues.
If you wish to do a `standard_update` to just the small set of projects you are touching through some other patch, you
can pass the option `-c` that will only run commands if the source tree already has changes in it.

## Custom commands

You can also write your own commands to apply changes over multiple repositories. Add your commands to the
`./zim_config.rb` file in the Zim project directory.

You can then chain together base and custom commands:

    $ ./zim --verbose clean patch_build_yaml_repositories push

## Normal Workflow

The normal workflow for making changes is to modify the `./zim_config.rb` file to add/update tasks you want to run
and then run the tasks via:

    $ ./zim clean mytask standard_update push

A fairly common task is to update the version of a dependent library. First you update the version number of the dependency
in the `./zim_config.rb` file and run something like:

    $ ./zim clean patch_mercury_dep push

## Epilogue

We might write some more help in the future, but for now, just look at all the other commands in there and you'll get
idea.
