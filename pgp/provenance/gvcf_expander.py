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

"""A library for expansion of gVCF data.
"""

from collections import namedtuple
import json
import math
import sys
import unittest


Pair = namedtuple('Pair', 'k v')


class GvcfExpander(object):
  """Common logic for gVCF expansion."""

  def __init__(self, bin_size=100, filter_ref_matches=True):
    self.bin_size = bin_size
    self.filter_ref_matches = filter_ref_matches
    self.current_key = None
    self.binned_calls = []
    self.sample_refs = {}

  def is_variant(self, fields):
    """Determines whether or not the VCF fields constitute variant."""
    if 'alternate_bases' in fields and 0 != len(fields['alternate_bases']):
      return True
    return False

  def get_start(self, fields):
    return int(fields['start_pos'])

  def get_end(self, fields):
    if 'END' in fields:
      return int(fields['END'])
    elif 'end' in fields:
      return int(fields['end'])
    return int(fields['end_pos'])

  def compute_start_bin(self, fields):
    return int(math.floor(self.get_start(fields)/self.bin_size))

  def compute_end_bin(self, fields):
    return int(math.floor(self.get_end(fields)/self.bin_size))

  def map(self, fields):
    results = []

    start_bin = self.compute_start_bin(fields)
    if self.is_variant(fields):
      end_bin = start_bin
    else:
      end_bin = self.compute_end_bin(fields)

    for current_bin in range(start_bin, end_bin+1):
      key = '%s:%s' % (fields['contig_name'], str(current_bin))
      results.append(Pair(key, fields))

    return results

  def reduce(self, pair):
    expanded_calls = []

    if None is self.current_key:
      self.current_key = pair.k

    if pair.k != self.current_key:
      expanded_calls = self.expand_binned_calls()
      self.current_key = pair.k
      self.binned_calls = []
      self.sample_refs = {}

    self.binned_calls.append(pair.v)

    return expanded_calls

  def finalize(self):
    return self.expand_binned_calls()

  def expand_binned_calls(self):
    expanded_calls = []
    current_bin = int(self.current_key.split(':')[1])

    calls = sorted(self.binned_calls, key=lambda k: int(k['start_pos']))

    for call in calls:
      if self.is_variant(call):
        expanded_calls.append(self.expand_variant(call))
      else:
        self.accumulate_block(call)
        # Don't output ref-matches that we already output
        if self.compute_start_bin(call) == current_bin:
          expanded_calls.append(call)

    return expanded_calls

  def expand_variant(self, variant_call):
    expansion_calls = []
    for sample_id in self.sample_refs.keys():
      ref_call = self.sample_refs[sample_id]
      if (self.get_start(ref_call) <= self.get_start(variant_call) and
          self.get_end(ref_call) >= self.get_start(variant_call) + 1):
        expansion_calls.extend(ref_call['call'])
      else:
        # This ref_block is now outside of the range we are
        # considering and therefore obsolete, nuke it
        del self.sample_refs[sample_id]

    if True == self.filter_ref_matches:
      # Get the sample_ids already called in this variant
      variant_sample_names = [call['callset_name'] for call in
                              variant_call['call']]

      # Filter out ref_calls for samples called in this variant; this
      # is naive; a better approach might be to compare the quality
      # score of the referenece call to that of the variant call for
      # the sample in question
      variant_call['call'].extend(
          [call for call in expansion_calls
           if call['callset_name'] not in variant_sample_names]
          )
    else:
      variant_call['call'].extend(expansion_calls)

    return variant_call

  def accumulate_block(self, ref_call):
    # Since everything is sorted by start_pos, we only need to stash
    # at most one ref block per sample in the ref block at a time
    self.sample_refs[ref_call['call'][0]['callset_name']] = ref_call


