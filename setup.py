#!/usr/bin/python

import os
from subprocess import call
import sys

# ----------------------------------
# Config
# ----------------------------------

SymlinkConfig = [
   {
      'name': 'vimrc',
      'action': lambda: symlink('.vimrc', '~/', 'vimrc')
   },
   {
      'name': 'gitconfig',
      'action': lambda: symlink('.gitconfig', '~/', 'gitconfig')
   }
];


# ----------------------------------
# Menu
# ----------------------------------

def display_menu(options, hasBack = False):
   # Generate menu items
   menuItems = []
   for index, option in enumerate(options):
      menuItems.append(create_menu_option(str(index + 1), option['name'], option['action']))
   if hasBack:
      menuItems.append(create_menu_option("b", "To previous menu", False))
   menuItems.append(create_menu_option("q", "Quit", False))

   # Display menu to user
   print "Select an option:"
   for item in menuItems:
      print item["entry"]

   # Process response
   valid = False
   validOptions = map(lambda item: item["key"], menuItems)
   while not valid:
      selected = raw_input("-> ")
      selected = selected.lower()

      if selected in validOptions:
         valid = True
         # Handle response
         menuItems[validOptions.index(selected)]['action']()
      else:
         print "Invalid option."

def create_menu_option(key, name, action):
   return {
      "key": key,
      "entry": "  %s) %s" % (key, name),
      "action": action
   }


# ----------------------------------
# Actions
# ----------------------------------

def sanitize_path(path):
   return os.path.abspath(os.path.expanduser(path))

def link_to_bashrc():
   # TODO: make idempotent
   bash_path = sanitize_path("~/.bashrc")

   if not os.path.isfile(bash_path):
      print "Error: \"" + bash_path + "\" was not found, not creating link."
      return

   with open(bash_path, "a") as bashrc:
     bashrc.write("\n\nsource " + project_root() + "/config/bashrc \n\n")

def git_user_config():
   # TODO: add verification loop
   print "What is the name to use for git?"
   name = raw_input("-> ")
   call(['git', 'config', '--global', 'user.name', name])

   print "What email to use for git?"
   email = raw_input("-> ")
   call(['git', 'config', '--global', 'user.email', email])

def full_setup():
   # Symlinks
   for link in SymlinkConfig:
      link['action']()

   # Git config
   git_user_config()


# ----------------------------------
# Util
# ----------------------------------

def symlink(name, target, config_path, force = False):
   linked = os.path.join(sanitize_path(target), name)

   if os.path.exists(linked) and not force:
      print "Not making symlink. File already exists at: " + linked
      return False

   os.symlink(sanitize_path(config_path), linked)
   return True

def project_root():
    return os.path.dirname(os.path.realpath(sys.argv[0]))

# ----------------------------------
# Menus
# ----------------------------------

def menu_symlink():
   display_menu(SymlinkConfig)


# ----------------------------------
# Runtime
# ----------------------------------

display_menu([
   {
      'name': 'Run entire setup',
      'action': full_setup
   },
   {
      'name': 'Add link for bashrc',
      'action': link_to_bashrc
   },
   {
      'name': 'Setup symlinks',
      'action': menu_symlink
   },
   {
      'name': 'Setup git user',
      'action': git_user_config
   }
]);
