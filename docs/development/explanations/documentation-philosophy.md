# Documentation philosophy

:::{seealso}
We recommend reading these resources:

- [Diátaxis]
- [Write the docs' Software documentation guide]
  - [Write the docs' Documentation principles]
:::

## User profiles

Documentation sources are in the <source:docs> folder
and separated into 4 main parts:

<source:docs/ioc>
: for documentation related to IOC development

<source:docs/pkgs>
: for documentation on using packages on any Linux distribution

<source:docs/nixos-services>
: for documentation related to NixOS administration

<source:docs/development>
: for documentation related to internal EPNix development

Anything that isn't specific to these parts
is in the main {file}`docs` folder.

This separation tries to match the profiles of EPNix users:

- IOC developers
- Non-NixOS system administrators
- NixOS system administrators
- EPNix contributors

## Article types

Each of these parts follows the [Diátaxis] model,
meaning that each article falls into one of these types:

Tutorial
: Has a single goal,
  which it uses to teach a certain subject
  to a user.

  For example,
  in {doc}`../../ioc/tutorials/streamdevice`,
  the user creates an IOC
  for a specific power supply simulator.
  There isn't any choice or option,
  no "if you want to do this, then do that."
  The goal of this tutorial isn't to guide the user in creating *any* `StreamDevice` IOC,
  but to teach a new user how IOC development generally works
  using EPNix.

  Tutorials should target a practical and realistic goal.

  :::{seealso}
  [Diátaxis' Tutorials article]
  :::

How-to guide
: In contrast to tutorials,
  the goal of guides isn't to teach new concepts
  but to show users how they achieve their own goals.

  For example,
  in {doc}`../../nixos-services/user-guides/phoebus-save-and-restore`,
  the article guides the user to set up the Phoebus save-and-restore authentication,
  depending on what authentication type they want.

  :::{seealso}
  [Diátaxis' How-to guides article]
  :::

Explanation
: As with tutorials,
  the goal of an explanation is to teach,
  but instead of doing a practical task,
  the user reads an article.

  For example,
  in {doc}`../../ioc/explanations/template-files`,
  the user doesn't have any specific action to take.
  The article should help the user understand
  what should go where in the future of their IOC development.

  :::{seealso}
  [Diátaxis' Explanation article]
  :::

Reference
: References are generally an exhaustive list
  of something that EPNix provides,
  for example,
  packages or NixOS options.

  References are not the place to teach or guide users.
  Users consult references as part of their work,
  picking and choosing the information they are looking for.

  For example,
  in the {doc}`../../nixos-services/options-reference/ioc-services` options reference,
  the list of options is given "as-is,"
  without detailed guides on how to use them or how to start.
  This is the role of the corresponding guide linked at the top of the page.
  The options reference is meant to be succinct,
  to help the user find what they want on the page.

  References should be generated from code.

  :::{seealso}
  [Diátaxis' Reference article]
  :::

This structure helps focus the writing depending on the user's use case:

- New users have a practical, single-path tutorial to follow
  and explanations to read.

  Talking about choices and specific cases would confuse new users
  and lower the usefulness of tutorials.

- Users who actually want to deploy software have guides and references
  that take care of specific use cases
  without needing to explain much.

  Explaining too much in a how-to guide or a reference
  would prevent the user from finding the information they need.

## Article ordering

As a general rule of documentation,
important information must come first,
which is why tutorials and guides are first in each part.

Tutorials are first because they should be the first articles read by new users.
Once the user has learned enough to start being proficient,
guides should be read.
References should be last,
because they're consulted after users become more familiar
with what they're working on.

The same can be said when ordering articles within their type:

- Tutorials are ordered so that users can follow them sequentially
- Inside guides,
  "prerequisites" should be put first
- Explanations should be ordered by complexity

(writing-style)=
## Writing style

### Understandability

The writing in articles should prioritize being understood by users:

- Be direct;
  use short sentences
- Be consistent
  - Use the same terms consistently
  - Have a consistent writing style
- Don't use complex words
- Avoid unexplained acronyms
- Use realistic examples and figures to illustrate your point
- Put related information close to each other
- Avoid overlapping articles
- Each unique link should have a unique and descriptive title
  - For internal links,
    prefer using the automatic title
    by using the {rst:role}`doc` role
- Don't use words such as "simple," "simply," "just," or "obvious."

### Discoverability

Users should be able to find what they want without issue:

- Put important information first
- Use headings and subheadings
- Use admonitions for important information,
  such as {rst:dir}`important`
- Link related articles
- If you expect users to search for some information in the wrong article,
  link the correct one

### Vale

To enforce parts of the writing style
and to take advantage of already written style guides,
we've set up the [Vale] linter.

This enables us to write rules,
such as:

```{code-block} yaml
:caption: Example Vale rule

extends: substitution
message: Consider using '%s' instead of '%s'
level: warning
swap:
  # To be consistent with the Nix terminology
  development environment: development shell
```


We encourage all writers of EPNix documentation to use Vale,
although following every rule isn't mandatory.

For example,
using the passive voice in certain contexts makes sense,
but the "passive voice" rule is still enabled
to avoid using it when possible.

  [Diátaxis' Explanation article]: https://diataxis.fr/explanation/
  [Diátaxis' How-to guides article]: https://diataxis.fr/how-to-guides/
  [Diátaxis' Reference article]: https://diataxis.fr/reference/
  [Diátaxis' Tutorials article]: https://diataxis.fr/tutorials/
  [Diátaxis]: https://diataxis.fr/
  [Vale]: https://vale.sh/
  [Write the docs' Documentation principles]: https://www.writethedocs.org/guide/writing/docs-principles/
  [Write the docs' Software documentation guide]: https://www.writethedocs.org/guide/
