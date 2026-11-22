from hdl import commit_state

def FilteredDomain_step(mut sim: FilteredDomain):
    sim.p1()
    commit_state(sim)

