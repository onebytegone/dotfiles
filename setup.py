#!/usr/bin/python

import os

def sanitize_path(path):
   return os.path.abspath(os.path.expanduser(path))

def symlink(name, target, config_path, force = False):
   linked = os.path.join(sanitize_path(target), name)

   if os.path.exists(linked) and not force:
      print "Not making symlink. File already exists at: " + linked
      return False

   os.symlink(sanitize_path(config_path), linked)
   return True

symlink('.gitconfig', '~', './gitconfig')
