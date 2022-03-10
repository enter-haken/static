# Static

## requirements

* elixir ~ 1.13
* erlang ~ 24.2
* tree ~ 2.0
* graphviz ~ 2.49

## installation

When you want to use `static` you have to do a 

```
$ make 
``` 

to install the [escript][1].

You have to provide the following parameters:

## run

`static` needs the following parameter

* `--content-path` / `-c` - - The **root folder** of the markdown sources
* `--output-path` / `-o` - The **target folder** for the generated html files. This folder does not need to exists.
* `--template` / `-t` - An [EEx template][1] used for every site generated.
* `--static-path` / `-s` - If you have aditional content, which needs to be copied to the **output folder**,
you can assign **an existing folder**.
This parameter is **optional**.

## template

The given template is responsible for **all sites** generated.
So it will basicly hold the html file.

An empty template file will lead to empty html files.

The smallest possible file would be:

```
<%= @body %>
```

All files will contain there parsed markown content.

You can take a look at [hake.one][3] and [the template used][4] for a bigger example.

## docker

There is a `Dockerfile` and a `docker-compose.yaml` file in place. 

You can start a testing container with

```
$ make up
```

and exec into it with 

```
make exec
```

You can stop the container with

```
make down
```

# feature ideas

* provide a "continue reading" link to give the next LNUM
* Give the opportunity to read the given content on one site.
* Provide PDF export
* Provide rss feeds

# Contact

[hake.one](https://hake.one). Jan Frederik Hake, <jan_hake@gmx.de>. 
[@enter_haken](https://twitter.com/enter_haken) on Twitter. 
[enter-haken#7260](https://discord.com) on discord.

[1]: https://hexdocs.pm/eex/EEx.html
[2]: https://hexdocs.pm/mix/main/Mix.Tasks.Escript.Build.html
[3]: https://hake.one
[4]: https://github.com/enter-haken/content/blob/main/template/default.eex
