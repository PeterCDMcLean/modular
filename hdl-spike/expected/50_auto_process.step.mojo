from hdl import commit_state

def AutoDomain_step(mut sim: AutoDomain):
    sim.p1()
    sim.p2()
    commit_state(sim)

