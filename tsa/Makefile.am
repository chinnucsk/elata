#
#   Copyright (c) 2011, Nokia Corporation
#   All Rights Reserved.
#
#   The contents of this file are subject to the 3-clause BSD License,
#   (the "License"); you may not use this file except in compliance 
#   with the License. You should have received a copy of the 3-clause
#   BSD Licensee along with this software. If not, it can be
#   retrieved online at http://www.opensource.org/licenses/BSD-3-Clause.
#
#   Software distributed under the License is distributed on an "AS IS"
#   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
#   the License for the specific language governing rights and limitations
#   under the License.
#

ESRC = \
   src/tsa_db.erl \
   src/tsa_sup.erl \
   src/tsa_filter.erl

EBIN  = $(addprefix ebin/, $(notdir $(ESRC:.erl=.beam)))
EBIN += ebin/elata_tsa.app
if HAVE_RRD
EBIN += priv/template.rrd
endif

nobase_pkgliberl_SCRIPTS = $(EBIN)
CLEANFILES = $(EBIN) 
EXTRA_DIST = $(ESRC)

priv/template.rrd:
	$(PERL) src/newdb.pl $@

include $(top_builddir)/Makefile.erlang

