#!/usr/bin/python

import os
from subprocess import call


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

def symlink(name, target, config_path, force = False):
   linked = os.path.join(sanitize_path(target), name)

   if os.path.exists(linked) and not force:
      print "Not making symlink. File already exists at: " + linked
      return False

   os.symlink(sanitize_path(config_path), linked)
   return True

def git_user_config():
   # TODO: add verification loop
   print "What is the name to use for git?"
   name = raw_input("-> ")
   call(['git', 'config', '--global', 'user.name', name])

   print "What email to use for git?"
   email = raw_input("-> ")
   call(['git', 'config', '--global', 'user.email', email])

# ----------------------------------
# Menus
# ----------------------------------

def menu_symlink():
   display_menu([
      {
         'name': 'vimrc',
         'action': lambda: symlink('.vimrc', '~/', 'vimrc')
      },
      {
         'name': 'gitconfig',
         'action': lambda: symlink('.gitconfig', '~/', 'gitconfig')
      }
   ])


# ----------------------------------
# Runtime
# ----------------------------------

display_menu([
   {
      'name': 'Run all tasks',
      'action': lambda: False
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
