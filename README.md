# Realityforge Project Management

This repository helps manage the `realityforge` projects. Projects are defined in the file
`belt_config.rb`. Other tools read this file when they need to determine the list of projects.

## Backpack

Backpack is a very simple tool that helps you manage GitHub organizations declaratively.
See the vendored [README](vendor/tools/backpack/README.md) for a basic overview of the
tool.

The simple instructions are update the file `backpack_config.rb` and converge via:

    $ ./backpack

## Zim

Zim is a really simple tool used to perform mechanical transformation of multiple code bases.
See the [README.md](vendor/tools/zim/README.md) for more details.

The simple instructions are update the file `zim_config.rb` and run via:

    $ ./zim
