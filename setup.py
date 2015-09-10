#!/usr/bin/python

import os


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
      'action': lambda: False
   },
   {
      'name': 'Setup git user',
      'action': lambda: False
   }
]);
