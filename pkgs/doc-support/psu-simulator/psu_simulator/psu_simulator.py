"""A simulated power supply.

The power supply protocol is inspired by the one from genesys power supplies.
"""

import random
from collections import OrderedDict
from enum import IntEnum

from lewis.adapters.stream import Cmd, StreamInterface, scanf
from lewis.core import approaches
from lewis.core.statemachine import State
from lewis.devices import StateMachineDevice

__version__ = "0.1.0"

# We don't need cryptographically secure RNG
# ruff: noqa: S311


class ConstantMode(IntEnum):
    """Whether the power supply is in constant voltage of constant current."""

    CONSTANT_VOLTAGE = 1
    CONSTANT_CURRENT = 2


class RampMode(IntEnum):
    """The type of ramp for approaching the programmed current / voltage."""

    IMMEDIATE = 0
    BOTH = 1
    UPWARDS = 2
    DOWNWARDS = 3


class ApproachingCurrentState(State):
    """The state when the target current is not the programmed current."""

    def in_state(self: "ApproachingCurrentState", dt: float) -> None:
        """Make a step towards the programmed current."""
        old_actual_current = self._context.actual_current
        match self._context.current_ramp_mode:
            case RampMode.IMMEDIATE:
                self._context.actual_current = self._context.programmed_current
            case RampMode.BOTH:
                self._context.actual_current = approaches.linear(
                    old_actual_current,
                    self._context.programmed_current,
                    self._context.current_ramp,
                    dt,
                )

        self.log.info(
            "Current changed (%s -> %s), programmed=%s, mode=%s, ramp=%s",
            old_actual_current,
            self._context.actual_current,
            self._context.programmed_current,
            self._context.current_ramp_mode.name,
            self._context.current_ramp,
        )


class ApproachingVoltageState(State):
    """The state when the target voltage is not the programmed current."""

    def in_state(self: "ApproachingVoltageState", dt: float) -> None:
        """Make a step towards the programmed voltage."""
        old_actual_voltage = self._context.actual_voltage
        match self._context.voltage_ramp_mode:
            case RampMode.IMMEDIATE:
                self._context.actual_voltage = self._context.programmed_voltage
            case RampMode.BOTH:
                self._context.actual_voltage = approaches.linear(
                    old_actual_voltage,
                    self._context.programmed_voltage,
                    self._context.voltage_ramp,
                    dt,
                )

        self.log.info(
            "Voltage changed (%s -> %s), programmed=%s, mode=%s, ramp=%s",
            old_actual_voltage,
            self._context.actual_voltage,
            self._context.programmed_voltage,
            self._context.voltage_ramp_mode.name,
            self._context.voltage_ramp,
        )


class SimulatedPowerSupply(StateMachineDevice):
    """The simulated power supply."""

    def _initialize_data(self: "SimulatedPowerSupply") -> None:
        self.serial: str = f"psu-simulator {__version__}"

        self.powered: bool = True
        self.mode: ConstantMode = ConstantMode.CONSTANT_VOLTAGE
        self.resistance: float = 2.0

        self.programmed_voltage: float = 0.0
        self.actual_voltage: float = 0.0
        self.voltage_ramp_mode: RampMode = RampMode.IMMEDIATE
        self.voltage_ramp: float = 0.0

        self.programmed_current: float = 0.0
        self.actual_current: float = 0.0
        self.current_ramp_mode: RampMode = RampMode.IMMEDIATE
        self.current_ramp: float = 0.0

    def _get_state_handlers(self: "SimulatedPowerSupply") -> dict[str, State]:
        return {
            "off": State(),
            "constant_voltage": State(),
            "approaching_voltage": ApproachingVoltageState(),
            "constant_current": State(),
            "approaching_current": ApproachingCurrentState(),
        }

    def _get_initial_state(self: "SimulatedPowerSupply") -> str:
        return "off"

    @property
    def measured_current(self: "SimulatedPowerSupply") -> float:
        """The currently measured output current."""
        if not self.powered:
            return 0

        match self.mode:
            case ConstantMode.CONSTANT_VOLTAGE:
                return self.actual_voltage / self.resistance
            case ConstantMode.CONSTANT_CURRENT:
                return self.actual_current

    @property
    def measured_voltage(self: "SimulatedPowerSupply") -> float:
        """The currently measured output voltage."""
        if not self.powered:
            return 0

        match self.mode:
            case ConstantMode.CONSTANT_VOLTAGE:
                return self.actual_voltage
            case ConstantMode.CONSTANT_CURRENT:
                return self.actual_current * self.resistance

    def _get_transition_handlers(self: "SimulatedPowerSupply") -> OrderedDict:
        return OrderedDict(
            [
                (
                    ("off", "constant_voltage"),
                    lambda: self.powered and self.mode == ConstantMode.CONSTANT_VOLTAGE,
                ),
                (
                    ("off", "constant_current"),
                    lambda: self.powered and self.mode == ConstantMode.CONSTANT_CURRENT,
                ),
                (("constant_voltage", "off"), lambda: not self.powered),
                (("constant_current", "off"), lambda: not self.powered),
                (("approaching_voltage", "off"), lambda: not self.powered),
                (("approaching_current", "off"), lambda: not self.powered),
                (
                    ("constant_voltage", "approaching_voltage"),
                    lambda: self.programmed_voltage != self.actual_voltage,
                ),
                (
                    ("approaching_voltage", "constant_voltage"),
                    lambda: self.programmed_voltage == self.actual_voltage,
                ),
                (
                    ("constant_current", "approaching_current"),
                    lambda: self.programmed_current != self.actual_current,
                ),
                (
                    ("approaching_current", "constant_current"),
                    lambda: self.programmed_current == self.actual_current,
                ),
            ]
        )


