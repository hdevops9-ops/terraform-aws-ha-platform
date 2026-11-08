import unittest
from check_plan import inspect
class PlanTests(unittest.TestCase):
    def test_create_allowed(self):
        self.assertEqual(inspect({"resource_changes":[{"address":"a","change":{"actions":["create"]}}]})["destructive_changes"],0)
    def test_replacement_rejected(self):
        with self.assertRaises(ValueError): inspect({"resource_changes":[{"address":"a","change":{"actions":["delete","create"]}}]})
    def test_delete_rejected(self):
        with self.assertRaises(ValueError): inspect({"resource_changes":[{"address":"a","change":{"actions":["delete"]}}]})
    def test_errored_plan_rejected(self):
        with self.assertRaises(ValueError):inspect({"errored":True})
if __name__ == "__main__":unittest.main()
