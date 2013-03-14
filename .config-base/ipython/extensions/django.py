# -*- coding: utf-8 -*-
__author__ = 'Thomas Frössman'

# FIXME: WIP: not yet working

from IPython.core.magic import Magics, magics_class, line_magic, cell_magic
from IPython.core.magic_arguments import (argument, magic_arguments,
                                          parse_argstring)



def import_objects(options, style=None):
    from django.core.management.color import no_style
    style = no_style
    class ObjectImportError(Exception):
        pass

    # XXX: (Temporary) workaround for ticket #1796: force early loading of all
    # models from installed apps. (this is fixed by now, but leaving it here
    # for people using 0.96 or older trunk (pre [5919]) versions.
    from django.db.models.loading import get_models, get_apps
    loaded_models = get_models()  # NOQA

    from django.conf import settings
    imported_objects = {'settings': settings}

    dont_load_cli = options.get('dont_load')  # optparse will set this to [] if it doensnt exists
    dont_load_conf = getattr(settings, 'SHELL_PLUS_DONT_LOAD', [])
    dont_load = dont_load_cli + dont_load_conf
    quiet_load = options.get('quiet_load')

    model_aliases = getattr(settings, 'SHELL_PLUS_MODEL_ALIASES', {})

    for app_mod in get_apps():
        app_models = get_models(app_mod)
        if not app_models:
            continue

        app_name = app_mod.__name__.split('.')[-2]
        if app_name in dont_load:
            continue

        app_aliases = model_aliases.get(app_name, {})
        model_labels = []

        for model in app_models:
            try:
                imported_object = getattr(__import__(app_mod.__name__, {}, {}, model.__name__), model.__name__)
                model_name = model.__name__

                if "%s.%s" % (app_name, model_name) in dont_load:
                    continue

                alias = app_aliases.get(model_name, model_name)
                imported_objects[alias] = imported_object
                if model_name == alias:
                    model_labels.append(model_name)
                else:
                    model_labels.append("%s (as %s)" % (model_name, alias))

            except AttributeError as e:
                if not quiet_load:
                    print(style.ERROR("Failed to import '%s' from '%s' reason: %s" % (model.__name__, app_name, str(e))))
                continue
        if not quiet_load:
            print(style.SQL_COLTYPE("From '%s' autoload: %s" % (app_mod.__name__.split('.')[-2], ", ".join(model_labels))))

    return imported_objects


@magics_class
class DjangoMagics(Magics):
    """
    """

    def __init__(self, *args, **kwds):
        """

        Arguments:
        - `*args`:
        - `**kwds`:
        """
        super(DjangoMagics, self).__init__(*args, **kwds)

    @line_magic
    def load_models(self, arg):
        """
        """
        imported_objects = import_objects(options={'dont_load': []},
                                          style=no_style())
        # ipython.push(imported_objects)
        import_objects()


def load_ipython_extension(ip):
    """Load the extension in IPython."""
    global _loaded
    if not _loaded:
        ip.register_magics(DjangoMagics)
        _loaded = True

_loaded = False
