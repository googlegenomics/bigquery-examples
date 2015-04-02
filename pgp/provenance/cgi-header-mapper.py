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

"""Count header values found within CGI files.

Assumptions:
- one sample per input file

This script can be run standalone:
   cat masterVarBeta-GS000010426-ASM.tsv | ./cgi-header-mapper.py

Or via the debugger:
   python -mpdb ./cgi-header-mapper.py masterVarBeta-GS000010426-ASM.tsv

It can also be run as a Hadoop Streaming job:
  hadoop jar /path/to/your/hadoop-streaming-*.jar -input inputpath \
  -mapper cgi-header-mapper.py -file cgi-header-mapper.py \
  -reducer aggregate -output outputpath

See also https://cloud.google.com/hadoop/
"""

import os
import re
import sys

# Constants
INPUT_FILE_KEY = "map_input_file"
DUPLICATE_GENOME = "gs://pgp-harvard-data-public/hu34D5B9/GS000012763-DID/GS000010327-ASM/GS01173-DNA_C07/ASM/masterVarBeta-GS000010327-ASM.tsv.bz2"


def generate_long_count_token(value):
  """Formats result for the Hadoop Aggregate package.

  For more detail, see
  http://hadoop.apache.org/docs/r1.2.1/streaming.html#Hadoop+Aggregate+Package

  Args:
    value: (string) the value to emit

  Returns:
    (string) the formatted value
  """
  return "LongValueSum:" + value + "\t" + "1"


def main():
  """Entry point to the script."""

  # Basic parsing of command line arguments to allow a filename
  # to be passed when running this code in the debugger.
  file_handle = sys.stdin
  if 2 <= len(sys.argv):
    path = sys.argv[1]
    file_handle = open(path, "r")
  else:
    path = os.environ[INPUT_FILE_KEY]
    print >> sys.stderr, path
    print >> sys.stderr, str(os.environ)

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
      # This is a header line, count it
      print generate_long_count_token(re.sub("\t", " ", line))

    line = file_handle.readline()

if __name__ == "__main__":
  main()
