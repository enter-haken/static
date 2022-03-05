# Static

## requirements

* elixir ~ 1.13
* erlang ~ 24.2
* tree ~ 2.0

## installation

When you want to use `static` you have to do a 

```
$ make 
``` 

to install the [escript][1].

You have to provide the following parameters:

# run

`static` needs the following parameter

## --content-path 

The **root folder** of the markdown sources

## --output-path

The **target folder** for the generated html files.
This folder does not need to exists.

## --template

An [EEx template][1] used for every site generated.

## --static-path

If you have aditional content, which needs to be copied to the **output folder**,
you can assign **an existing folder**.
This parameter is **optional**.

# Contact

[hake.one](https://hake.one). Jan Frederik Hake, <jan_hake@gmx.de>. 
[@enter_haken](https://twitter.com/enter_haken) on Twitter. 
[enter-haken#7260](https://discord.com) on discord.

[1]: https://hexdocs.pm/eex/EEx.html
[2]: https://hexdocs.pm/mix/main/Mix.Tasks.Escript.Build.html
