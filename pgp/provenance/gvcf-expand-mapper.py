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

"""A mapper for expansion of gVCF data.
"""

import json
import sys

from gvcf_expander import GvcfExpander


def main():
  """Entry point to the script."""

  # Basic parsing of command line arguments to allow a filename
  # to be passed when running this code in the debugger.
  file_handle = sys.stdin
  if 2 <= len(sys.argv):
    file_handle = open(sys.argv[1], "r")

  expander = GvcfExpander()

  line = file_handle.readline()
  while line:
    line = line.strip()
    if not line:
      line = file_handle.readline()
      continue

    fields = json.loads(line)

    pairs = expander.map(fields=fields)
    for pair in pairs:
      emit(pair.k, pair.v)

    line = file_handle.readline()


def emit(key, fields):
  """Emits a key/value pair to stdout.

  Args:
    key: (string)
    fields: (dictionary)

  Returns: n/a

  Side Effects:
    a VCF line is written to stdout
  """
  print "%s\t%s" % (key, json.dumps(fields))


if __name__ == "__main__":
  main()
