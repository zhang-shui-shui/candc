# C&C NLP tools
# Copyright (c) Universities of Edinburgh, Oxford and Sydney
# Copyright (c) James R. Curran
#
# This software is covered by a non-commercial use licence.
# See LICENCE.txt for the full text of the licence.
#
# If LICENCE.txt is not included in this distribution
# please email candc@it.usyd.edu.au to obtain a copy.

$MARKEDUP = shift;
$GR_MAP = shift;

open(MARKEDUP, "$MARKEDUP") || die("can't open markedup file");
open(GR_MAP, "$GR_MAP") || die("can't open grmap file");

$reverse{nmod} = 1;
$reverse{vmod} = 1;
$reverse{detmod} = 1;
$reverse{mod} = 1;
$reverse{cmod} = 1;

print <<END;
# This is the 'markedup' file which maps from bare categories to the
# categories marked up with head and dependency information.  This
# file now also contains the mapping to grammatical relations similar
# to the Briscoe and Carroll and Parc dependency bank annotation.
#
# Editing existing marked up categories in this file without regenerating
# the training data and reestimating the model will lead to reduced
# performance.  However, it is possible to change the mapping to grammatical
# relations without affecting the existing model.
#
# The file begins with a declaration of all grammatical relations and indicates
# whether the corresponding ccg arguments are in the same or reverse order 
# e.g. "red N{X}/N{X}<1> 1 car" maps to "nmod(car, red)" (reverse order)
# whereas "buys ((S[dcl]{_}\\NP{Y}<1>){_}/NP{Z}<2>){_} 2 companies" maps to
# dobj(buys, companies)
#
# A single blank line should separate the GR declarations from the rest of
# the file (which may then contain blank lines which are ignored).
#
# The category information is in the following format:
# <frequency> <bare_category>
#   <#_of_slots> <markedup_category>
#   <slot_1> <gr_1>
#   <slot_2> <gr_2>
# ...
# 
# The slots in the CCG markup aren't always numbered from left to right (for
# historical reasons). This is an inconsistency we will fix in a later version.
#
# The gr annotation is roughly based on the Briscoe and Carroll (B+C) gr scheme and
# the scheme used in the Parc Dependency Bank. This is a first attempt at a mapping
# into grs and the annotation scheme may well change in the future.
# One difference between here and B+C  is that the
# annotation in this file is currently a straight mapping from the CCG dependencies,
# which are all binary relations. Thus relations involving, eg, PP complements or
# coordinations, which for B+C are terniary relations, here are represented as two
# binary relations
ccomp forward
# (closed) clausal complement; ie clause contains its subject
cmod reverse
# clausal modifier 
comp forward
# typically used for non-verbal complements; eg in "man with telescope"
# "telescope" is a complement of "with": comp(with, telescope)
conj forward
# coordination; eg "Bill and Ted" becomes the two relations:
# conj(and, Bill), conj(and, Ted)
detmod reverse
# determiner modifier
dobj forward
# direct object of verb
mod reverse
# modifier, typically used for modifiers of modifiers; eg mod(clever, very)
ncsubj forward
# non-clausal subject of verbs
nmod reverse
# nominal modifier
obj2 forward
# second object of a verb in a ditransitive construction
obl forward
# oblique arguments of verbs, ie arguments headed by propositions (following Parc)
# eg "give to Mary" becomes obl(give, to), comp(to, Mary); at some point we might
# like to combine these into a single relation following B+C
vmod reverse
# verbal modifier
xcomp forward
# clausal complement with no overt subject; this currently gets used for all CCG
# dependencies with arguments of the form S\\NP (of which there are many)
xocomp forward
# clausal complement with no overt object; this currently gets used for all CCG
# dependencies with arguments of the form S/NP

END

while(<MARKEDUP>){
    /^(\S+) (\S+)$/;
    $bare_cat = $1;
    $markedup = $2;

    $cat2markedup{$bare_cat} = $markedup;

    $max_slot = 0;
    while($markedup =~ /<([0-9])>/g){
	$max_slot = $1 if($1 > $max_slot);
    }
    $cat2max_slot{$bare_cat} = $max_slot;

    if(!$max_slot){
	print "$bare_cat\n  0 $markedup\n\n";
	delete $cat2markedup{$bare_cat};
    }
}

while(<GR_MAP>){
    if(/^$/){
	die "$cat is missing GR for slot $\n" if($printed_slots != $max_slot);
	print "\n";
	next;
    }

    if(/^\d+\s+(\S+)\s+(\d+)\s+(\S+)/){
	$cat = $1;
	$slot = $2;
	$gr = $3;
	$markedup = $cat2markedup{$cat};
	delete $cat2markedup{$cat};
	$max_slot = $cat2max_slot{$cat};
        $printed_slots = 1;

	print "$cat\n  $max_slot $markedup\n  $slot $gr\n";
	next;
    }

    if(/^(\d+)\s+(\S+)\s*$/){
	$cat = $2;
	$markedup = $cat2markedup{$cat};
	next unless(defined $markedup);
	$max_slot = $cat2max_slot{$cat};
	delete $cat2markedup{$cat};
	$printed_slots = 0;

	print "$cat\n  $max_slot $markedup\n";
	while($printed_slots != $max_slot){
	    $printed_slots++;
	    print "  $printed_slots missing\n";
        }
	print "\n";
	next;
    }

    if(/^\s+(\d+)\s+(\S+)/){
	$slot = $1;
	$gr = $2;
	$printed_slots++;

	print "  $slot $gr\n";
	next;
    }

    warn "$_";
}

foreach $cat (keys %cat2markedup){
  warn "$cat is missing from $GR_MAP\n";
}











