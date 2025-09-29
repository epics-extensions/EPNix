import json
import time
from typing import Any, Dict, List

# Use Any here, instead of the recursive "JSON",
# because recursion is not yet supported
JSON = str | int | float | bool | None | Dict[str, Any] | List[Any]


def get(uri: str):
    return json.loads(
        server.succeed(
            f"curl -sSf -H 'Accept: application/json' 'http://localhost:8080{uri}'"
        )
    )


def post(uri: str, data: JSON):
    encoded_data = json.dumps(data)
    return json.loads(
        server.succeed(
            "curl -sSf "
            "-X POST "
            "-H 'Content-Type: application/json' "
            "-H 'Accept: application/json' "
            f"'http://localhost:8080{uri}' "
            f"--data '{encoded_data}'"
        )
    )


def pv_status(pv_name: str) -> List[Dict[str, Any]]:
    return get(f"/mgmt/bpl/getPVStatus?pv={pv_name}")


def check_pv_archived(pv_name: str) -> bool:
    return pv_status(pv_name)[0]["status"] == "Being archived"


def get_data(pv_name: str) -> List[Dict[str, Any]]:
    raw_data = get(f"/retrieval/data/getData.json?pv={pv_name}")
    return raw_data[0]["data"]


def caput(pv_name: str, value: str):
    ioc.succeed(f"caput '{pv_name}' '{value}'")


start_all()

server.wait_for_unit("tomcat.service")
server.wait_for_open_port(8080)

with subtest("wait until Archiver Appliance is up and running"):
    server.wait_until_succeeds("curl -sSf http://localhost:8080/mgmt/ui/index.html")

with subtest("no PV is being archived"):
    assert get("/mgmt/bpl/getAllPVs") == [], "no PV should be archived on startup"

with subtest("archive all PVs"):
    post(
        "/mgmt/bpl/archivePV",
        [
            {"pv": "aiExample"},
            {"pv": "calcExample", "samplingmethod": "SCAN", "samplingperiod": "2"},
            {"pv": "static"},
            {"pv": "staticDeadband"},
            {"pv": "staticProcessed"},
            {"pv": "waveform"},
            {"pv": "nonExisting"},
        ],
    )

with subtest("aiExample"):
    with subtest("wait until aiExample is being archived"):
        retry(lambda _: check_pv_archived("aiExample"))

    with subtest("wait for a few points"):
        time.sleep(10)

    with subtest("json of aiExample is valid"):
        data = get_data("aiExample")

        def alarm(value: float):
            if value <= 2 or value >= 8:
                return 2
            elif value <= 4 or value >= 6:
                return 1
            else:
                return 0

        previous_val = data[0]["val"]

        # Validate some of the data
        for i in range(1, 6):
            value: float = data[i]["val"]

            expected_val: float
            if previous_val == 9:
                expected_val = 0
            else:
                expected_val = previous_val + 1

            assert value == expected_val, "inconsistent archiving of aiExample"
            assert data[i]["severity"] == alarm(value), (
                "incoherent severity of the aiExample alarm"
            )

            previous_val = value

    with subtest("csv of aiExample is valid"):
        csv_content = server.succeed(
            "curl -sSf 'http://localhost:8080/retrieval/data/getData.csv?pv=aiExample'"
        )

        csv_lines = csv_content.split("\n")

        # Validate the first 5 lines
        for i in range(5):
            cols = csv_lines[i].split(",")

            assert int(cols[0]) == data[i]["secs"], (
                "secs CSV value incoherent with JSON"
            )
            assert float(cols[1]) == data[i]["val"], (
                "val CSV value incoherent with JSON"
            )
            assert int(cols[2]) == data[i]["severity"], (
                "severity CSV value incoherent with JSON"
            )
            assert int(cols[3]) == data[i]["status"], (
                "status CSV value incoherent with JSON"
            )
            assert int(cols[4]) == data[i]["nanos"], (
                "nanos CSV value incoherent with JSON"
            )

with subtest("static records"):
    with subtest("wait until static is being archived"):
        retry(lambda _: check_pv_archived("static"))

    with subtest("static should be empty"):
        data = get_data("static")
        assert data == [], "no data should have been archived for 'static'"

    with subtest("we can change the value of static"):
        caput("static", "1")

    with subtest("change of static is visible in the archiver"):

        def static_has_data(_):
            global data
            data = get_data("static")
            return len(data) > 0

        retry(static_has_data)
        assert len(data) == 1, "static should have one datapoint"
        assert data[0]["val"] == 1, "static's only value should be 1"

with subtest("ADEL field"):
    with subtest("wait until staticDeadband is being archived"):
        retry(lambda _: check_pv_archived("staticDeadband"))

    caput("staticDeadband", "0")

    with subtest("staticDeadband should have 1 value"):
        data = get_data("staticDeadband")
        assert len(data) == 1, (
            "only the first datapoint should have been archived for 'staticDeadband'"
        )
        assert data[0]["val"] == 0, (
            "the first datapoint for 'staticDeadband' is incorrect"
        )

    with subtest("we can change the value of staticDeadband within the deadband"):
        caput("staticDeadband", "1")
        caput("staticDeadband", "2")
        caput("staticDeadband", "3")
        caput("staticDeadband", "4")

    with subtest("change of staticDead is not visible in the archiver"):
        data = get_data("staticDeadband")
        assert len(data) == 1, (
            "no additional data should have been archived for 'staticDeadband'"
        )

    caput("staticDeadband", "10")

    with subtest("change of staticDeadband is visible in the archiver"):

        def static_deadband_has_more_data(_):
            global data
            data = get_data("staticDeadband")
            return len(data) > 1

        retry(static_deadband_has_more_data)
        assert len(data) == 2, "staticDeadband should have two datapoints"
        assert data[1]["val"] == 10, (
            "staticDeadband's additional datapoint should be 10"
        )

