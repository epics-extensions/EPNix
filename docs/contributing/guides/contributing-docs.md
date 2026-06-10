# Contributing documentation

## Prerequisites

Before contributing to EPNix,
follow the contributing {doc}`prerequisites`.

## Documentation philosophy

Make sure to read the {doc}`../explanations/documentation-philosophy`,
which explains how the documentation is structured
and the writing style.

## Building documentation

### As a package

To build the documentation,
run the following from EPNix's source code directory:

```{code-block}
:caption: Building the documentation

nix build -L ".#docs"
```

The HTML is then stored in {file}`./result/share/doc/epnix/html/`.

You can open a browser with `xdg-open ./result/share/doc/epnix/html/index.html`.

:::{tip}
Some features aren't available when using a web browser with files,
such as link icons.
If you want the documentation with these features,
run:

```{code-block}
python -m http.server 8000 -b 127.0.0.1 -d result/share/doc/epnix/html
```

Then open a browser at <http://localhost:8000>.
:::

### In a development shell

When actively writing documentation,
building the {nix:pkg}`epnix.docs` package is slow.

You can use the `docs` development shell
to build the documentation with `make`:

```{code-block} bash
:caption: Building the documentation in a development shell

nix develop ".#docs"
make -C docs html
```

If there are issues with the sidebar
or other inconsistencies,
run `make -C docs clean`
then rebuild the documentation.

:::{tip}
For a faster edit and compile cycle,
you can use the [watchexec] tool
to automatically build the documentation
when you change files:

```{code-block}
:caption: Continuously compile the documentation

# If not already,
# enter the "docs" development shell
nix develop ".#docs"

# Leave this command running in a terminal
watchexec "make -C docs html"
```
:::

You can open a browser with `xdg-open docs/_build/html/index.html`
or run a web server with:

```{code-block}
:caption: Start a web server for documentation built in a development shell

python -m http.server 8000 -b 127.0.0.1 -d docs/_build/html
```

This command starts a web server available at <http://localhost:8000>.

## Writing style

Read {ref}`writing-style`
in the {doc}`../explanations/documentation-philosophy` article
for general guidelines.

### Vale

We recommend using Vale when writing documentation.

