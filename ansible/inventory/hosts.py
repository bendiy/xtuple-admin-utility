#!/usr/bin/env python3

"""
Dynamic inventory script
"""

import argparse
import os
import json


class Inventory(object):
    def __init__(self, config_json, list_json, empty_json, api_json):
        self.config_json = config_json
        self.list_json = list_json
        self.empty_json = empty_json
        self.api_json = api_json
        self.inventory = ()
        parser = argparse.ArgumentParser()
        parser.add_argument('--list', action='store_true')
        parser.add_argument('--host', action='store')
        self.args = parser.parse_args()
        if self.args.list:
            self.inventory = self.list()
        elif self.args.host:
            self.inventory = self.empty()
        else:
            self.inventory = self.empty()
        print(json.dumps(self.inventory))

    def list(self):
        inventory = self.load(self.list_json)
        config = self.load(self.config_json)
        inventory['local']['vars'].update(config)
        inventory['digital_ocean']['vars'].update(config)
        inventory['aws']['vars'].update(config)
        api = self.load(self.api_json)
        for customer, info in api['customers'].items():
            for domain, server in info['servers'].items():
                inventory['local']['vars']['xtuple']['hosts'].append({
                    'name': server['vars']['name'],
                    'domain': domain,
                    'domain_alias': server['vars']['domain_alias'],
                    'environments': server['vars']['environments'],
                    'state': server['state'],
                    'zone': server['vars']['zone'],
                    'key': server['vars']['key'],
                    'group': server['vars']['group'],
                })
                # hostvars does not work for dynamically added hosts
                # inventory['_meta']['hostvars'][domain] = server['vars']
                inventory[server['vars']['name']] = {
                    'hosts': [domain],
                    'vars': server['vars']
                }
        return inventory

    def empty(self):
        return self.load(self.empty_json)

    @staticmethod
    def load(file):
        return json.load(open("{dir}/{file}".format(
            dir=os.path.dirname(os.path.realpath(__file__)),
            file=file
        )))


Inventory('config.json', 'groups.json', 'empty.json', 'inventory.json')
