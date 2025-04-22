import json
import time
from typing import Any

start_all()


def wait_for_boot():
    with subtest("Machines boot correctly"):
        server.wait_for_unit("apache-kafka.service")
        server.wait_for_unit("elasticsearch.service")
        server.wait_for_unit("phoebus-alarm-server.service")
        server.wait_for_unit("phoebus-alarm-logger.service")
        server.wait_for_open_port(9092, "192.168.1.3")
        server.wait_for_open_port(9200)
        server.wait_for_open_port(8082)

        ioc.wait_for_unit("ioc.service")

        client.wait_for_unit("multi-user.target")

    with subtest("Alarm logger is connected to Elasticsearch"):
        status = get_logger("/")
        assert status["elastic"]["status"] == "Connected"


alarm_path = "/Accelerator/ALARM_TEST"
alarm_config = f"config:{alarm_path}"
alarm_state = f"state:{alarm_path}"

server_ip = "192.168.1.3"


def send_kafka(key: str, value: dict[str, Any]):
    value_s = json.dumps(value)
    client.succeed(
        f"echo '{key}={value_s}' | kcat -P -b {server_ip}:9092 -t Accelerator -K="
    )


def get_alarm() -> dict[str, Any]:
    result_s = client.wait_until_succeeds(
        f"kcat -b {server_ip}:9092 -C -t Accelerator -e -qJ | grep -F '{alarm_state}' | tail -1"
    )
    result = json.loads(result_s)

    assert result["key"] == alarm_state
    return json.loads(result["payload"])


def get_logger(uri: str):
    result_s = client.succeed(f"curl 'http://server:8082{uri}'")
    return json.loads(result_s)


# -----

wait_for_boot()

with subtest("We initialize the PV"):
    # This is done so that the PV is processed at least once, else the
    # alarm will be shown as INVALID
    client.wait_until_succeeds("caput ALARM_TEST 2")

with subtest("Topics are created"):
    client.wait_until_succeeds(f"kcat -b {server_ip}:9092 -L | grep Accelerator")

with subtest("Can monitor a PV"):
    send_kafka(
        alarm_config,
        {"user": "root", "host": "localhost.localdomain", "description": "The Alarm"},
    )

with subtest("Alarm logger is aware of the config"):

    def logger_has_config(_):
        logger_alarms = get_logger("/search/alarm")
        return any(alarm["config"] == alarm_config for alarm in logger_alarms)

    retry(logger_has_config)

with subtest("We can get the alarm state"):
    assert get_alarm()["severity"] == "OK"

with subtest("EPICS Alarm is also OK"):
    result = client.succeed("caget -t ALARM_TEST.SEVR")
    assert result.strip() == "NO_ALARM"

with subtest("We can trigger an MINOR alarm"):
    client.succeed("caput ALARM_TEST 3")
    client.wait_until_succeeds("caget -t ALARM_TEST.SEVR | grep MINOR")

    alarm = get_alarm()

    assert alarm["current_severity"] == "MINOR"
    assert alarm["severity"] == "MINOR"

with subtest("We can trigger an MAJOR alarm"):
    client.succeed("caput ALARM_TEST 4")
    client.wait_until_succeeds("caget -t ALARM_TEST.SEVR | grep MAJOR")

    alarm = get_alarm()

    assert alarm["current_severity"] == "MAJOR"
    assert alarm["severity"] == "MAJOR"

with subtest("We can go back to normal"):
    client.succeed("caput ALARM_TEST 2")
    client.wait_until_succeeds("caget -t ALARM_TEST.SEVR | grep NO_ALARM")

    alarm = get_alarm()

    assert alarm["current_severity"] == "OK"
    # Alarm still needs to be acknowledged
    assert alarm["severity"] == "MAJOR"

with subtest("We can acknowledge the previous alarm"):
    send_kafka(
        alarm_state,
        {
            "severity": "OK",
            "message": "OK",
            "value": "2.0",
            "time": {"seconds": int(time.time()), "nano": 0},
            "current_severity": "OK",
            "current_message": "NO_ALARM",
        },
    )

with subtest("We can see that the previous alarm was acknowledged"):
    result_s = client.wait_until_succeeds(
        f"kcat -b {server_ip}:9092 -C -t Accelerator -e -qJ | grep -F '{alarm_state}' | tail -1"
    )
    result = json.loads(result_s)

    alarm = get_alarm()

    assert alarm["current_severity"] == "OK"
    # Alarm was acknowledged
    assert alarm["severity"] == "OK"

with subtest("The Alarm logger recorded every state change"):
    logger_alarms: list[dict[str, Any]] = []

    def logger_has_latest_state(_):
        global logger_alarms
        logger_alarms = get_logger("/search/alarm/pv/ALARM_TEST")
        logger_alarms.sort(key=lambda event: event.get("time", ""), reverse=True)
        return (
            logger_alarms[0]["current_severity"] == "OK"
            and logger_alarms[0]["severity"] == "OK"
        )

    retry(logger_has_latest_state)

    assert logger_alarms[4]["current_severity"] == "OK"
    assert logger_alarms[4]["severity"] == "OK"
    assert logger_alarms[4]["value"] == "2.0"

    assert logger_alarms[3]["current_severity"] == "MINOR"
    assert logger_alarms[3]["severity"] == "MINOR"
    assert logger_alarms[3]["value"] == "3.0"

    assert logger_alarms[2]["current_severity"] == "MAJOR"
    assert logger_alarms[2]["severity"] == "MAJOR"
    assert logger_alarms[2]["value"] == "4.0"

    assert logger_alarms[1]["current_severity"] == "OK"
    assert logger_alarms[1]["severity"] == "MAJOR"
    assert logger_alarms[1]["value"] == "4.0"

    assert logger_alarms[0]["current_severity"] == "OK"
    assert logger_alarms[0]["severity"] == "OK"
    assert logger_alarms[0]["value"] == "2.0"

with subtest("The data is still here after a server reboot"):
    server.shutdown()
    server.start()

    wait_for_boot()

    alarm = get_alarm()
    assert alarm["current_severity"] == "OK", "wrong current severity"
    assert alarm["severity"] == "OK", "wrong severity"

    logger_alarms = get_logger("/search/alarm/pv/ALARM_TEST")
    logger_alarms.sort(key=lambda event: event.get("time", ""), reverse=True)
    alarm_states = [
        alarm for alarm in logger_alarms if alarm["config"].startswith("state:")
    ]

    assert alarm_states[2]["current_severity"] == "MAJOR", "wrong current severity"
    assert alarm_states[2]["severity"] == "MAJOR", "wrong severity"
    assert alarm_states[2]["value"] == "4.0", "wrong value"

with subtest("Can export alarm configuration"):
    server.succeed(
        "phoebus-alarm-server -settings /etc/phoebus/alarm-server.properties -export export.xml"
    )
    server.succeed("grep ALARM_TEST export.xml")
    server.copy_from_vm("export.xml")
