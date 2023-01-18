# GitLab setup

To avoid a great deal of confusion, it's best to configure your machine so that
it can clone private GitLab repositories unattended. This means that this
command should succeed without asking for user input on the terminal:

```bash
git clone 'ssh://git@drf-gitlab.cea.fr/EPICS/epnix/epnix.git'
```

Asking for user input graphically is however acceptable.

The reason is that the Nix command-line tool often writes text on the terminal,
and does so over the questions asked by programs like SSH or Git. If SSH or Git
asks for a password on the terminal, you probably won't see it, and confusion
will appear when the Nix command hangs.

There's two main ways to configure your machine for this:

- SSH keys
- GitLab tokens

## SSH keys

### Configuring the SSH key

To setup SSH keys to use with your GitLab account, you can follow the [official
documentation], and particularly look at these sections:

- See if you have an existing SSH key pair
- Generate an SSH key pair
- Add an SSH key to your GitLab account
- Verify that you can connect

[official documentation]: <https://docs.gitlab.com/ee/user/ssh.html>

### Configuring the ssh-agent

If you have a GNOME installation, chances are you already have an ssh-agent
installed and running.

To check, open a *new* terminal, and look at the value of the `$SSH_AUTH_SOCK`
variable.

If it returns nothing, install `gnome-keyring`, then log out and log in again.

Then, reopen a new terminal, and add your configured SSH key like so:

```bash
ssh-add 'path/to/key/id_ed25519'
```

Check that logging in to GitLab doesn't ask for user input on the terminal:

```bash
ssh -T 'git@drf-gitlab.cea.fr'
# Welcome to GitLab, @user!
```

If it doesn't work, but you have `gnome-keyring-daemon` installed and running,
you can add this line to your `~/.bashrc`:

```bash
export SSH_AUTH_SOCK=/run/user/$UID/keyring/ssh
```

## GitLab tokens

GitLab tokens offer a fast, timed way of authentication, suitable for either
quick and dirty access, or for setting up services or scripts that need access
to GitLab. In any case, GitLab tokens shouldn't be used for usual development.

You can create GitLab tokens either per-user, per-group, or per-project.

Creating a Gitlab token for your user means that you can give it access to all
projects and APIs that you have access to. This can be useful for your personal
applications, or tools like [glab].

[glab]: <https://docs.gitlab.com/ee/integration/glab/>

You can create a GitLab token for given group or project so that it offers
access to that specific group or project. These kinds of tokens should be
preferred.

To create a token, go to the user/group/project settings, under the "Access
Tokens" section. Give your token a meaningful name, an expiration date, and for
a group/project, select the appropriate role.

If you only want your token to be able to clone repositories, you can just
select the `read_repository` scope. Else refer to GitLab's official
documentation by clicking "Learn more."

After creating the personal access token, you can copy the token's value. Be
careful, as this value can't be accessed after closing the page.

If you want to clone any repository, the URL will need to be:

```bash
https://gitlab-ci-token:${TOKEN}@drf-gitlab.cea.fr"
```

As EPNix uses SSH flake inputs, you can use this command to instruct Git to
rewrite GitLab URLs:

```bash
git config --global url."https://gitlab-ci-token:${TOKEN}@drf-gitlab.cea.fr".insteadOf "ssh://git@drf-gitlab.cea.fr"
```

To check that your setup is working, execute the following command:

```bash
git clone 'ssh://git@drf-gitlab.cea.fr/EPICS/epnix/epnix.git'
```
