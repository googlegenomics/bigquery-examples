#!/usr/bin/env python

# Copyright 2014 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Add extract reference-matching records from CGI data and conver to VCF.

Assumptions:
- one sample per input file

This script can be run standalone:
   cat hu34D5B9/masterVarBeta-GS000010426-ASM.tsv | ./cgi-ref-blocks-mapper.py

Or via the debugger:
   python -mpdb ./cgi-ref-blocks-mapper.py hu34D5B9/masterVarBeta-GS000010426-ASM.tsv

It should be run as a mapper-only Hadoop Streaming job:
  hadoop jar /path/to/your/hadoop-streaming-*.jar \
  -libjars /home/deflaux/custom.jar \
  -outputformat com.custom.CustomMultiOutputFormat \
  -mapper cgi-ref-blocks-mapper.py -file cgi-ref-blocks-mapper.py \
  --numReduceTasks 0 -input inputpath -output outputpath

Notice that there is a special output format to put the VCF header
back into the output files including the specific sample id.

See also https://developers.google.com/hadoop/ and
http://stackoverflow.com/questions/18541503/multiple-output-files-for-hadoop-streaming-with-python-mapper

"""

import os
import re
import sys

### Constants
INPUT_FILE_KEY = "map_input_file"
SAMPLE_ID_PATTERN = "/(hu[A-F0-9]{6})/"
# This genome was sequenced twice, this is the path of the older of the two
DUPLICATE_GENOME = "gs://pgp-harvard-data-public/hu34D5B9/GS000012763-DID/GS000010327-ASM/GS01173-DNA_C07/ASM/masterVarBeta-GS000010327-ASM.tsv.bz2"
# These genomes did not successfully get converted to VCF by cgatools mkvcf
MKVCF_FAILED_GENOMES = ["huEDF7DA", "hu34D5B9"]

# CGI masterVar field indices
CHROMOSOME = 2
LOCUS_BEGIN = 3
LOCUS_END = 4
REFERENCE = 7
ALLELE1SEQ = 8
ALLELE2SEQ = 9


def main():
  """Entry point to the script."""

  sample_id = None
  sample_id_re = re.compile(SAMPLE_ID_PATTERN)

  # Basic parsing of command line arguments to allow a filename
  # to be passed when running this code in the debugger.
  file_handle = sys.stdin
  if 2 <= len(sys.argv):
    path = sys.argv[1]
    file_handle = open(path, "r")
  else:
    path = os.environ[INPUT_FILE_KEY]
    print >> sys.stderr, path

  match = sample_id_re.search(path)
  sample_id = match.group(1)

  line = file_handle.readline()
  while line:
    line = line.rstrip("\n")

    if DUPLICATE_GENOME == path:
      # hu34D5B9 was sequenced twice, skip the older genome
      pass
    elif sample_id in MKVCF_FAILED_GENOMES:
      # Don't bother extracting ref-matching blocks for the genomes for which
      # we were unable to run cgatools mkvcf
      pass
    elif not line:
      # This is a blank line, skip it
      pass
    elif "#" == line[0]:
      # This is a header line, skip it
      pass
    elif ">" == line[0]:
      # This is the column header line, skip it
      pass
    else:
      fields = line.split("\t")
      if ("=" == fields[REFERENCE] and "=" == fields[ALLELE1SEQ]
          and "=" == fields[ALLELE2SEQ]):
        # This is a reference-matching record, emit it
        contig = fields[CHROMOSOME].replace("chr", "", 1)
        start_pos = int(fields[LOCUS_BEGIN]) + 1
        end = int(fields[LOCUS_END])
        # The key is used by the custom output format to put the
        # resulting files in a subdirectory specific to the sample
        # and also as part of one of the VCF header lines.
        key = sample_id
        value = "%s\t%d\t.\tN\t.\t.\t.\tNS=1;AN=0;END=%d\tGT:PS\t0/0:." % (
            contig, start_pos, end)
        print "%s\t%s" % (key, value)

    line = file_handle.readline()

if __name__ == "__main__":
  main()
