## Food for thought: a digital ledger for tests?

Email reports for success or failure might be useful for immediate attention,
but it provides no historical information or the big picture of the entire
software stack used to accomplish the results observed. Making it easy to query
for prior results, and under what circumstances they were encountered may be
valuable information for the future. This begs the question if we can do better
when recording results for baselines for a specific release.

Also, how do we scale in a distributed way? What if folks want to help test?
How do we vouch for their test rig setup?

One possibility might be to create our own test specific digital ledger which
aggregates all this information together, along with a protocol for agreement.
We might then be able to also use use smart contracts to codify specific
requirements for results on a test, so that if they are met and tests pass,
that a merge for a branch is considered acceptable. These ideas are being
evaluated.
