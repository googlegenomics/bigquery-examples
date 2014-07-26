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

"""Add sample id as column to CGI data.

Assumptions:
- one sample per input file

This script can be run standalone:
   cat masterVarBeta-GS000010426-ASM.tsv | ./cgi-mapper.py

Or via the debugger:
   python -mpdb ./cgi-mapper.py masterVarBeta-GS000010426-ASM.tsv

To have the sample id correctly parsed when input is from stdin, set the 
environment variable that Hadoop would set:
   export map_input_file=hu34D5B9/masterVarBeta-GS000015891-ASM.tsv.bz2
   bzcat hu34D5B9/masterVarBeta-GS000015891-ASM.tsv.bz2 | ./cgi-mapper.py

To have the sample id correctly parsed when input is from a file, ensure that it
is in the file path:
   python -mpdb ./cgi-mapper.py hu34D5B9/masterVarBeta-GS000015891-ASM.tsv

It can also be run as a mapper-only Hadoop Streaming job:
  hadoop jar /path/to/your/hadoop-streaming-*.jar -input inputpath \
  -mapper cgi-mapper.py -file cgi-mapper.py --numReduceTasks 0 \
  -output outputpath
See also https://developers.google.com/hadoop/

TODO(deflaux):
 - field relativeCoverageDiploid contains some values that are 'N', consider
   converting those values to null
 - consider converting zero-based positions to one-based positions if we
   find that most annotations are one-based

"""

import os
import re
import sys

# Constants
INPUT_FILE_KEY = "map_input_file"
SAMPLE_ID_PATTERN = "/(hu[A-F0-9]{6})/"
DUPLICATE_GENOME = "gs://pgp-harvard-data-public/hu34D5B9/GS000012763-DID/GS000010327-ASM/GS01173-DNA_C07/ASM/masterVarBeta-GS000010327-ASM.tsv.bz2"


def main():
  """Entry point to the script."""

  sample_id = None
  sample_id_re = re.compile(SAMPLE_ID_PATTERN)

  # Basic parsing of command line arguments to allow a filename
  # to be passed when running this code in the debugger.
  path = None
  file_handle = sys.stdin
  if 2 <= len(sys.argv):
    path = sys.argv[1]
    file_handle = open(path, "r")
  elif INPUT_FILE_KEY in os.environ:
    path = os.environ[INPUT_FILE_KEY]
    print >> sys.stderr, path
    print >> sys.stderr, str(os.environ)
  
  if path is not None:
    match = sample_id_re.search(path)
    if match:
      sample_id = match.group(1)

  line = file_handle.readline()
  while line:
    line = line.rstrip("\n")

    if DUPLICATE_GENOME == path:
      # hu34D5B9 was sequenced twice, skip the older genome
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
      print "%s\t%s" % (sample_id, "\t".join(fields))

    line = file_handle.readline()

if __name__ == "__main__":
  main()
