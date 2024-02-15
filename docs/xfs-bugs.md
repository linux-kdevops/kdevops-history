Table of Contents
=================

* [Table of Contents](#table-of-contents)
* [Upstream bugs reported on kdevops for XFS](#upstream-bugs-reported-on-kdevops-for-xfs)
   * [Process for stable fixes](#process-for-stable-fixes)
   * [v6.6-rc5](#v66-rc5)
      * [Defining critical bugs](#defining-critical-bugs)
      * [Critial bugs count](#critial-bugs-count)
      * [Non critical bugs count](#non-critical-bugs-count)
      * [XFS bugs](#xfs-bugs)
         * [1) <a href="https://bugzilla.kernel.org/show_bug.cgi?id=218224" rel="nofollow">korg#218224</a> - XFS: Assertion failed: ip-&gt;i_nblocks == 0 file: fs/xfs/xfs_inode.c, line: 2359](#1-korg218224---xfs-assertion-failed-ip-i_nblocks--0-file-fsxfsxfs_inodec-line-2359)
         * [2) <a href="https://bugzilla.kernel.org/show_bug.cgi?id=218225" rel="nofollow">korg#218225</a> - xfs assert (irec-&gt;br_blockcount &amp; ~XFS_IEXT_LENGTH_MASK) == 0 file: fs/xfs/libxfs/xfs_iext_tree.c, line: 58](#2-korg218225---xfs-assert-irec-br_blockcount--xfs_iext_length_mask--0-file-fsxfslibxfsxfs_iext_treec-line-58)
         * [3) <a href="https://bugzilla.kernel.org/show_bug.cgi?id=218226" rel="nofollow">korg#218226</a> - XFS: Assertion failed: bp-&gt;b_flags &amp; XBF_DONE, file: fs/xfs/xfs_trans_buf.c, line: 241](#3-korg218226---xfs-assertion-failed-bp-b_flags--xbf_done-file-fsxfsxfs_trans_bufc-line-241)
         * [4) <a href="https://bugzilla.kernel.org/show_bug.cgi?id=218229" rel="nofollow">korg#218229</a> - xfs/438 hung](#4-korg218229---xfs438-hung)
         * [5) <a href="https://bugzilla.kernel.org/show_bug.cgi?id=218230" rel="nofollow">korg#218230</a> - xfs/538 hung](#5-korg218230---xfs538-hung)
      * [Memory management bugs](#memory-management-bugs)
         * [1) <a href="https://bugzilla.kernel.org/show_bug.cgi?id=216114" rel="nofollow">korg#216114</a> - page dumped because: VM_BUG_ON_FOLIO(!folio_contains(folio, index)) and kernel BUG at mm/truncate.c:669!](#1-korg216114---page-dumped-because-vm_bug_on_foliofolio_containsfolio-index-and-kernel-bug-at-mmtruncatec669) -- fixed by commit fc346d0a70a1 ("mm: migrate high-order folios in swap cache correctly") merged as of v6.7-rc8
         * [2) <a href="https://bugzilla.kernel.org/show_bug.cgi?id=218227" rel="nofollow">korg#218227</a> - fsstress + compaction](#2-korg218227---fsstress--compaction)

# Upstream bugs reported on kdevops for XFS

There are plenty of bugs found and reported by kdevops, you can use git grep
korg for bugs reported bugzilla.kernel.org but there are also many bugs reported
on other bugzillas for other distributions. This section tracks bugs perhaps
not yet reported on linux-next or rc kernels.

## Process for stable fixes

A table fix candidate does by no means indicate that we should immediately send
the fix to stable, this is precisely why we have stable XFS maintainers to avoid
fiascos to users like the recent [ext4 data corruption](https://lwn.net/Articles/954770/)
and so someone has to go through the trouble of ensuring first:

  * 1) A baseline is created for the respective stable kernel
  * 2) Verifying that the fix does not regress that stable kernel

Please coordinate with the stable XFS maintainers:

 * Leah Rumancik <leah.rumancik@gmail.com>
 * Amir Goldstein <amir73il@gmail.com>
 * Chandan Babu R <chandan.babu@oracle.com>

Likewise if the issue is found not yet merged upstream a fix first needs
to be vetted by the community, and ultimately the release manager will
decide when / if to merge something. The release manager for XFS is
Chandan Babu R <chandan.babu@oracle.com>.

## v6.6-rc5

We have found XFS bugs and also memory management bugs. We spit this into
two sections.

### Defining critical bugs

Critical bugs are:

  * Crashes
  * Asserts with memory or XFS debug enabled
  * hung tasks

### Critial bugs count

Since we strive to report all critical bugs and use a notation to describe
their respective bugzilla.kernel.org entries we can find all critical bugs
as follows:

```
cat workflows/fstests/expunges/6.6.0-rc5/xfs/unassigned/*.txt| egrep -i "korg|hung task"| wc -l
46
```

### Non critical bugs count

Non critical bugs can be found withe following then:

```
cat workflows/fstests/expunges/6.6.0-rc5/xfs/unassigned/*.txt| grep -v korg | grep -i -v "hung task"| wc -l
410
```

The explanation as to what caused some of these issues can be found by using
git blame on respective commit if the commit author had time and the confidence
to explain the bug. Otherwise you can help to diagnose and look into the issue
more carefully by inspecting the archive of results for the bug.

XXX: Add a script which let's a developer easily look for logs for a respective
bug on all archives for a specific kernel.

### XFS bugs

Below are the bugs reported to the community which have been found using
v6.6-rc5 as a baseline.

#### 1) [korg#218224](https://bugzilla.kernel.org/show_bug.cgi?id=218224) - XFS: Assertion failed: ip->i_nblocks == 0 file: fs/xfs/xfs_inode.c, line: 2359

Luis noted how this resembles a bug found previously on s390, Chinner
[suggested](https://lore.kernel.org/all/ZXPy4+cXlIt0agNz@dread.disaster.area/T/#u)
hat perhaps the fix for that issue could be tried to see if it resolves the crash
on x86_64. The fix is commit 7930d9e10370 ("xfs: recovery should not clear
di_flushiter unconditionally").


```
git describe --contains 7930d9e10370
v6.7-rc2~10^2
```

This tells us that the fix was first merged into v6.7-rc2~10, and so clearly
not part of v6.6-rc5 which was where the issues were found. If this fix
is confirmed to resolve these issues it would be a good stable backport
candidate to evaluate for integration.

#### 2) [korg#218225](https://bugzilla.kernel.org/show_bug.cgi?id=218225) - xfs assert (irec->br_blockcount & ~XFS_IEXT_LENGTH_MASK) == 0 file: fs/xfs/libxfs/xfs_iext_tree.c, line: 58

No feedback from the community yet.

#### 3) [korg#218226](https://bugzilla.kernel.org/show_bug.cgi?id=218226) - XFS: Assertion failed: bp->b_flags & XBF_DONE, file: fs/xfs/xfs_trans_buf.c, line: 241 

[Chinner noted that this is a known issue](https://lore.kernel.org/linux-xfs/20231128153808.GA19360@lst.de/).
Christoph posted a patch but Chinner does not believe that is a right fix and
so a proper fix is still pending.

#### 4) [korg#218229](https://bugzilla.kernel.org/show_bug.cgi?id=218229) - xfs/438 hung

[Chandan noted that Leah had fixed
this](https://lore.kernel.org/linux-xfs/20231030203349.663275-1-leah.rumancik@gmail.com/), we should test and
confirms if this fixes the issue.

#### 5) [korg#218230](https://bugzilla.kernel.org/show_bug.cgi?id=218230) - xfs/538 hung

Chandan has root caused this issue and is working on an issue.

### Memory management bugs

Note that the memory management folks do not want us to use bugzilla.kernel.org
for memory management bugs. They want us to instead report issues to the
mailing list directly.

#### 1) [korg#216114](https://bugzilla.kernel.org/show_bug.cgi?id=216114) - page dumped because: VM_BUG_ON_FOLIO(!folio_contains(folio, index)) and kernel BUG at mm/truncate.c:669!

Matthew acknowledged that this is a terribly rare issue, and suggested and
[suggested a patch to try](https://lore.kernel.org/all/ZXQAgFl8WGr2pK7R@casper.infradead.org/T/#u)
to see if it fixes the issue.

This is confirmed to be fixed by commit fc346d0a70a1 ("mm: migrate high-order folios in swap cache correctly") merged as of v6.7-rc8.

#### 2) [korg#218227](https://bugzilla.kernel.org/show_bug.cgi?id=218227) - fsstress + compaction

Ongoing [discussion here](https://lore.kernel.org/all/8fa1c95c-4749-33dd-42ba-243e492ab109@suse.cz/)
Vlastimil noted this is caused as of commit 9c5ccf2db04b ("mm: remove HUGETLB_PAGE_DTOR")).

It is not yet clear what to do or how to resolve this.
