# try:
#     from django.core.management import setup_environ
#     import settings
#     setup_environ(settings)
#     print 'imported django settings'
#     try:
#         exec_strs = ["from %s.models import *" % apps for apps in settings.INSTALLED_APPS]
#         for x in exec_strs:
#             try:
#                 exec(x)
#             except:
#                 print 'Not imported for %s' % x
#                 print 'imported django models'
#     except:
#         pass
# except:
#     pass


# # end
