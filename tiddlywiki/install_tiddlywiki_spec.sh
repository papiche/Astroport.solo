#!/bin/sh
Describe 'Installation Script for TiddlyWiki'
  It 'installs npm & tiddlywiki if it is not installed'
    When call ./install_tiddlywiki.sh
    The output should equal "npm installed
TiddlyWiki installed"
  End
End

