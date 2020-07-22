# One ansible role to rule them all

Each ansible role and terraform module which kdevops uses focuses on one
specific small goal of the development focus of kdevops. Since the number of
ansible roles which kdevops makes use of has grown, and we don't want to deal
with the complexities of 'galaxy collections', we rely on *one* galaxy role to
let you install all the rest of the kdevops dependencies for you:

  * [kdevops_install](https://github.com/mcgrof/kdevops_install)

This project synchronizes releases based on that role's own releases, and
so there is parity in release numbers between both of these projects to
reflect this.
