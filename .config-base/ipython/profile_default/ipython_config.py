# -*- coding: utf-8 -*-
__author__ = 'Thomas Frössman'

c = get_config()  # noqa

c.InteractiveShellApp.extensions = [
    'hierarchymagic',
    'tempmagic',
    'importfilemagic',
    'djangomagic',
]

# Logging
import os
import time

logdir = os.path.expanduser(time.strftime("~/notes/history/ipython/%Y/%m/"))
logfile = os.path.join(logdir, time.strftime("%d.log"))
if not os.path.exists(logdir):
    os.makedirs(logdir)
c.InteractiveShellApp.exec_lines = ["%%logstart %s append" % logfile]
