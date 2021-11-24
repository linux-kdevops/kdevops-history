# Using kdevops as a git subtree

Because it is expected that kernel-ci efforts might deal with releases which
are not yet public, you are encouraged to use kdevops as a git subtree if you
want to carry a delta which for whatever reason you cannot make public yet.
Reasons for having your own kdevops git tree which uses the public kdevops
tree as a git sub tree might be:

  * keeping track of expunges for baselines for releases which are not yet
    public
  * adding support vagrant images for releases which are not yet public
  * dealing with internal R&D registration (consider enterprise Linux
    registration) of guests to a subscription service

If you have your own delta you are hightly encouraged to try to minimize the
amount of delta, otherwise it may be difficult to keep up with the project.
