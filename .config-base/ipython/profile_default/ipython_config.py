# -*- coding: utf-8 -*-
__author__ = 'Thomas Frössman'

c = get_config()  # noqa

c.InteractiveShellApp.extensions = [
    'hierarchymagic',
    'django_notebook',
    'tempmagic',
    'importfilemagic',
    # 'django'
]