To install it as a command-line tool,
follow [Vale's Install instructions].
To install it as a Language Server,
follow [Vale's LSP guide].

When writing,
try to follow Vale's advice
when it makes sense.

Following every Vale rule isn't mandatory,
but it should lead to better documentation.

## Sphinx and MyST's Markdown

EPNix uses [Sphinx] as a documentation system
and the [MyST] Sphinx extension to write it in Markdown.

MyST's Markdown differs in some ways from the standard Markdown format
to offer Sphinx's features.

Read [Sphinx]'s documentation to learn more about the framework,
features,
plugins,
or how to organize documents.

Read [MyST]'s documentation to learn about the Markdown syntax.

The following is a summary of some features.

### Organizing the structure

Sphinx builds a tree of documents
called a "TOC tree."
You use the {rst:dir}`toctree` directive
to insert child documents.
For example:

````{code-block} markdown
```{toctree}
:maxdepth: 2

sub-document
```
````

Some recommendations:

- Use the ```` ```{toctree} ```` Markdown syntax,
  *not* `:::{toctree}`.

- Use the `:maxdepth: 2` option.

- Use the {rst:dir}`:glob: <toctree:glob>` option and `*` as document
  when the general order doesn't matter.

  :::{tip}
  You can mix globbing and selecting articles to put first or last,
  for example:

  ````{code-block} markdown
  :caption: Order a single article as first

  ```{toctree}
  :glob:
  :maxdepth: 2

  prerequisites
  *
  ```
  ````
  :::

- Use the {rst:dir}`:numbered: <toctree:numbered>` option
  when you want to sequence a set of articles,
  such as for tutorials.

### Code blocks

Use the {rst:dir}`code-block` directive.
Use the {rst:dir}`:caption: <code-block:caption>` option
to describe your code extract.
For example:

````{code-block} markdown
```{code-block} nix
:caption: An example Nix attribute set

{
  example = "Hello, world!";
}
```
````

### Figures

Use the `figure` directive,
for example:

````{code-block} markdown
```{figure} my-article/my-image.png

An example image description
```
````

### Links

Cross-referencing must be done in a future-proof way,
meaning that if possible,
if a link breaks,
Sphinx should output a warning during the build.

For this,
use Sphinx's {external+sphinx:doc}`roles <usage/restructuredtext/roles>`
to express which type of object you're referencing.

#### To other articles

To link to another EPNix article,
use the {rst:role}`doc` role.
For example:

```{code-block} markdown
:caption: Referencing an EPNix article

See the {doc}`../guides/prerequisites`.
```

Try to keep the title of the article in the text.
If necessary,
you can change the link title with this syntax:

```{code-block} markdown
:caption: *Not recommended* --- changing the link title

See the {doc}`custom title <../guides/prerequisites>`.
```

#### To a sub-section

##### In the same document

To link to a sub-section in the same article,
you can use {external+myst:ref}`MyST's implicit targets <syntax/implicit-targets>` feature:

```{code-block} markdown

## A heading with slug

See the section <project:#a-heading-with-slug>
```

Try to keep the original title in the text.
If necessary,
you can change the link title with this syntax:

```{code-block} markdown

## A heading with slug

See the section [custom title](#a-heading-with-slug)
```

##### In another document

Create an {external+myst:ref}`explicit target <syntax/targets>`:

```{code-block} markdown
:caption: Creating an explicit target

*In the target article:*

(my-target-name)=
## Document subsection

----

*Then, in the other article*

See the section {ref}`my-target-name`.
```

:::{important}
The name of your target must be a unique "ref" throughout the entire EPNix documentation.
:::

:::{tip}
This explicit target syntax also works for paragraphs
and other elements.
:::

#### To a code block, figure, or table

To link to a code block, figure, or table,
use the `:name:` option:

````{code-block} markdown
:caption: Referencing a figure

```{figure} my-article/my-image.png
:name: my-figure

An example image description
```

----

See the {ref}`my-figure` figure.
````

:::{important}
The name of your target must be a unique "ref" throughout the entire EPNix documentation.
:::

#### To a NixOS option

To link to NixOS options,
use the {rst:role}`nix:option` role:

```{code-block} markdown
:caption: Referencing a NixOS option

Use the {nix:option}`services.archiver-appliance.enable` option.
```

#### To a Nix package

To link to a Nix package,
use the {rst:role}`nix:pkg` role:

```{code-block} markdown
:caption: Referencing a Nix package

Install the {nix:pkg}`epnix.epics-base` package.
```

#### To EPNix's source code

Use the `source` MyST URL scheme to link to a file or directory
in EPNix's source code:

```{code-block} markdown
:caption: Referencing a file in EPNix's source code

See the <source:docs> folder.
```

#### To other Sphinx-based documentation

Use Sphinx's {ref}`Intersphinx <ext-intersphinx>` extension
to link to other articles or elements
of another Sphinx-based documentation.

If missing,
add the other documentation
to the {confval}`intersphinx_mapping` option
in <source:docs/conf.py>.

Once done,
any cross-referencing role,
except {rst:role}`doc`,
can resolve to an external document.

For example:

```{code-block} markdown
:caption: Using Intersphinx cross-references

- {rst:dir}`toctree` resolves to the Sphinx documentation
- {cpp:class}`epicsThread` resolves to the `epics-base` documentation
```

Gives the following result:

- {rst:dir}`toctree` resolves to the Sphinx documentation
- {cpp:class}`epicsThread` resolves to the `epics-base` documentation

:::{tip}
In the `docs` development shell,
you can run this to show available objects:

```{code-block} bash
:caption: Showing available Intersphinx references

python -m sphinx.ext.intersphinx $URL/objects.inv
# For example:
python -m sphinx.ext.intersphinx https://www.sphinx-doc.org/en/master/objects.inv
```
:::

If you want your link to be explicitly to a specific project
or if you want to use the {rst:role}`doc`,
prefix your role with {samp}`external+{project}:`,
for example:

```{code-block} markdown
:caption: Using Intersphinx cross-references

- {external+sphinx:doc}`usage/restructuredtext/roles` resolves to the Sphinx documentation
- {external+myst:ref}`syntax/implicit-targets` resolves to the MyST documentation
- {external+epics-base:cpp:class}`epicsThread` resolves to the `epics-base` documentation
```

Gives the following result:

- {external+sphinx:doc}`usage/restructuredtext/roles` resolves to the Sphinx documentation
- {external+myst:ref}`syntax/implicit-targets` resolves to the MyST documentation
- {external+epics-base:cpp:class}`epicsThread` resolves to the `epics-base` documentation

  [MyST]: https://myst-parser.readthedocs.io/en/latest/
  [Sphinx]: https://www.sphinx-doc.org/en/master/
  [Vale's Install instructions]: https://vale.sh/docs/install
  [Vale's LSP guide]: https://vale.sh/docs/guides/lsp
  [watchexec]: https://github.com/watchexec/watchexec/
