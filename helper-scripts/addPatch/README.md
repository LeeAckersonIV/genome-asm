# Instructions to run the addPatch.pl script

### command

perl addPatch.pl --gaf test.gaf --patch test_patch.tsv --map test_utig4_to_2 --verbose > test.out 2> test.log

there are four command line arguments:

```bash
--gaf test.gaf: this is the gaf from verkko before detangling, this tab delimited file must have the header: name path assignment
--patch test_patch.tsv: also tab delimited file where the columns are (containing header):old_names(semicolon_separated) new_path(patch) new_name new_assignment
--map test_utig4_2_utig1: the conversion map between utig4 and utig1, must contain no header
```
test files and output are provided in this directory.

### prepare the patch file

The patch file must be tab delimited and contain the header old_names(semicolon_separated) new_path(patch) new_name new_assignment

There are three possible ways patch can happen:

1) when the old name (1st column) is the same as the new name (3rd column), the old gaf line corresponding to the old name is replaced with new path and new assignment.
2) when the old name contains multiple semicolon separated paths, the multiple lines in the old gaf are deleted and replaced with one single line with the new name, new path, and new alignment. This happens when you merge multiple paths.
3) when multiple lines in the patch file share the same old name, the one line in the old gaf is replaced with the multiple lines corresponding to the new names, new paths, and new assignments. This happens when you split one path into multiple.

After these patches are applied, a few things can happen to the unitigs.

1) a node is reactivated: an unused node is now part of a new path, the unused node is deleted from the gaf and now part of the new path.
2) a node is orphaned: a node that was in a path is now unused.

A special case is when the patch is in the utig1 space. All unused nodes and all original utig4 nodes are checked against the new patch (utig1 path). If a utig4 node's utig1 path is part of the patch (when the largest contiguous match is more than 60% of the path when the number of utig1 nodes is less than or equal to 10 or the largest contiguous match is more than 90% of the path when the number is greater than 10), it is considered covered. A convered node is reactivated and a uncovered node is orphaned and dealt with accordingly.
