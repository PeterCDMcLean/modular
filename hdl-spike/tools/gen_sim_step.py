#!/usr/bin/env python3
"""Generate a Sim step adapter from an @module design.

Process methods are marked with a `# @process` comment immediately before the
method. The generator emits `<Module>_step(mut sim: Module)`, invoking every
discovered process and then `commit_state`.
"""

import re
import sys
from pathlib import Path

src = Path(sys.argv[1]).read_text().splitlines()
modules = []
current = None
pending_module = False

for i, line in enumerate(src):
    if "@module" in line:
        pending_module = True
    match = re.match(r"\s*struct\s+(\w+)", line)
    if match and pending_module:
        current = match.group(1)
        modules.append([current, []])
        pending_module = False
    if line.strip().startswith("# @process"):
        j = i + 1
        while j < len(src) and not src[j].strip():
            j += 1
        method = re.match(
            r"\s*def\s+(\w+)\s*\(\s*mut\s+self\s*\)\s*:", src[j]
        )
        if method and current:
            modules[-1][1].append(method.group(1))

if not modules or not any(methods for _, methods in modules):
    raise SystemExit("gen_sim_step: no @process methods found")

print("from hdl import commit_state")
print()
for name, methods in modules:
    if not methods:
        continue
    print(f"def {name}_step(mut sim: {name}):")
    for method in methods:
        print(f"    sim.{method}()")
    print("    commit_state(sim)")
    print()
