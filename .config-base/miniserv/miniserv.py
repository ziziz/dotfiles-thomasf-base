from bottle import route, run, template, static_file, get, post, request
from subprocess import Popen
import os
import sys
from urllib import quote

root_dir = os.path.dirname(os.path.realpath(__file__))
files_dir = os.path.join(root_dir, "files")
port = 7345


@route('/')
def index(name='Hello hello'):
    return template('<b>Hello {{name}}</b>!', name=name)


@get('/files/<filepath:path>')
def server_static(filepath):
    return static_file(filepath, root=files_dir)


@post('/files/<filepath:path>')
def update_file(filepath):
    pass


@post('/url')
def store_url():
    data = request.json
    Popen(["emacsclient", "-n", "org-protocol://capture://u/" +
           quote(data['url'].encode('utf8'), safe='') + "/" +
           quote(data['title'].encode('utf8'), safe='') + "/" +
           quote(data['body'].encode('utf8'), safe='')])


@get('/org-protocol/<arg:path>')
def org_protocol(arg):
    try:
        Popen(["emacsclient", "-n", arg])
        return {"ok": True}
    except Exception:
        return {"ok": False}

if __name__ == '__main__':
    if "-d" in sys.argv:
        run(host='localhost', port=port, quiet=True)
    else:
        run(host='localhost', port=port, reloader=True)
