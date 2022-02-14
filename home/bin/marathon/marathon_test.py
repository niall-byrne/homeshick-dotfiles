import io
import sys
import unittest

from marathon import miles_to_km, overview
from unittest.mock import patch

# This code was so bad it's unbelievable


class MarathonTest(unittest.TestCase):
    def setUp(self):
        pass

    def debug(self, message):
        pass

    def tearDown(self):
        pass

    def test_miles_to_km(self):
        assert miles_to_km(2) == 2 * 1.60934
        assert miles_to_km(100) == 100 * 1.60934

    @patch('builtins.print')
    def test_overview_week_0(self, mockprint):
        overview(0, 0)
        mockprint.assert_not_called()

    @patch('builtins.print')
    def test_overview_week_1_in_past(self, mockprint):
        overview(0, 1)
        mockprint.assert_not_called()

    @patch('builtins.print')
    def test_overview_week_1_first(self, mockprint):
        overview(1, 0)
        mockprint.assert_called_with(
            "First Week's Long Run: 12.87 km, Total Distance: 33.80 km over 4 runs total."
        )

    @patch('builtins.print')
    def test_overview_week_2_future(self, mockprint):
        overview(2, 1)
        mockprint.assert_called_with(
            "Next Week's Long Run: 16.09 km, Total Distance: 40.23 km over 4 runs total."
        )

    @patch('builtins.print')
    def test_overview_week_2_future_idempotent(self, mockprint):
        overview(2, 1)
        mockprint.assert_called_with(
            "Next Week's Long Run: 16.09 km, Total Distance: 40.23 km over 4 runs total."
        )

    @patch('builtins.print')
    def test_overview_week_2_current_idempotent(self, mockprint):
        overview(2, 2)
        mockprint.assert_called_with(
            "This Week's Long Run: 16.09 km, Total Distance: 40.23 km over 4 runs total."
        )

    @patch('builtins.print')
    def test_overview_week_3_future(self, mockprint):
        overview(3, 1)
        mockprint.assert_called_with(
            "Week 3's Long Run: 9.66 km, Total Distance: 27.36 km over 4 runs total."
        )

    @patch('builtins.print')
    def test_overview_week_3_past(self, mockprint):
        overview(3, 6)
        mockprint.assert_called_with(
            "Week 3's Long Run: 9.66 km, Total Distance: 27.36 km over 4 runs total."
        )


if __name__ == '__main__':
    unittest.main(verbosity=2)
