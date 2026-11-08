"""Reject destructive Terraform actions. Read JSON from stdin; print no values."""
import json
import sys

def inspect(plan):
    if plan.get("errored"): raise ValueError("Terraform plan contains errors")
    changes = plan.get("resource_changes", [])
    deletes=[r["address"] for r in changes if "delete" in r["change"]["actions"]]
    if deletes: raise ValueError("Destructive/replacement changes rejected: " + ", ".join(deletes))
    return {"resource_changes": len(changes), "destructive_changes": 0}

if __name__ == "__main__":
    try: print(json.dumps(inspect(json.load(sys.stdin))))
    except (ValueError, KeyError) as e: sys.exit(str(e))
