"""A simple server mocking an ASCII communication."""

import sys

__version__ = "0.1.0"


def log(*args: str, **kwargs: str) -> None:
    """Print a message to stderr."""
    print(*args, file=sys.stderr, **kwargs)


def send(*args: str, **kwargs: str) -> None:
    """Send a message."""
    print(*args, end="\r\n", flush=True, **kwargs)


def main() -> None:
    """Start the mock server."""
    log("received connection")

    varfloat = 0.0
    scalc = ""

    while True:
        data = sys.stdin.readline().strip()

        if not data:
            break

        log("received command:", data)

        # TODO(minijackson): change that with a command-line parsing tool?

        if data == "FLOAT":
            send("42.1234")
        elif data == "FLOAT_WITH_PREFIX":
            send("VALUE: 69.1337")
        elif data == "ENUM":
            send("TWO")
        elif data.startswith("SET_VARFLOAT "):
            varfloat = float(data.split(" ", maxsplit=1)[1])
        elif data == "GET_VARFLOAT":
            send(str(varfloat))
        elif data == "REGEX_TITLE":
            send(
                """<!DOCTYPE html>
<html>
    <head>
        <title>Hello, World!</title>
    </head>
    </body>
        <p>Hello, World!</p>
    </body>
</html>
""",
            )
        elif data == "REGEX_SUB":
            send("abcabcabcabc")
        elif data.startswith("SET_SCALC "):
            send("sent")
            scalc = data.split(" ", maxsplit=1)[1]
        elif data == "GET_SCALC":
            send(scalc)
        else:
            log("unknown command")
