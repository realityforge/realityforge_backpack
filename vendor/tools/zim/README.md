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

There are also some useful composite commands such as clean, which does a `clone, fetch, reset, goto_master, pull`
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

## TODO

In the future a number of enhancements may be made.

* Visual inline-inspection with optional manual intervention. Currently changes are made across a codebase often with
  a regex and the developer has the responsibility of getting the regex right and potentially visually inspecting code
  before pushing to the remote repository. Often this is done through the use of the `gitk` task. However an improvement
  would allow a visual inspection at the time of code change and the ability to accept, reject or manually override the
  change at the time Zim transforms a particular file. This is something available in Facebook's
  [codemod](https://github.com/facebook/codemod) tool.
* Another major enhancement would be to use a transformation tool that can parse the target file types and operate on
  some sort of AST. [Spoon](https://github.com/INRIA/spoon) does this for java and [Jscodeshift](https://github.com/facebook/jscodeshift)
  does this for javascript. A good article on this approach is [Getting started with Codemods](https://www.sitepoint.com/getting-started-with-codemods/).

## Epilogue

We might write some more help in the future, but for now, just look at all the other commands in there and you'll get
idea.