with subtest("static processed record"):
    with subtest("wait until staticProcessed is being archived"):
        retry(lambda _: check_pv_archived("staticProcessed"))

    with subtest("json of staticProcessed is valid"):
        data = get_data("staticProcessed")

        previous_secs = data[0]["secs"]
        delay_sum = 0

        for i in range(1, 6):
            assert data[i]["val"] == 0, "value of staticProcessed should not change"
            delay_sum += data[i]["secs"] - previous_secs
            previous_secs = data[i]["secs"]

        mean_delay = delay_sum / 5

        assert round(mean_delay) == 1, (
            "staticProcessed should be processed every second"
        )

with subtest("waveform record"):
    with subtest("wait until staticDeadband is being archived"):
        retry(lambda _: check_pv_archived("staticDeadband"))

    caput("waveform", "1,2,3,4,5")

    with subtest("json of waveform is valid"):

        def waveform_has_data(_):
            global data
            data = get_data("waveform")
            return len(data) > 0

        retry(waveform_has_data)
        assert len(data) == 1, "waveform should have one datapoint"
        print(data)
        assert data[0]["val"] == ["1,2,3,4,5"], "waveform datapoint is incorrect"

with subtest("non existing record"):
    assert pv_status("nonExisting")[0]["status"] != "Being archived", (
        "nonExisting record shouldn't be archived"
    )
    never_connected_pvs = []

    def correct_never_connected_pvs(_):
        global never_connected_pvs
        never_connected_pvs = get("/mgmt/bpl/getNeverConnectedPVs")

        return len(never_connected_pvs) == 1

    retry(correct_never_connected_pvs)
    assert never_connected_pvs[0]["pvName"] == "nonExisting", "wrong PV never connected"

with subtest("manual sampling period"):
    with subtest("wait until calcExample is being archived"):
        retry(lambda _: check_pv_archived("calcExample"))

    # Somehow these ones has capital P
    assert pv_status("calcExample")[0]["samplingPeriod"] == "2.0", (
        "wrong sampling period returned in status"
    )

    pv_type_info = get("/mgmt/bpl/getPVTypeInfo?pv=calcExample")
    assert pv_type_info["samplingMethod"] == "SCAN", (
        "wrong sampling method returned in type info"
    )
    assert pv_type_info["samplingPeriod"] == "2.0", (
        "wrong sampling period returned in type info"
    )

    with subtest("json of calcExample is valid"):
        data = get_data("calcExample")

        previous_secs = data[0]["secs"]
        delay_sum = 0

        for i in range(1, 6):
            delay_sum += data[i]["secs"] - previous_secs
            previous_secs = data[i]["secs"]

        mean_delay = delay_sum / 5

        assert round(mean_delay) == 2, "calcExample should be archived every two second"

with subtest("play pause"):
    with subtest("pause archiving aiExample"):
        # TODO: Doesn't seem to work through POST, may be a bug
        get("/mgmt/bpl/pauseArchivingPV?pv=aiExample")

    # For the store dirs test below
    with subtest("consolidate aiExample"):
        # Not POST? weird
        get("/mgmt/bpl/consolidateDataForPV?pv=aiExample&storage=MTS")

    data = get_data("aiExample")
    expected_num_datapoints = len(data)
    expected_last_point = data[expected_num_datapoints - 1]

    with subtest("wait for a bit"):
        time.sleep(3)

    data = get_data("aiExample")
    num_datapoints = len(data)
    last_point = data[num_datapoints - 1]

    assert num_datapoints == expected_num_datapoints, "pause shouldn't archive more"
    assert last_point == expected_last_point, "pause shouldn't change last point"

    with subtest("resume archiving aiExample"):
        get("/mgmt/bpl/resumeArchivingPV?pv=aiExample")

    with subtest("wait for a bit again"):
        time.sleep(3)

    data = get_data("aiExample")
    num_datapoints = len(data)
    last_point = data[num_datapoints - 1]

    assert num_datapoints != expected_num_datapoints, "resume didn't archive more"
    # Works because we also compare the timestamp
    assert last_point != expected_last_point, "resume didn't change last point"


with subtest("checking store dirs"):
    sts_content = server.succeed("ls -1 /arch/sts/ArchiverStore")
    assert len(sts_content.strip().split("\n")) > 0

    mts_content = server.succeed("ls -1 /arch/mts/ArchiverStore")
    assert len(mts_content.strip().split("\n")) > 0

# TODO: check controlling PV, which seems to be buggy?
# Added PV sometimes not linked to the controlling PV
# TODO: check renaming PV
# TODO: check different policies
