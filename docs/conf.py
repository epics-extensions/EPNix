# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

import json
import os
import sys
from pathlib import Path

# Enables importing our custom "pygments_styles" module
sys.path.append(os.path.abspath("./_ext"))

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = "EPNix"
copyright = "The EPNix Contributors"
author = "The EPNix Contributors"
release = "nixos-24.11"

source_repository = "https://github.com/epics-extensions/EPNix"

language = "en"

nitpicky = True

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

extensions = [
    "myst_parser",
    "sphinx.ext.githubpages",
    "sphinx_copybutton",
    "sphinxcontrib_nixdomain",
    "sphinxext.opengraph",
]

templates_path = ["_templates"]
exclude_patterns = [
    "_build",
    "Thumbs.db",
    ".DS_Store",
    "_vale",
]

# numfig = True

pygments_style = "pygments_styles.EpnixNordLight"
pygments_dark_style = "pygments_styles.EpnixNordDarker"

# -- Options for MyST --------------------------------------------------------
# https://myst-parser.readthedocs.io/en/latest/configuration.html

myst_enable_extensions = [
    "attrs_inline",
    "colon_fence",
    "deflist",
]

myst_url_schemes = {
    "http": None,
    "https": None,
    "mailto": None,
    "source": "https://github.com/epics-extensions/EPNix/blob/{{netloc}}{{path}}",
    "gh-issue": {
        "url": "https://github.com/executablebooks/MyST-Parser/issue/{{path}}#{{fragment}}",
        "title": "Issue #{{path}}",
        "classes": ["github"],
    },
}

# -- Options for Sphinx Copybutton -------------------------------------------
# https://sphinx-copybutton.readthedocs.io/en/latest/use.html

# Exclude copying line numbers, prompts, and prompt outputs
copybutton_exclude = ".linenos, .gp, .go"

# -- Options for the Nix domain ----------------------------------------------

nix_options_json_files = ["./nixos-options.json"]
# Sphinx 7.4.0, the display of the hierarchy of objects in the TOC changed,
# and sphinxcontrib-nixdomain doesn't support it,
# so we just display the full option path in the TOC
nix_toc_display_full_path = True


def nix_linkcode_resolve(path: str) -> str:
    return f"{source_repository}/blob/master/{path}"


# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_static_path = ["_static"]
html_baseurl = f"https://epics-extensions.github.io/EPNix/{release}/"

html_theme = "furo"
html_theme_options = {
    "source_repository": source_repository,
    "source_branch": "master",
    "source_directory": "docs/",
    "dark_css_variables": {
        "color-brand-primary": "#7ebae4",
        "color-brand-content": "#7ebae4",
    },
    "light_css_variables": {
        "color-brand-primary": "#415e9a",
        "color-brand-content": "#415e9a",
    },
    "footer_icons": [
        {
            "name": "GitHub",
            "url": source_repository,
            "html": """
                <svg stroke="currentColor" fill="currentColor" stroke-width="0" viewBox="0 0 16 16">
                    <path fill-rule="evenodd" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z"></path>
                </svg>
            """,
            "class": "",
        },
    ],
}

html_logo = "logo.svg"
html_favicon = "favicon.svg"

# Multi version

html_sidebars = {
    "**": [
        "sidebar/brand.html",
        "sidebar/search.html",
        "sidebar/scroll-start.html",
        "sidebar/navigation.html",
        "sidebar/scroll-end.html",
        "multi-version.html",
    ]
}

html_css_files = ["multi-version.css"]

html_context = {}

versions = Path("./versions.json")
if versions.exists():
    with versions.open() as f:
        html_context["versions"] = json.load(f)

    # Mark current version as current
    current_version = next(
        el for el in html_context["versions"] if el["name"] == release
    )
    current_version["current"] = True

# -- Options for Man output --------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-manual-page-output

man_pages = [
    ("ioc/references/options", "epnix-ioc", "IOC options reference", "", 5),
    ("ioc/references/packages", "epnix-ioc-packages", "", "", 5),
    ("nixos-services/options-reference/index", "epnix-nixos", "", "", 5),
    ("pkgs/packages", "epnix-packages", "", "", 5),
]

man_show_urls = True

# -- Options for OpenGraph ---------------------------------------------------
# https://sphinxext-opengraph.readthedocs.io/en/latest/

ogp_site_url = html_baseurl
ogp_image = "_static/logo.svg"
ogp_image_alt = "EPNix logo"
