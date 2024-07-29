"""Custom pygments highlight styles, based on Nord.

Modified so that:

- Nord has a light theme
- It is AA readable
- It uses the main blue colors of the EPNix logo
"""

from pygments.style import Style
from pygments.token import (
    Comment,
    Error,
    Generic,
    Keyword,
    Name,
    Number,
    Operator,
    Punctuation,
    String,
    Text,
    Token,
    Whitespace,
)

# Nord palette
darker_nord0 = "#242933"
nord0 = "#2e3440"
nord1 = "#3b4252"
nord2 = "#434c5e"
nord3 = "#4c566a"
nord4 = "#d8dee9"
nord5 = "#e5e9f0"
nord6 = "#eceff4"
nord7 = "#8fbcbb"  # blue green
nord8 = "#88c0d0"  # light blue
nord9 = "#81a1c1"  # blue
nord10 = "#5e81ac"  # deep blue
nord11 = "#bf616a"  # red
nord12 = "#d08770"  # orange
nord13 = "#ebcb8b"  # yellow
nord14 = "#a3be8c"  # green
nord15 = "#b48ead"  # purple

# EPNix palette
epnix_blue0 = "#0b1924"
epnix_blue1 = "#18334b"
epnix_blue2 = "#5277c3"
epnix_blue3 = "#415e9a"
epnix_blue4 = "#7ebae4"

epnix_dark_background = "#1a1c1e"  # from the furo theme
epnix_light_background = "#f8f9fb"  # from the furo theme


class EpnixNordLight(Style):
    name = "epnix-nord-light"

    _green = "#577140"  # nord11 with lightness darkened by 0.3
    _red = "#a9444e"  # nord11 with lightness darkened by 0.1
    _orange = "#a45036"  # nord12 with lightness darkened by 0.2
    _yellow = _orange  # Can't get the yellow to work
    _purple = "#84587c"  # nord15 with lightness darkened by 0.2

    _normal_text = nord0
    _faded_text = nord3
    _background = epnix_light_background
    _highlight_background = nord4
    _comment = "#3f6e75"  # stolen from the xcode style
    _keyword = epnix_blue1
    _function = epnix_blue3
    _string = _green

    line_number_color = _faded_text
    line_number_background_color = _background
    line_number_special_color = _background
    line_number_special_background_color = _faded_text

    background_color = _background
    highlight_color = _highlight_background

    styles = {
        Token: _normal_text,
        Whitespace: _normal_text,
        Punctuation: _normal_text,
        Comment: f"italic {_comment}",
        Comment.Preproc: _keyword,
        Keyword: f"bold {_keyword}",
        Keyword.Pseudo: f"nobold {_keyword}",
        Keyword.Type: f"nobold {_keyword}",
        Operator: f"bold {_keyword}",
        Operator.Word: f"bold {_keyword}",
        Name: _normal_text,
        Name.Builtin: _keyword,
        Name.Function: _function,
        Name.Class: _function,
        Name.Namespace: _function,
        Name.Exception: _red,
        Name.Variable: _normal_text,
        Name.Constant: _function,
        Name.Entity: _orange,
        Name.Attribute: _function,
        Name.Tag: _keyword,
        Name.Decorator: _orange,
        String: _string,
        String.Doc: _comment,
        String.Interpol: _string,
        String.Escape: _yellow,
        String.Regex: _yellow,
        String.Symbol: _yellow, # modified, looks better with Nix
        String.Other: _string,
        Number: _purple,
        Generic.Heading: f"bold {_function}",
        Generic.Subheading: f"bold {_function}",
        Generic.Deleted: _red,
        Generic.Inserted: _green,
        Generic.Error: _red,
        Generic.Emph: "italic",
        Generic.Strong: "bold",
        Generic.Prompt: f"bold {_comment}",  # modified
        Generic.Output: _normal_text,
        Generic.Traceback: _red,
        Error: _red,
        Text: _normal_text,
    }


class EpnixNordDarker(Style):
    """Based on "nord-darker"."""

    _green = nord14
    _red = "#ce858c"  # nord11 with lightness lightened by 0.1
    _orange = nord12
    _yellow = nord13
    _purple = nord15

    _normal_text = nord6
    _faded_text = nord4
    _background = epnix_dark_background  # modified
    _highlight_background = nord1
    _comment = nord9  # modified
    _keyword = epnix_blue4  # modified
    _function = nord7  # modified
    _string = _green

    line_number_color = _faded_text
    line_number_background_color = _background
    line_number_special_color = _background
    line_number_special_background_color = _faded_text

    background_color = _background
    highlight_color = _highlight_background

    styles = {
        Token: _normal_text,
        Whitespace: _normal_text,
        Punctuation: _normal_text,
        Comment: f"italic {_comment}",
        Comment.Preproc: _keyword,
        Keyword: f"bold {_keyword}",
        Keyword.Pseudo: f"nobold {_keyword}",
        Keyword.Type: f"nobold {_keyword}",
        Operator: f"bold {_keyword}",
        Operator.Word: f"bold {_keyword}",
        Name: _normal_text,
        Name.Builtin: _keyword,
        Name.Function: _function,
        Name.Class: _function,
        Name.Namespace: _function,
        Name.Exception: _red,
        Name.Variable: _normal_text,
        Name.Constant: _function,
        Name.Entity: _orange,
        Name.Attribute: _function,
        Name.Tag: _keyword,
        Name.Decorator: _orange,
        String: _string,
        String.Doc: _comment,
        String.Interpol: _string,
        String.Escape: _yellow,
        String.Regex: _yellow,
        String.Symbol: _yellow, # modified, looks better with Nix
        String.Other: _string,
        Number: _purple,
        Generic.Heading: f"bold {_function}",
        Generic.Subheading: f"bold {_function}",
        Generic.Deleted: _red,
        Generic.Inserted: _green,
        Generic.Error: _red,
        Generic.Emph: "italic",
        Generic.Strong: "bold",
        Generic.Prompt: f"bold {_comment}",  # modified
        Generic.Output: _normal_text,
        Generic.Traceback: _red,
        Error: _red,
        Text: _normal_text,
    }
