# Private repository setup

To avoid a great deal of confusion, it's best to configure your machine so that
it can clone your private repositories unattended. This means that this
command should succeed without asking for user input on the terminal:

```bash
git clone 'ssh://git@your.gitlab.com/your/epicsApp.git'
```

But, asking for user input graphically is acceptable.

The reason is that the Nix command-line tool often writes text on the terminal,
and does so over the questions asked by programs like SSH or Git. If SSH or Git
asks for a password on the terminal, you probably won't see it, and confusion
will appear when the Nix command hangs.

There's two main ways to configure your machine for this:

- SSH keys
- GitHub / GitLab tokens

## SSH keys

### Configuring the SSH key

To setup SSH keys to use with your GitHub account, you can follow the [official
documentation].

[official documentation]: <https://docs.github.com/en/authentication/connecting-to-github-with-ssh>

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
ssh -T 'git@your.gitlab.com'
# Welcome to GitLab, @user!
```

If it doesn't work, but you have `gnome-keyring-daemon` installed and running,
you can add this line to your `~/.bashrc`:

```bash
export SSH_AUTH_SOCK=/run/user/$UID/keyring/ssh
```

## GitHub / GitLab tokens

GitHub and GitLab tokens offer a timed way of authenticating, suitable for
either quick and dirty access, or for setting up services or scripts that need
access to GitHub / GitLab repositories. In any case, tokens shouldn't be used
for usual development.

In GitLab, you can create tokens either per-user, per-group, or per-project.

In GitHub, you can only create personal access tokens, but their usage can be
restricted in an organization.

Creating a GitHub token, or a Gitlab token for your user means that you can
give it access to all projects and APIs that you have access to. This can be
useful for your personal applications, or tools like [glab].

[glab]: <https://docs.gitlab.com/ee/integration/glab/>

In GitLab, you can create a token for given group or project so that it offers
access to that specific group or project. These kinds of tokens should be
preferred.

### GitHub

To create a GitHub token, follow the [official documentation].

[official documentation]: <https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token>

### GitLab

To create a GitLab token, go to the user/group/project settings, under the
"Access Tokens" section. Give your token a meaningful name, an expiration date,
and for a group/project, select the appropriate role.

If you only want your token to be able to clone repositories, you can just
select the `read_repository` scope. Else refer to GitLab's official
documentation by clicking "Learn more."

After creating the personal access token, you can copy the token's value. Be
careful, as this value can't be accessed after closing the page.

If you want to clone any repository, the URL will need to be:

```bash
https://gitlab-ci-token:${TOKEN}@your.gitlab.com"
```

As EPNix uses SSH flake inputs, you can use this command to instruct Git to
rewrite GitLab URLs:

```bash
git config --global url."https://gitlab-ci-token:${TOKEN}@your.gitlab.com".insteadOf "ssh://git@your.gitlab.com"
```

To check that your setup is working, execute the following command:

```bash
git clone 'ssh://git@your.gitlab.com/your/epicsApp.git'
```
