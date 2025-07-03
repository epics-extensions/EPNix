import json
from typing import Any

import json5

start_all()

server.wait_for_unit("channel-finder.service")
server.wait_for_open_port(8082)
server.wait_for_open_port(8444)

client.wait_for_unit("multi-user.target")

with subtest("ChannelFinder is listening on HTTP(S)"):
    client.succeed("curl -sSfL http://server:8082/")
    client.succeed("curl -sSfL -k https://server:8444/")


def get(uri: str) -> Any:
    result = client.succeed(f"curl -sSfL http://server:8082/ChannelFinder{uri}")
    return json.loads(result)


with subtest("ChannelFinder connected to ElasticSearch"):
    status = get("/")
    assert status["elastic"]["status"] == "Connected"

server.wait_for_unit("recceiver.service")

all_properties = {
    "Engineer",
    "EpicsBase",
    "EpicsVersion",
    "WorkingDirectory",
    "alias",
    "hostName",
    "iocName",
    "iocid",
    "pvStatus",
    "recceiverID",
    "recordDesc",
    "recordType",
    "time",
}

all_channels = {
    "ALIAS_RECORD1",
    "ALIAS_RECORD2",
    "Msg-I",
    "RECORD1",
    "RECORD2",
    "RECORD3",
    "State-Sts",
}

with subtest("RecCeiver sent all properties"):

    def has_all_properties(_last: bool) -> bool:
        properties = get("/resources/properties")
        property_names = {prop["name"] for prop in properties}
        return property_names == all_properties

    retry(has_all_properties, timeout=30)

with subtest("RecCeiver sent all channels"):

    def property_is(props: list[Any], name: str, value: Any) -> bool:
        for prop in props:
            if prop["name"] == name:
                return prop["value"] == value

        # Property not found, fail
        print(f"Property {name} not found")
        return False

    def has_all_channels(_last: bool) -> bool:
        channels = get("/resources/channels")

        channels = {chan["name"]: chan for chan in channels}

        if channels.keys() != all_channels:
            print("Not all channel names are here")
            return False

        for name, chan in channels.items():
            properties = {prop["name"]: prop["value"] for prop in chan["properties"]}

            assert properties["hostName"] == "client", f"wrong hostName for {name}"
            assert properties["iocName"] == "myioc", f"wrong iocName for {name}"
            assert properties["Engineer"] == "myself", f"wrong Engineer for {name}"

            chan["properties"] = properties

        # Description
        assert (
            channels["RECORD3"]["properties"]["recordDesc"] == "An empty ai record"
        ), "wrong description for RECORD3"

        # Aliases
        assert channels["ALIAS_RECORD1"]["properties"]["alias"] == "RECORD1", (
            "wrong alias for RECORD1"
        )
        assert channels["ALIAS_RECORD2"]["properties"]["alias"] == "RECORD2", (
            "wrong alias for RECORD2"
        )

        return True

    retry(has_all_channels, timeout=30)

with subtest("Client considers itself synchronized"):
    client.succeed("caget -t Msg-I | grep -qxF Synchronized")
    client.succeed("caget -t State-Sts | grep -qxF Done")

with subtest("ChannelFinder pvAccess server"):
    server.wait_for_open_port(5075)
    server.wait_until_succeeds("pvlist localhost", timeout=30)
    data = json5.loads(server.succeed("pvcall -M json cfService:query"))

    assert set(data["labels"]).issuperset(all_properties), "not all labels found"
    assert set(data["value"]["channelName"]) == all_channels, "not all channels found"
