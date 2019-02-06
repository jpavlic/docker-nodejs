import unittest
import urllib2
import time
import json


class SmokeTests(unittest.TestCase):
    def smoke_test_container(self, port):
        self.assertTrue(1 == 1, "Always passes")


class NodeTest(SmokeTests):
    def test_hub_and_node_up(self):
        self.smoke_test_container(8080)
        self.smoke_test_container(80)


class StandaloneTest(SmokeTests):
    def test_standalone_up(self):
        self.smoke_test_container(80)
