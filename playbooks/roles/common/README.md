common
======

The common role lets you add tasks which is commmon to all workflows.
Without this we would be duplicating code.

Requirements
------------

None.

Role Variables
--------------

  * kdevops_git_reset: perform a git reset. This is useful in case you want
	to change the URL you use for kdevops.

Dependencies
------------

None.

Example Playbook
----------------

Below is an example playbook task:

```
---
- hosts: all
  roles:
    - role: common
```

License
-------

copyleft-next-0.3.1
