# Upstream bugs reported on kdevops for XFS

There are plenty of bugs found and reported by kdevops, you can use git grep
korg for bugs reported bugzilla.kernel.org but there are also many bugs reported
on other bugzillas for other distributions. This section tracks bugs perhaps
not yet reported on linux-next or rc kernels.

## v6.6-rc5

  * [korg#218224](https://bugzilla.kernel.org/show_bug.cgi?id=218224) - XFS: Assertion failed: ip->i_nblocks == 0 file: fs/xfs/xfs_inode.c, line: 2359
  * [korg#218225](https://bugzilla.kernel.org/show_bug.cgi?id=218225) - xfs assert (irec->br_blockcount & ~XFS_IEXT_LENGTH_MASK) == 0 file: fs/xfs/libxfs/xfs_iext_tree.c, line: 58
  * [korg#218226](https://bugzilla.kernel.org/show_bug.cgi?id=218226) - XFS: Assertion failed: bp->b_flags & XBF_DONE, file: fs/xfs/xfs_trans_buf.c, line: 241 
  * [korg#216114](https://bugzilla.kernel.org/show_bug.cgi?id=216114) - page dumped because: VM_BUG_ON_FOLIO(!folio_contains(folio, index)) and kernel BUG at mm/truncate.c:669!
  * [korg#218227](https://bugzilla.kernel.org/show_bug.cgi?id=218227) - fsstress + compaction
