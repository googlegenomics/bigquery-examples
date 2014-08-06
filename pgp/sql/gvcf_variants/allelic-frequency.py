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

"""Run allelic frequency upon one chromosome at a time, appending to the result table."""

import string, subprocess

chromosomes = range(1,23)
chromosomes.extend(['X', 'Y', 'M'])

with open ("./allelic-frequency-chr1.sql", "r") as myfile:
  query=myfile.read().replace('"', '\\"')

for chrom in chromosomes:
  q = string.replace(query, "WHERE contig_name = '1'", "WHERE contig_name = '%s'" % chrom)
  cmd = [
        'bq', 
        '--project_id', 'google.com:biggene',
        '--nosync',
        'query',
        '--allow_large_results',
        '--append_table',
        '--destination_table', 'pgp_analysis_results.gvcf_variants_allelic_frequency',
        '--batch', '"' + q + '"']
  print " ".join(cmd)
  print subprocess.check_output(" ".join(cmd),
                                stderr=subprocess.STDOUT,
                                shell=True)

