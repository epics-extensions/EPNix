# Setting up the flake registry

While developing with EPNix,
it’s possible you will end up typing `'github:epics-extensions/epnix'` quite often.

It happens when you need to create a "top" template,
or when you just want to have `epics-base` in your shell,
and so on.

This is tedious.

Nix provides a way of shortening these URLs,
by adding to the [Nix registry]:

```bash
nix registry add epnix 'github:epics-extensions/epnix'
```

Now, referring to `epnix` in Nix command-lines will be as if you referred to the full URL.
For example, the develop command to have EPICS based installed outside of a top would be:

```bash
nix develop epnix
```

If you want to initialize an EPNix top,
you can run:

```bash
nix flake new -t epnix my-top
```

[nix registry]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-registry.html#description
