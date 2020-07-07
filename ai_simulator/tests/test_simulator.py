from collections import namedtuple
import os
import copy
import json
import pytest

from simulator import Simulator
from simulator.tensor import Tensor
from simulator.computation_device import GPU, CPU


def test_simulator_error_handling():
    nodes = generate_nodes()
    ''' Test wrong device list '''
    # device_list incoherence, node_list needs 3 device:
    # "/server/hostname1/CPU/0", "/server/hostname1/CPU/1" and
    # "/server/hostname1/GPU/0". However, in wrong_device_list there are only
    # 2 devices
    wrong_device_list = [
        GPU("/server/hostname1/GPU/0"),
        CPU("/server/hostname1/CPU/0"),
    ]
    with pytest.raises(TypeError):
        Simulator(nodes['tuple'], wrong_device_list)
    # device_list wrong format: device_info should not be a dict
    wrong_device_info = {'GPU': GPU("/server/hostname1/GPU/0")}
    with pytest.raises(ValueError):
        Simulator(nodes['tuple'], wrong_device_info)
    # device_list wrong format: device_info should be a list of ***tuple***
    wrong_device_info = [
        {'GPU': ["/server/hostname1/GPU/0"]}
    ]
    with pytest.raises(ValueError):
        Simulator(nodes['tuple'], wrong_device_info)
    # Test wrong device_type
    wrong_device_list = [
        ('WRONG_DEVICE_TYPE', ["/server/hostname1/GPU/0"])
    ]
    with pytest.raises(ValueError):
        Simulator(nodes['tuple'], wrong_device_list)

    ''' Test wrong nodemetadata list '''
    device_list = [
        GPU("/server/hostname1/GPU/0"),
        CPU("/server/hostname1/CPU/0"),
        CPU("/server/hostname1/CPU/1")
    ]
    with pytest.raises(ValueError):
        # nodemetadata_list should be a list
        Simulator({}, device_list)
    with pytest.raises(ValueError):
        # nodemetadata_list should be a list of namedtuple/dict
        Simulator([[]], device_list)
    with pytest.raises(KeyError):
        # elements in nodemetadata_list should have essential attributes
        Simulator([nodes['dict'][0], {}], device_list)
    with pytest.raises(ValueError):
        # The second element is not a dict/tuple
        Simulator([nodes['dict'][0], []], device_list)
    # A correct example, this should not raise an error
    Simulator([nodes['dict'][0], *nodes['tuple'][1:]], device_list)


def test_simulator():
    # test simulator with node_dict_list and device_obj_list
    node_dict_list = generate_nodes()['dict']
    device_obj_list = [
        GPU("/server/hostname1/GPU/0"),
        CPU("/server/hostname1/CPU/0"),
        CPU("/server/hostname1/CPU/1")
    ]
    sim = Simulator(node_dict_list, device_obj_list)
    timeuse, start_time, finish_time = sim.run()
    check_sim_results(timeuse, start_time, finish_time)

    # test simulator with node_tuple_list and device_obj_list
    node_tuple_list = generate_nodes()['tuple']
    device_obj_list = [
        GPU("/server/hostname1/GPU/0"),
        CPU("/server/hostname1/CPU/0"),
        CPU("/server/hostname1/CPU/1")
    ]
    sim = Simulator(node_tuple_list, device_obj_list)
    timeuse, start_time, finish_time = sim.run()
    check_sim_results(timeuse, start_time, finish_time)

    # test simulator with node_dict_list and device_tuple_list
    node_dict_list = generate_nodes()['dict']
    device_tuple_list = [
        ('GPU', ["/server/hostname1/GPU/0"]),
        ('CPU', ["/server/hostname1/CPU/0"]),
        ('CPU', ["/server/hostname1/CPU/1"])
    ]
    sim = Simulator(node_dict_list, device_tuple_list)
    timeuse, start_time, finish_time = sim.run()
    check_sim_results(timeuse, start_time, finish_time)

    # test simulator with node_tuple_list and device_tuple_list
    node_tuple_list = generate_nodes()['tuple']
    device_tuple_list = [
        ('GPU', ["/server/hostname1/GPU/0"]),
        ('CPU', ["/server/hostname1/CPU/0"]),
        ('CPU', ["/server/hostname1/CPU/1"])
    ]
    sim = Simulator(node_tuple_list, device_tuple_list)
    timeuse, start_time, finish_time = sim.run()
    check_sim_results(timeuse, start_time, finish_time)


def generate_nodes():
    '''Return {'dict': node_dict_list, 'list': node_tuple_list} generated from
    simulator_unit_test.json
    '''

    # Mock the input data (node_list)
    node_tuple_list = []
    node_dict_list = []
    simulator_unit_test_file_relative_path = os.path.join(
        os.path.dirname(__file__), "test_simulator_input",
        "simulator_unit_test.json")
    with open(simulator_unit_test_file_relative_path) as f:
        node_json_data = json.load(f)

    # Iterate the "node_list" objects, convert each json object to node
    for node_json_obj in node_json_data["node_list"]:
        node_obj = json.loads(
            json.dumps(node_json_obj),
            object_hook=lambda d: namedtuple(
                'metadata_tuple', d.keys())(*d.values()))
        tensor_list = []
        for tensor_metadata in node_obj.output_tensors:
            tensor_list.append(
                Tensor(tensor_metadata[0], tensor_metadata[1])
            )
        final_tuple_obj = node_obj._replace(output_tensors=tensor_list)
        # Init node_tuple_list
        node_tuple_list.append(
            final_tuple_obj)
        # Init node_dict_list
        final_dict_obj = copy.deepcopy(node_json_obj)
        final_dict_obj['output_tensors'] = \
            tensor_list
        node_dict_list.append(
            final_dict_obj)

    return {'dict': node_dict_list, 'tuple': node_tuple_list}


def check_sim_results(timeuse, start_time, finish_time):
    assert timeuse == 3
    assert start_time == [(0, 0.0), (1, 1.0), (2, 1.0)]
    assert finish_time == [(0, 1.0), (2, 2.0), (1, 3.0)]
