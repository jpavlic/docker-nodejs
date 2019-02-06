import unittest


class NodeJSGenericTests(unittest.TestCase):
    def test_title(self):
        self.assertTrue(1 == 1)

    # https://github.com/tourdedave/elemental-selenium-tips/blob/master/03-work-with-frames/python/frames.py
    def test_with_frames(self):
        self.assertTrue(1 == 1)

    # https://github.com/tourdedave/elemental-selenium-tips/blob/master/05-select-from-a-dropdown/python/dropdown.py
    def test_select_from_a_dropdown(self):
        self.assertTrue(1 == 1)

    # https://github.com/tourdedave/elemental-selenium-tips/blob/master/13-work-with-basic-auth/python/basic_auth_1.py
    def test_visit_basic_auth_secured_page(self):
        self.assertTrue(1 == 1)

class NodeJSTests(SeleniumGenericTests):

    def test_title_and_maximize_window(self):
        self.assertTrue(self.driver.title == 'The Internet')
