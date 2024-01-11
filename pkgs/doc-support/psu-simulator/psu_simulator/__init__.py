"""A simple power supply simulator."""

import logging
import random
import socketserver

import click

__version__ = "0.1.0"

# We don't need cryptographically secure RNG
# ruff: noqa: S311

logging.basicConfig(level="INFO", format="%(levelname)s %(message)s")
logger = logging.getLogger(__package__)

class Server(socketserver.ThreadingMixIn, socketserver.TCPServer):
    """TCP server."""

    allow_reuse_address = True

    current: int = 0
    voltage: int = 0
    resistance: int = 0


class PowerSupply(socketserver.StreamRequestHandler):
    """The power supply protocol handler."""

    def set_current(self: "PowerSupply", val: float) -> None:
        """Set the current."""
        self.server.current = val
        self.server.voltage = self.server.current * self.server.resistance

    def set_voltage(self: "PowerSupply", val: float) -> None:
        """Set the voltage."""
        self.server.voltage = val
        self.server.current = self.server.voltage / self.server.resistance

    def handle(self: "PowerSupply") -> None:
        """Handle incoming connections."""
        logger.info("received connection")

        self._dispatch = {
            b"help": self.cmd_help,
            b":idn?": self.cmd_get_identification,
            b"meas:curr?": self.cmd_get_measured_current,
            b":curr?": self.cmd_get_current,
            b":curr": self.cmd_set_current,
            b"meas:volt?": self.cmd_get_measured_voltage,
            b":volt?": self.cmd_get_voltage,
            b":volt": self.cmd_set_voltage,
        }

        while True:
            try:
                args = self.rfile.readline().strip().split()
            except BrokenPipeError:
                return

            if args == []:
                try:
                    self.wfile.write(b".\n")
                except BrokenPipeError:
                    return
                continue

            command = args[0].lower()
            params = args[1:]

            decoded_params = [param.decode() for param in params]
            logger.info("received command: %s%s", command.decode(), decoded_params)

            if command in self._dispatch:
                result = self._dispatch[command](*params)
                self.wfile.write(str(result).encode())
                self.wfile.write(b"\n")
            else:
                self.wfile.write(f"command not found: {command.decode()}\n".encode())

    def finish(self: "PowerSupply") -> None:
        """Clean up connections."""
        logger.info("closed connection")

    def cmd_help(self: "PowerSupply", *args: str) -> str:
        """Get help about various commands.

        Usage: help <command>.
        """
        if len(args) >= 1:
            command = args[0]
            if command in self._dispatch:
                doc = self._dispatch[command].__doc__
                self.wfile.write(doc.encode())
            else:
                self.wfile.write(f"command not found: {command!s}".encode())
            return ""

        self.wfile.write(b"Available commands:\n")
        for command, func in self._dispatch.items():
            doc = func.__doc__.splitlines()[0].encode()
            self.wfile.write(b"  - '" + command + b"': " + doc + b"\n")

        return ""

    def cmd_get_identification(self: "PowerSupply", *_args: str) -> int:
        """Return the identification of the power supply.

        Usage: :idn?
        Returns: string
        """
        return f"psu-simulator {__version__}"

    def cmd_get_measured_current(self: "PowerSupply", *_args: str) -> int:
        """Return the measured current, in Amps.

        Usage: meas:curr?
        Returns: float
        """
        return self.server.current + random.uniform(-1.5, 1.5)

    def cmd_get_current(self: "PowerSupply", *_args: str) -> int:
        """Return the current current command, in Amps.

        Usage: :curr?
        Returns: float
        """
        return self.server.current

    def cmd_set_current(self: "PowerSupply", *args: str) -> str:
        """Set the current, in Amps.

        Usage: :curr <current(float)>
        Returns: 'OK' | 'ERR'
        """
        try:
            val = float(args[0])
        except ValueError:
            return "ERR"
        else:
            self.set_current(val)
            return "OK"

    def cmd_get_measured_voltage(self: "PowerSupply", *_args: str) -> int:
        """Return the measured voltage, in Volts.

        Usage: meas:volt?
        Returns: float
        """
        return self.server.voltage + random.uniform(-1.5, 1.5)

    def cmd_get_voltage(self: "PowerSupply", *_args: str) -> int:
        """Return the voltage voltage command, in Volts.

        Usage: :volt?
        Returns: float
        """
        return self.server.voltage

    def cmd_set_voltage(self: "PowerSupply", *args: str) -> str:
        """Set the voltage, in Volts.

        Usage: :volt <voltage(float)>
        Returns: 'OK' | 'ERR'
        """
        try:
            val = float(args[0])
        except ValueError:
            return "ERR"
        else:
            self.set_voltage(val)
            return "OK"


@click.command()
@click.option(
    "-l",
    "--listen-address",
    default="localhost",
    show_default=True,
    help="Listening address",
)
@click.option(
    "-p",
    "--port",
    default=8727,
    show_default=True,
    help="Listening TCP port",
)
@click.option(
    "--resistance",
    default=20,
    show_default=True,
    help="Resistance of the circuit connected to the power supply, in Ohms.",
)
def main(listen_address: str, port: int, resistance: int) -> None:
    """Start a power supply simulator server."""
    with Server((listen_address, port), PowerSupply) as server:
        logger.info("Listening on %s:%s", listen_address, port)
        server.resistance = resistance
        logger.info("Resistance is %s Ohms", resistance)

        try:
            server.serve_forever()
        except KeyboardInterrupt:
            return
