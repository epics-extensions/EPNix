# FAQ

## How to version a whole EPNix top

Meaning, not versioning an app separate from the top. This might be justified
if you don't intend to share an app in any other top.

1. First, create a top and an app, as in the [Getting
   Started](./getting-started.md) guide.

2. Make sure to add an exception for the `exampleApp` folder at the end of
   the top's `.gitignore` file:
    ```conf
    ...
    # Applications and Support modules should be an EPNix dependency in flake.nix
    *App
    *Sup
    # You can add exceptions like this:
    # ---
    #!myCustomLocalApp
    !exampleApp
    ```

3. Then, version both the top and the app:
    ```bash
    git init
    git add -N .
    ```

4. Finally, in your `flake.nix`, you can remove any input and value in
   `epnix.applications.apps` that refers to this directory.
