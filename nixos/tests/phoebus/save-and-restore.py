import json
from typing import Any, Dict, List

# Use Any here, instead of the recursive "JSON",
# because recursion is not yet supported
JSON = str | int | float | bool | None | Dict[str, Any] | List[Any]

root_node_id = "44bef5de-e8e6-4014-af37-b8f6c8a939a2"
user = "myself"

base_url = "http://server:8080/save-restore"


def get(uri: str):
    return json.loads(
        client.succeed(f"curl -sSf -H 'Accept: application/json' '{base_url}{uri}'")
    )


def put(uri: str, data: JSON):
    encoded_data = json.dumps(data)
    return json.loads(
        client.succeed(
            "curl -sSf "
            "-X PUT "
            "-u customAdmin:customAdminPass "
            "-H 'Content-Type: application/json' "
            "-H 'Accept: application/json' "
            f"'{base_url}{uri}' "
            f"--data '{encoded_data}'"
        )
    )


def delete(uri: str):
    client.succeed(
        "curl -sSf "
        "-X DELETE "
        "-u customAdmin:customAdminPass "
        "-H 'Content-Type: application/json' "
        "-H 'Accept: application/json' "
        f"'{base_url}{uri}'"
    )


start_all()

server.wait_for_unit("phoebus-save-and-restore.service")
server.wait_for_open_port(8080)

client.wait_for_unit("multi-user.target")

with subtest("Default root node is created"):
    node = get(f"/node/{root_node_id}")
    assert node["uniqueId"] == root_node_id

subnode_id: str

with subtest("We can create a subnode"):
    result = put(
        f"/node?parentNodeId={root_node_id}",
        {
            "nodeType": "FOLDER",
            "name": "subnode",
            "description": "A test subnode",
            "userName": user,
        },
    )
    subnode_id = result["uniqueId"]
    # Check that it is really added
    node = get(f"/node/{subnode_id}")
    parent_node = get(f"/node/{subnode_id}/parent")
    assert parent_node["uniqueId"] == root_node_id

config_id: str

with subtest("We can create a config"):
    result = put(
        f"/config?parentNodeId={subnode_id}",
        {
            "configurationNode": {
                "name": "test configuration",
                "nodeType": "CONFIGURATION",
                "userName": user,
            },
            "configurationData": {
                "pvList": [
                    {
                        "pvName": "double",
                    },
                    {
                        "pvName": "string",
                    },
                    {
                        "pvName": "intarray",
                    },
                    {
                        "pvName": "stringarray",
                    },
                    {
                        "pvName": "enum",
                    },
                    {
                        "pvName": "table",
                    },
                ]
            },
        },
    )
    config_id = result["configurationNode"]["uniqueId"]
    config = get(f"/config/{config_id}")
    assert config["uniqueId"] == config_id


def vtype(name: str, typ: str, value: Any) -> Dict[str, Any]:
    return {
        "configPv": {
            "pvName": name,
            "readOnly": False,
        },
        "value": {
            "type": {
                "name": typ,
                "version": 1,
            },
            "value": value,
            "alarm": {
                "severity": "NONE",
                "status": "NONE",
                "name": "NO_ALARM",
            },
            "time": {"unixSec": 1664550284, "nanoSec": 870687555},
            "display": {
                "lowDisplay": 0.0,
                "highDisplay": 0.0,
                "units": "",
            },
        },
    }


snapshot_id: str

with subtest("We can create a snapshot"):
    result = put(
        f"/snapshot?parentNodeId={config_id}",
        {
            "snapshotNode": {
                "name": "test snapshot",
                "nodeType": "SNAPSHOT",
                "userName": user,
            },
            "snapshotData": {
                "snapshotItems": [
                    vtype("double", "VDouble", 42.0),
                    vtype("string", "VString", "hello"),
                    vtype("intarray", "VIntArray", [1, 2, 3]),
                    vtype("stringarray", "VStringArray", ["you", "and", "me"]),
                ],
            },
        },
    )
    snapshot_id = result["snapshotNode"]["uniqueId"]
    snapshot = get(f"/snapshot/{snapshot_id}")
    assert config["uniqueId"] == config_id

with subtest("We can delete a node"):
    print(delete(f"/node/{subnode_id}"))
