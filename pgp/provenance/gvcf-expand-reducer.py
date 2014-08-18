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

"""A reducer for expansion of gVCF data.
"""

import json
import os
import sys

from gvcf_expander import GvcfExpander
from gvcf_expander import Pair

FILTER_ENV_KEY = "FILTER_REF_MATCHES"


def main():
  """Entry point to the script."""

  # Basic parsing of command line arguments to allow a filename
  # to be passed when running this code in the debugger.
  file_handle = sys.stdin
  if 2 <= len(sys.argv):
    file_handle = open(sys.argv[1], "r")

  if FILTER_ENV_KEY in os.environ:
    expander = GvcfExpander(filter_ref_matches=True)
  else:
    expander = GvcfExpander()

  line = file_handle.readline()
  while line:
    line = line.strip()
    if not line:
      line = file_handle.readline()
      continue

    (key, value) = line.split("\t")
    fields = json.loads(value)
    results = expander.reduce(pair=Pair(key, fields))

    for result in results:
      emit(result)

    line = file_handle.readline()

  results = expander.finalize()

  for result in results:
    emit(result)


def emit(fields):
  """Emits a reduced value to stdout.

  Args:
    fields: (dict)

  Returns: n/a

  Side Effects:
    a value is written to stdout
  """
  print "%s" % (json.dumps(fields))


if __name__ == "__main__":
  main()
