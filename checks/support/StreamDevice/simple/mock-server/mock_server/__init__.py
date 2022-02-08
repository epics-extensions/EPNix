import sys


__version__ = '0.1.0'


def log(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


def send(*args, **kwargs):
    print(*args, end='\r\n', flush=True, **kwargs)


def main():
    log('received connection')

    varfloat = 0.
    scalc = ""

    while True:
        data = sys.stdin.readline().strip()

        if not data:
            break

        log('received command:', data)

        if data == 'FLOAT':
            send('42.1234')
        elif data == 'FLOAT_WITH_PREFIX':
            send('VALUE: 69.1337')
        elif data == 'ENUM':
            send('TWO')
        elif data.startswith('SET_VARFLOAT '):
            varfloat = float(data.split(' ', maxsplit=1)[1])
        elif data == 'GET_VARFLOAT':
            send(str(varfloat))
        elif data == "REGEX_TITLE":
            send("""<!DOCTYPE html>
<html>
  <head>
    <title>Hello, World!</title>
  </head>
  </body>
    <p>Hello, World!</p>
  </body>
</html>
""")
        elif data == "REGEX_SUB":
            send("abcabcabcabc")
        elif data.startswith('SET_SCALC '):
            send('sent')
            scalc = data.split(' ', maxsplit=1)[1]
        elif data == 'GET_SCALC':
            send(scalc)
        else:
            log('unknown command')
