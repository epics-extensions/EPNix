# FAQ

**Work In Progress**

- How to version a whole EPNix top, including an app it contains (i.e. not
  versioning the app separately and excluding it in the top's `.gitignore`)?
  This might be the case if an app is not intended to be shared in any other
  top.

    1. First, create a top and an app:
        ```sh
        # Create a new top
        nix flake new -t 'git+ssh://git@drf-gitlab.cea.fr/EPICS/epnix/epnix.git' my-top
        cd my-top
        nix develop

        # Create a new app
        makeBaseApp.pl -t ioc example
        makeBaseApp.pl -i -t ioc -p example example
        ```

    2. Make sure to add an exception for the `exampleApp` folder at the end of
       the top's `.gitignore` file:
        ```sh
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
        ```sh
        git init
        git add -N .
        ```

    4. Finally, instruct EPNix to use your created app locally (and not from a
       remote Git repository):

        - Edit your top's `flake.nix`:
            - add `./exampleApp` in `epnix.applications.apps`

        **OR**

        - Edit your top's `flake.nix`
            - add `./exampleApp` in `epnix.applications.apps` (and not
              `"./exampleApp"`)

        - In any case, do not set any additional inputs in your `flake.nix`:
            ```nix
            # Add your app inputs here:
            # ---
            #inputs.ssh-monitorApp = {
            #  url = "git+ssh://git@drf-gitlab.cea.fr/EPICS/ssh-monitorApp.git";
            #  flake = false;
            #};
            ```

    You can test that your top builds by executing: `nix build -L`. This will
    put a `./result` symbolic link in your top's directory containing the
    result of the compilation.

    **Warning:** with this configration, make sure that only your top is
    versioned! E.g. if you change your mind down the line, and start
    versionning your app, then you might get build errors.

    **Note:** as a rule of thumb, each time you modify the `flake.nix` file, or
    update your inputs using `nix flake update` or `nix flake lock`, you should
    leave and re-enter your development environment (`nix develop`).

TODO
