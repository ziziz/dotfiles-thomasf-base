#!/usr/bin/env python

from subprocess import Popen, PIPE
import os
import json

def load_gpg_json_dict():
    data =""
    try:
        data=Popen(["gpg","--quiet","--no-tty","--decrypt",
                    os.path.expanduser("~/.accounts.json.gpg")],
                   stdout=PIPE).communicate()[0]
    except Exception:
        print("error retreiving data")
    return json.loads(data)

def get_value(account, key):
    return load_gpg_json_dict()[account][key]

def get_username(account):
    return get_value(account, "username")

def get_password(account):
    return get_value(account, "password")


if __name__ == "__main__":
    try:
        import argparse
        parser = argparse.ArgumentParser()
        parser.add_argument("account", help="account name")
        parser.add_argument("key", help="key")
        args = parser.parse_args()
        print get_value(args.account, args.key)
    except:
        pass
