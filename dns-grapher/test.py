#!/usr/bin/python
# vim: ts=3 sw=3 ai
import pydot

if pydot.find_graphviz():
#   pass
   print "You have graphviz.. continuing"   
else:
   print "You don't have graphviz installed"
   exit(1)


roothints = open('root.hints')
print roothints

for rootserver in roothints:
   print rootserver.split()[0] + " -> " + rootserver.split()[4]