class GvcfExpanderTest(unittest.TestCase):
  """Unit tests for common logic for gVCF expansion."""

  def test_is_variant(self):
    expander = GvcfExpander()

    self.assertTrue(expander.is_variant(json.loads(self.variant_1)))
    self.assertTrue(expander.is_variant(json.loads(self.variant_2)))
    self.assertFalse(expander.is_variant(json.loads(self.ref_a)))
    self.assertFalse(expander.is_variant(json.loads(self.ref_b)))
    self.assertFalse(expander.is_variant(json.loads(self.ref_c)))
    self.assertFalse(expander.is_variant(json.loads(self.ref_d)))
    self.assertFalse(expander.is_variant(json.loads(self.ref_ambiguous)))
    self.assertFalse(expander.is_variant(json.loads(self.no_call_1)))

  def test_mapper_variant(self):
    test_input = json.loads(self.variant_1)

    expected_output = json.loads(self.variant_1)  # no changes

    expander = GvcfExpander()
    result = expander.map(fields=test_input)
    self.assertEqual(1, len(result))
    (key, value) = result[0]
    self.assertEqual('13:1022656', key)
    self.assertDictEqual(expected_output, value)

  def test_mapper_ref_block(self):
    test_input = json.loads(self.ref_a)

    expected_output = json.loads(self.ref_a)  # no changes

    expander = GvcfExpander()
    result = expander.map(fields=test_input)
    self.assertEqual(3, len(result))
    self.assertEqual('13:1022656', result[0].k)
    self.assertEqual('13:1022657', result[1].k)
    self.assertEqual('13:1022658', result[2].k)
    for i in range(0, 3):
      self.assertDictEqual(expected_output, result[i].v)

  def test_mapper_no_call(self):
    test_input = json.loads(self.no_call_1)

    expected_output = json.loads(self.no_call_1)  # no changes

    expander = GvcfExpander()
    result = expander.map(fields=test_input)
    self.assertEqual(1, len(result))
    (key, value) = result[0]
    self.assertEqual('13:1022656', key)
    self.assertDictEqual(expected_output, value)

  def test_mr_variant(self):
    test_input = json.loads(self.variant_1)

    expected_output = json.loads(self.variant_1)  # no changes

    expander = GvcfExpander()
    result = expander.map(fields=test_input)
    self.assertEqual(1, len(result))
    (key, value) = result[0]
    self.assertEqual('13:1022656', key)
    self.assertDictEqual(expected_output, value)

    result = expander.reduce(pair=result[0])
    self.assertEqual(0, len(result))
    result = expander.finalize()
    self.assertEqual(1, len(result))
    value = result[0]
    self.assertDictEqual(expected_output, value)

  def test_mr_ref(self):
    test_input = json.loads(self.ref_a)

    expected_output = json.loads(self.ref_a)  # no changes

    expander = GvcfExpander()
    pairs = expander.map(fields=test_input)
    self.assertEqual(3, len(pairs))

    result = expander.reduce(pairs[0])
    self.assertEqual(0, len(result))
    result = expander.reduce(pairs[1])
    self.assertEqual(1, len(result))
    value = result[0]
    self.assertDictEqual(expected_output, value)

    for i in range(2, 3):
      result = expander.reduce(pairs[i])
      self.assertEqual(0, len(result))

    result = expander.finalize()
    self.assertEqual(0, len(result))

  def test_mr_no_call(self):
    test_input = json.loads(self.no_call_1)

    expected_output = json.loads(self.no_call_1)  # no changes

    expander = GvcfExpander()
    result = expander.map(fields=test_input)
    self.assertEqual(1, len(result))
    (key, value) = result[0]
    self.assertEqual('13:1022656', key)
    self.assertDictEqual(expected_output, value)

    result = expander.reduce(pair=result[0])
    self.assertEqual(0, len(result))
    result = expander.finalize()
    self.assertEqual(1, len(result))
    value = result[0]
    self.assertDictEqual(expected_output, value)

  def test_mr(self):

    for filter_ref_matches in [True, False]:
      expander = GvcfExpander(filter_ref_matches=filter_ref_matches)
      pairs = []

      pairs.extend(expander.map(fields=json.loads(self.ref_a)))
      pairs.extend(expander.map(fields=json.loads(self.ref_b)))
      pairs.extend(expander.map(fields=json.loads(self.ref_c)))
      pairs.extend(expander.map(fields=json.loads(self.ref_ambiguous)))
      pairs.extend(expander.map(fields=json.loads(self.variant_1)))
      pairs.extend(expander.map(fields=json.loads(self.variant_2)))
      pairs.extend(expander.map(fields=json.loads(self.no_call_1)))
      self.assertEqual(11, len(pairs))

      # Sort these by key so that all pairs in the same bin are in a
      # row, but not necessarily in any order within that bin
      pairs = sorted(pairs)

      self.assertEqual(0, len(expander.reduce(pairs[0])))
      self.assertEqual(0, len(expander.reduce(pairs[1])))
      self.assertEqual(0, len(expander.reduce(pairs[2])))
      self.assertEqual(0, len(expander.reduce(pairs[3])))
      self.assertEqual(0, len(expander.reduce(pairs[4])))
      self.assertEqual(0, len(expander.reduce(pairs[5])))
      self.assertEqual(0, len(expander.reduce(pairs[6])))
      result = expander.reduce(pairs[7])
      self.assertEqual(7, len(result))
      self.assertIn(json.loads(self.ref_b), result)
      self.assertIn(json.loads(self.ref_c), result)
      self.assertIn(json.loads(self.ref_a), result)
      self.assertIn(json.loads(self.ref_ambiguous), result)
      self.assertIn(json.loads(self.no_call_1), result)

      if True == filter_ref_matches:
        self.assertIn(json.loads(self.expanded_variant_1_filtered), result)
        self.assertIn(json.loads(self.expanded_variant_2), result)
      else:
        self.assertIn(json.loads(self.expanded_variant_1), result)
        self.assertIn(json.loads(self.expanded_variant_2), result)

      for i in range(7, 11):
        result = expander.reduce(pairs[i])
        self.assertEqual(0, len(result))

  def setUp(self):
    self.maxDiff = None

    self.ref_a = """
{
  "contig_name": "13",
  "start_pos": "102265642",
  "end_pos": "102265643",
  "reference_bases": "N",
  "END": "102265842",
  "call": [
    {
      "callset_id": "1",
      "callset_name": "same_start",
      "gt": "0/0",
      "ps": "."
    },
    {
      "callset_id": "2",
      "callset_name": "same_start_second_sample",
      "gt": "0/0",
      "ps": "."
    }
  ]
}
"""

    self.ref_b = """
{
  "contig_name": "13",
  "start_pos": "102265602",
  "end_pos": "102265643",
  "reference_bases": "N",
  "END": "102265842",
  "call": [
    {
      "callset_id": "1",
      "callset_name": "different_start",
      "gt": "0/0",
      "ps": "."
    }
  ]
}
"""

    self.ref_ambiguous = """
{
  "contig_name": "13",
  "start_pos": "102265642",
  "end_pos": "102265643",
  "reference_bases": "N",
  "END": "102265650",
  "call": [
    {
      "callset_id": "3",
      "callset_name": "ambiguous",
      "gt": "0/0",
      "ps": "."
    }
  ]
}
"""

    self.ref_c = """
{
  "contig_name": "13",
  "start_pos": "102265602",
  "end_pos": "102265643",
  "reference_bases": "N",
  "END": "102265642",
  "call": [
    {
      "callset_id": "1",
      "callset_name": "does_not_overlap_var_1",
      "gt": "0/0",
      "ps": "."
    }
  ]
}
"""

    self.ref_d = """
{
  "contig_name": "chr14",
  "start_pos": "22973137",
  "end_pos": "22973138",
  "reference_bases": "A",
  "alternate_bases": [
  ],
  "ac": [
  ],
  "af": [
  ],
  "END": "22973211",
  "mleac": [
  ],
  "mleaf": [
  ],
  "rpa": [
  ],
  "call": [
    {
      "callset_id": "715080930289-10",
      "callset_name": "foo1",
      "ad": [
      ],
      "dp": "44",
      "gt": "0\/0",
      "pl": [
      ]
    },
    {
      "callset_id": "715080930289-14",
      "callset_name": "foo2",
      "ad": [
      ],
      "dp": "35",
      "gt": "0\/0",
      "pl": [
      ]
    }
  ]
}
"""

    self.no_call_1 = """
{
  "AC":[

  ],
  "CGA_FI":[

  ],
  "MEINFO":[

  ],
  "reference_bases":"TGA",
  "CGA_MIRB":[

  ],
  "NS":"1",
  "alternate_bases":[

  ],
  "CGA_RPT":[

  ],
  "CIPOS":[

  ],
  "AN":"0",
  "CGA_XR":[

  ],
  "CGA_PFAM":[

  ],
  "contig_name": "13",
  "start_pos": "102265642",
  "call":[
    {
      "callset_id":"7122130836277736291-116",
      "CGA_RDP":"14",
      "FT":"PASS",
      "AD":[
        "10",
        "14"
      ],
      "phaseset":"7278593",
      "EHQ":[

      ],
      "HQ":[

      ],
      "FILTER": "True",
      "QUAL":0,
      "callset_name":"no_call",
      "genotype_likelihood":[

      ],
      "DP":"30",
      "genotype":[
        -1,
        -1
      ]
    }
  ],
  "end_pos": "102265645",
  "CGA_MEDEL":[

  ]
}
"""

    self.variant_1 = """
{
  "contig_name": "13",
  "start_pos": "102265642",
  "end_pos": "102265647",
  "reference_bases": "GTTCA",
  "alternate_bases": [
    "G"
  ],
  "ac": [
    "1"
  ],
  "an": "2",
  "cga_fi": [
    "9358|NM_004791.1|ITGBL1|INTRON|UNKNOWN-INC"
  ],
  "cga_medel": [

  ],
  "cga_mirb": [

  ],
  "cga_pfam": [

  ],
  "cga_rpt": [
    "(TTCA)n|Simple_repeat|0.0"
  ],
  "cga_xr": [

  ],
  "cipos": [

  ],
  "meinfo": [

  ],
  "ns": "1",
  "call": [
    {
      "callset_id": "383928317087-12",
      "callset_name": "hu52B7E5",
      "ad": [
        "3",
        "22"
      ],
      "cga_rdp": "22",
      "dp": "25",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "VQLOW",
      "gl": [
        "-33",
        "0",
        "-33"
      ],
      "gq": "33",
      "gt": "1/0",
      "hq": [
        "33",
        "33"
      ],
      "ps": "."
    },
    {
      "callset_id": "383928317087-34",
      "callset_name": "hu1187FF",
      "ad": [
        "2",
        "27"
      ],
      "cga_rdp": "27",
      "dp": "29",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "VQLOW",
      "gl": [
        "-36",
        "0",
        "-36"
      ],
      "gq": "36",
      "gt": "1/0",
      "hq": [
        "36",
        "36"
      ],
      "ps": "."
    },
    {
      "callset_id": "383928317087-38",
      "callset_name": "huC434ED",
      "ad": [
        "3",
        "29"
      ],
      "cga_rdp": "29",
      "dp": "32",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "PASS",
      "gl": [
        "-42",
        "0",
        "-42"
      ],
      "gq": "42",
      "gt": "1/0",
      "hq": [
        "42",
        "42"
      ],
      "ps": "."
    },
    {
      "callset_id": "3",
      "callset_name": "ambiguous",
      "ad": [
        "3",
        "12"
      ],
      "cga_rdp": "12",
      "dp": "15",
      "ehq": [
        "75",
        "75"
      ],
      "ft": "PASS",
      "gl": [
        "-86",
        "0",
        "-86"
      ],
      "gq": "86",
      "gt": "1/0",
      "hq": [
        "86",
        "86"
      ],
      "ps": "."
    }
  ]
}
"""

    self.expanded_variant_1 = """
{
  "contig_name": "13",
  "start_pos": "102265642",
  "end_pos": "102265647",
  "reference_bases": "GTTCA",
  "alternate_bases": [
    "G"
  ],
  "ac": [
    "1"
  ],
  "an": "2",
  "cga_fi": [
    "9358|NM_004791.1|ITGBL1|INTRON|UNKNOWN-INC"
  ],
  "cga_medel": [

  ],
  "cga_mirb": [

  ],
  "cga_pfam": [

  ],
  "cga_rpt": [
    "(TTCA)n|Simple_repeat|0.0"
  ],
  "cga_xr": [

  ],
  "cipos": [

  ],
  "meinfo": [

  ],
  "ns": "1",
  "call": [
    {
      "callset_id": "383928317087-12",
      "callset_name": "hu52B7E5",
      "ad": [
        "3",
        "22"
      ],
      "cga_rdp": "22",
      "dp": "25",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "VQLOW",
      "gl": [
        "-33",
        "0",
        "-33"
      ],
      "gq": "33",
      "gt": "1/0",
      "hq": [
        "33",
        "33"
      ],
      "ps": "."
    },
    {
      "callset_id": "383928317087-34",
      "callset_name": "hu1187FF",
      "ad": [
        "2",
        "27"
      ],
      "cga_rdp": "27",
      "dp": "29",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "VQLOW",
      "gl": [
        "-36",
        "0",
        "-36"
      ],
      "gq": "36",
      "gt": "1/0",
      "hq": [
        "36",
        "36"
      ],
      "ps": "."
    },
    {
      "callset_id": "383928317087-38",
      "callset_name": "huC434ED",
      "ad": [
        "3",
        "29"
      ],
      "cga_rdp": "29",
      "dp": "32",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "PASS",
      "gl": [
        "-42",
        "0",
        "-42"
      ],
      "gq": "42",
      "gt": "1/0",
      "hq": [
        "42",
        "42"
      ],
      "ps": "."
    },
    {
      "callset_id": "3",
      "callset_name": "ambiguous",
      "ad": [
        "3",
        "12"
      ],
      "cga_rdp": "12",
      "dp": "15",
      "ehq": [
        "75",
        "75"
      ],
      "ft": "PASS",
      "gl": [
        "-86",
        "0",
        "-86"
      ],
      "gq": "86",
      "gt": "1/0",
      "hq": [
        "86",
        "86"
      ],
      "ps": "."
    },
    {
      "callset_id": "1",
      "callset_name": "different_start",
      "gt": "0/0",
      "ps": "."
    },
    {
      "callset_id": "1",
      "callset_name": "same_start",
      "gt": "0/0",
      "ps": "."
    },
    {
      "callset_id": "2",
      "callset_name": "same_start_second_sample",
      "gt": "0/0",
      "ps": "."
    },
    {
      "callset_id":"7122130836277736291-116",
      "CGA_RDP":"14",
      "FT":"PASS",
      "AD":[
        "10",
        "14"
      ],
      "EHQ":[

      ],
      "phaseset":"7278593",
      "HQ":[

      ],
      "FILTER": "True",
      "QUAL":0,
      "callset_name":"no_call",
      "genotype_likelihood":[

      ],
      "DP":"30",
      "genotype":[
        -1,
        -1
      ]
    },
    {
      "callset_id": "3",
      "callset_name": "ambiguous",
      "gt": "0/0",
      "ps": "."
    }
  ]
}
"""

    self.expanded_variant_1_filtered = """
{
  "contig_name": "13",
  "start_pos": "102265642",
  "end_pos": "102265647",
  "reference_bases": "GTTCA",
  "alternate_bases": [
    "G"
  ],
  "ac": [
    "1"
  ],
  "an": "2",
  "cga_fi": [
    "9358|NM_004791.1|ITGBL1|INTRON|UNKNOWN-INC"
  ],
  "cga_medel": [

  ],
  "cga_mirb": [

  ],
  "cga_pfam": [

  ],
  "cga_rpt": [
    "(TTCA)n|Simple_repeat|0.0"
  ],
  "cga_xr": [

  ],
  "cipos": [

  ],
  "meinfo": [

  ],
  "ns": "1",
  "call": [
    {
      "callset_id": "383928317087-12",
      "callset_name": "hu52B7E5",
      "ad": [
        "3",
        "22"
      ],
      "cga_rdp": "22",
      "dp": "25",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "VQLOW",
      "gl": [
        "-33",
        "0",
        "-33"
      ],
      "gq": "33",
      "gt": "1/0",
      "hq": [
        "33",
        "33"
      ],
      "ps": "."
    },
    {
      "callset_id": "383928317087-34",
      "callset_name": "hu1187FF",
      "ad": [
        "2",
        "27"
      ],
      "cga_rdp": "27",
      "dp": "29",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "VQLOW",
      "gl": [
        "-36",
        "0",
        "-36"
      ],
      "gq": "36",
      "gt": "1/0",
      "hq": [
        "36",
        "36"
      ],
      "ps": "."
    },
    {
      "callset_id": "383928317087-38",
      "callset_name": "huC434ED",
      "ad": [
        "3",
        "29"
      ],
      "cga_rdp": "29",
      "dp": "32",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "PASS",
      "gl": [
        "-42",
        "0",
        "-42"
      ],
      "gq": "42",
      "gt": "1/0",
      "hq": [
        "42",
        "42"
      ],
      "ps": "."
    },
    {
      "callset_id": "3",
      "callset_name": "ambiguous",
      "ad": [
        "3",
        "12"
      ],
      "cga_rdp": "12",
      "dp": "15",
      "ehq": [
        "75",
        "75"
      ],
      "ft": "PASS",
      "gl": [
        "-86",
        "0",
        "-86"
      ],
      "gq": "86",
      "gt": "1/0",
      "hq": [
        "86",
        "86"
      ],
      "ps": "."
    },
    {
      "callset_id": "1",
      "callset_name": "different_start",
      "gt": "0/0",
      "ps": "."
    },
    {
      "callset_id": "1",
      "callset_name": "same_start",
      "gt": "0/0",
      "ps": "."
    },
    {
      "callset_id": "2",
      "callset_name": "same_start_second_sample",
      "gt": "0/0",
      "ps": "."
    },
    {
      "callset_id":"7122130836277736291-116",
      "CGA_RDP":"14",
      "FT":"PASS",
      "AD":[
        "10",
        "14"
      ],
      "EHQ":[

      ],
      "phaseset":"7278593",
      "HQ":[

      ],
      "FILTER": "True",
      "QUAL":0,
      "callset_name":"no_call",
      "genotype_likelihood":[

      ],
      "DP":"30",
      "genotype":[
        -1,
        -1
      ]
    }
  ]
}
"""

    self.variant_2 = """
{
  "contig_name": "13",
  "start_pos": "102265640",
  "end_pos": "102265645",
  "reference_bases": "GTTCA",
  "alternate_bases": [
    "A"
  ],
  "ac": [
    "1"
  ],
  "an": "2",
  "cga_fi": [
    "9358|NM_004791.1|ITGBL1|INTRON|UNKNOWN-INC"
  ],
  "cga_medel": [

  ],
  "cga_mirb": [

  ],
  "cga_pfam": [

  ],
  "cga_rpt": [
    "(TTCA)n|Simple_repeat|0.0"
  ],
  "cga_xr": [

  ],
  "cipos": [

  ],
  "meinfo": [

  ],
  "ns": "1",
  "call": [
    {
      "callset_id": "383928317087-12",
      "callset_name": "hu52B7E5",
      "ad": [
        "3",
        "22"
      ],
      "cga_rdp": "22",
      "dp": "25",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "VQLOW",
      "gl": [
        "-33",
        "0",
        "-33"
      ],
      "gq": "33",
      "gt": "1/0",
      "hq": [
        "33",
        "33"
      ],
      "ps": "."
    },
    {
      "callset_id": "383928317087-34",
      "callset_name": "hu1187FF",
      "ad": [
        "2",
        "27"
      ],
      "cga_rdp": "27",
      "dp": "29",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "VQLOW",
      "gl": [
        "-36",
        "0",
        "-36"
      ],
      "gq": "36",
      "gt": "1/0",
      "hq": [
        "36",
        "36"
      ],
      "ps": "."
    },
    {
      "callset_id": "383928317087-38",
      "callset_name": "huC434ED",
      "ad": [
        "3",
        "29"
      ],
      "cga_rdp": "29",
      "dp": "32",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "PASS",
      "gl": [
        "-42",
        "0",
        "-42"
      ],
      "gq": "42",
      "gt": "1/0",
      "hq": [
        "42",
        "42"
      ],
      "ps": "."
    },
    {
      "callset_id": "383928317087-48",
      "callset_name": "hu0211D6",
      "ad": [
        "3",
        "12"
      ],
      "cga_rdp": "12",
      "dp": "15",
      "ehq": [
        "75",
        "75"
      ],
      "ft": "PASS",
      "gl": [
        "-86",
        "0",
        "-86"
      ],
      "gq": "86",
      "gt": "1/0",
      "hq": [
        "86",
        "86"
      ],
      "ps": "."
    }
  ]
}
"""

    self.expanded_variant_2 = """
{
  "contig_name": "13",
  "start_pos": "102265640",
  "end_pos": "102265645",
  "reference_bases": "GTTCA",
  "alternate_bases": [
    "A"
  ],
  "ac": [
    "1"
  ],
  "an": "2",
  "cga_fi": [
    "9358|NM_004791.1|ITGBL1|INTRON|UNKNOWN-INC"
  ],
  "cga_medel": [

  ],
  "cga_mirb": [

  ],
  "cga_pfam": [

  ],
  "cga_rpt": [
    "(TTCA)n|Simple_repeat|0.0"
  ],
  "cga_xr": [

  ],
  "cipos": [

  ],
  "meinfo": [

  ],
  "ns": "1",
  "call": [
    {
      "callset_id": "383928317087-12",
      "callset_name": "hu52B7E5",
      "ad": [
        "3",
        "22"
      ],
      "cga_rdp": "22",
      "dp": "25",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "VQLOW",
      "gl": [
        "-33",
        "0",
        "-33"
      ],
      "gq": "33",
      "gt": "1/0",
      "hq": [
        "33",
        "33"
      ],
      "ps": "."
    },
    {
      "callset_id": "383928317087-34",
      "callset_name": "hu1187FF",
      "ad": [
        "2",
        "27"
      ],
      "cga_rdp": "27",
      "dp": "29",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "VQLOW",
      "gl": [
        "-36",
        "0",
        "-36"
      ],
      "gq": "36",
      "gt": "1/0",
      "hq": [
        "36",
        "36"
      ],
      "ps": "."
    },
    {
      "callset_id": "383928317087-38",
      "callset_name": "huC434ED",
      "ad": [
        "3",
        "29"
      ],
      "cga_rdp": "29",
      "dp": "32",
      "ehq": [
        "0",
        "0"
      ],
      "ft": "PASS",
      "gl": [
        "-42",
        "0",
        "-42"
      ],
      "gq": "42",
      "gt": "1/0",
      "hq": [
        "42",
        "42"
      ],
      "ps": "."
    },
    {
      "callset_id": "383928317087-48",
      "callset_name": "hu0211D6",
      "ad": [
        "3",
        "12"
      ],
      "cga_rdp": "12",
      "dp": "15",
      "ehq": [
        "75",
        "75"
      ],
      "ft": "PASS",
      "gl": [
        "-86",
        "0",
        "-86"
      ],
      "gq": "86",
      "gt": "1/0",
      "hq": [
        "86",
        "86"
      ],
      "ps": "."
    },
    {
      "callset_id": "1",
      "callset_name": "different_start",
      "gt": "0/0",
      "ps": "."
    },
    {
      "callset_id": "1",
      "callset_name": "does_not_overlap_var_1",
      "gt": "0/0",
      "ps": "."
    }
  ]
}
"""

if __name__ == '__main__':
  unittest.main()
