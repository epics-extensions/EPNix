# Taken from:
# https://github.com/NixOS/nixpkgs/blob/5ca4d6bf8d82262a6d4b8d2ef5f029bece888781/maintainers/maintainer-list.nix
/*
 List of EPNix maintainers.
  ```nix
  handle = {
    # Required
    name = "Your name";
    email = "address@example.org";
    # Optional
    matrix = "@user:example.org";
    github = "GithubUsername";
    githubId = your-github-id;
    keys = [{
      longkeyid = "rsa2048/0x0123456789ABCDEF";
      fingerprint = "AAAA BBBB CCCC DDDD EEEE  FFFF 0000 1111 2222 3333";
    }];
  };
  ```
  where
  - `handle` is the handle you are going to use in epnix expressions,
  - `name` is your, preferably real, name,
  - `email` is your maintainer email address,
  - `matrix` is your Matrix user ID,
  - `github` is your GitHub handle (as it appears in the URL of your profile page, `https://github.com/<userhandle>`),
  - `githubId` is your GitHub user ID, which can be found at `https://api.github.com/users/<userhandle>`,
  - `keys` is a list of your PGP/GPG key IDs and fingerprints.
  `handle == github` is strongly preferred whenever `github` is an acceptable attribute name and is short and convenient.
  If `github` begins with a numeral, `handle` should be prefixed with an underscore.
  ```nix
  _1example = {
    github = "1example";
  };
  ```
  Add PGP/GPG keys only if you actually use them to sign commits and/or mail.
  To get the required PGP/GPG values for a key run
  ```shell
  gpg --keyid-format 0xlong --fingerprint <email> | head -n 2
  ```
  !!! Note that PGP/GPG values stored here are for informational purposes only, don't use this file as a source of truth.
  More fields may be added in the future, however, in order to comply with GDPR this file should stay as minimal as possible.
  Please keep the list alphabetically sorted.
  See `<nixpkgs/maintainers/scripts/check-maintainer-github-handles.sh>` for an example on how to work with this data.
 */
{
  minijackson = {
    email = "remi.nicole@cea.fr";
    name = "Rémi Nicole";
    matrix = "@Minijackson:matrix.org";
    github = "minijackson";
    githubId = 1200507;
    keys = [
      {
        longkeyid = "rsa2048/0xFEA888C9F5D64F62";
        fingerprint = "3196 83D3 9A1B 4DE1 3DC2  51FD FEA8 88C9 F5D6 4F62";
      }
    ];
  };
  stephane = {
    email = "stephane.tzvetkov@cea.fr";
    name = "Stéphane Tzvetkov";
  };
}