class PowerSupplyInterface(StreamInterface):
    """The TCP/IP interface to the power supply."""

    commands = frozenset(
        {
            Cmd("help", "help( .+)?"),
            Cmd("get_idn", scanf(":idn?")),
            Cmd("get_powered", scanf("outp:pon?")),
            Cmd("set_powered", scanf("outp:pon %s"), argument_mappings=(bytes,)),
            Cmd("get_mode", scanf("outp:mode?")),
            Cmd("_set_mode", scanf("outp:mode %s"), argument_mappings=(bytes,)),
            Cmd("get_measured_current", scanf("meas:curr?")),
            Cmd("get_programmed_current", scanf(":curr?")),
            Cmd(
                "set_programmed_current",
                scanf(r":curr %f"),
                argument_mappings=(float,),
            ),
            Cmd("get_measured_voltage", scanf("meas:volt?")),
            Cmd("get_programmed_voltage", scanf(":volt?")),
            Cmd(
                "_set_programmed_voltage",
                scanf(r":volt %f"),
                argument_mappings=(float,),
            ),
        },
    )

    in_terminator = "\n"
    out_terminator = "\n"

    def help(self: "PowerSupplyInterface", arg: bytes) -> str:
        """Print help about the various commands.

        Usage: help
        Usage: help <command>
        """
        result = ""

        if arg is not None:
            return self._help_about(arg.decode().strip())

        def _sort_key(cmd: Cmd) -> str:
            return getattr(cmd.pattern, "pattern", "help")

        for cmd in sorted(self.commands, key=_sort_key):
            cmd_name = "help (%s)" if cmd.func == "help" else cmd.pattern.pattern
            doc = getattr(self, cmd.func).__doc__
            if doc is None:
                continue
            summary = doc.splitlines()[0]

            result += " - '" + cmd_name + "': " + summary + "\n"

        return result

    def _help_about(self: "PowerSupplyInterface", command: str) -> str:
        if command == "help":
            return self.help.__doc__

        doc = None
        for cmd in self.commands:
            if cmd.func == "help":
                continue
            cmd_name = cmd.pattern.pattern.split()[0]
            if cmd_name == command:
                doc = getattr(self, cmd.func).__doc__
                break

        if doc is None:
            return "Unknown command"

        return doc

    def get_idn(self: "PowerSupplyInterface") -> str:
        """Return the identification of the power supply.

        Usage: :idn?
        Returns: string
        """
        return self.device.serial

    def get_powered(self: "PowerSupplyInterface") -> str:
        """Return whether the output of the power supply is powered on.

        Usage: outp:pon?
        Returns: "ON" | "OFF"
        """
        return "ON" if self.device.powered else "OFF"

    def set_powered(self: "PowerSupplyInterface", val: bytes) -> str:
        """Enable or disable the output.

        Usage: outp:pon <"ON" | "1" | "OFF" | "0">
        Returns: "OK" | "ERR"
        """
        match val.lower():
            case b"on" | b"1":
                self.device.powered = True
                return "OK"
            case b"off" | b"0":
                self.device.powered = False
                return "OK"
            case _:
                return "ERR"

    def get_mode(self: "PowerSupplyInterface") -> str:
        """Return whether the power supply is in constant voltage or constant current.

        Usage: outp:mode?
        Returns: "CV" (the default) | "CC"
        """
        match self.device.mode:
            case ConstantMode.CONSTANT_CURRENT:
                return "CC"
            case ConstantMode.CONSTANT_VOLTAGE:
                return "CV"

    def _set_mode(self: "PowerSupplyInterface", val: bytes) -> str:
        """Set whether the power supply is in constant current or constant voltage.

        Usage: outp:mode <"CV" | "CC">
        Returns: "OK" | "ERR"
        """
        match val.lower():
            case b"cc":
                self.device.mode = ConstantMode.CONSTANT_CURRENT
                return "OK"
            case b"cv":
                self.device.mode = ConstantMode.CONSTANT_VOLTAGE
                return "OK"
            case _:
                return "ERR"

    def get_measured_current(self: "PowerSupplyInterface") -> str:
        """Return the measured current, in Amps.

        Usage: meas:curr?
        Returns: float
        """
        try:
            return self.device.measured_current + random.uniform(-1.5, 1.5)
        except Exception as e:
            return str(e)

    def get_programmed_current(self: "PowerSupplyInterface") -> str:
        """Return the current current command, in Amps.

        Usage: :curr?
        Returns: float
        """
        return self.device.programmed_current

    def set_programmed_current(self: "PowerSupplyInterface", val: float) -> str:
        """Set the current, in Amps.

        Usage: :curr <float>
        Returns: "OK" | "ERR"
        """
        self.device.programmed_current = val
        return "OK"

    def get_measured_voltage(self: "PowerSupplyInterface") -> str:
        """Return the measured voltage, in Volts.

        Usage: meas:volt?
        Returns: float
        """
        return self.device.measured_voltage + random.uniform(-1.5, 1.5)

    def get_programmed_voltage(self: "PowerSupplyInterface") -> str:
        """Return the voltage voltage command, in Volts.

        Usage: :volt?
        Returns: float
        """
        return self.device.programmed_voltage

    def _set_programmed_voltage(self: "PowerSupplyInterface", val: float) -> str:
        """Set the voltage, in Volts.

        Usage: :volt <float>
        Returns: "OK" | "ERR"
        """
        self.device.programmed_voltage = val
        return "OK"
