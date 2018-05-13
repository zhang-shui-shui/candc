# C&C NLP tools
# Copyright (c) Universities of Edinburgh, Oxford and Sydney
# Copyright (c) James R. Curran
#
# This software is covered by a non-commercial use licence.
# See LICENCE.txt for the full text of the licence.
#
# If LICENCE.txt is not included in this distribution
# please email candc@it.usyd.edu.au to obtain a copy.

import sys

def usage(s):
  print >> sys.stderr, s
  print >> sys.stderr, "usage: merge_counts <count_files...>"
  sys.exit(1)

if len(sys.argv) < 3:
  usage("incorrect number of arguments")

print "# this file was generated by the following command(s):"

first_file = True
counts = {}
for filename in sys.argv[1:]:
  for line in open(filename):
    if line.startswith('#'):
      if line.startswith('# this file was generated'):
        continue
      if first_file:
        print line,
      continue
    line = line.strip()
    if not line:
      continue

    (count, value) = line.split(' ', 1)
    count = int(count)
#    print "%d '%s'" % (count, value)
    counts[value] = counts.get(value, 0) + count
  first_file = False

print "# %s" % (' '.join(sys.argv))
print

items = map(lambda x: (x[1], x[0]), counts.items())
items.sort(lambda x, y: cmp(y, x))

for item in items:
  print '%d %s' % item