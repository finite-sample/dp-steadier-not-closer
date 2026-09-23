# Published-number check

The Distortions manuscript reports 21 polls, 372 small groups, 5,736
participants, 139 policy issues, and 2,601 group-issue pairs. The corrected
replication in the sibling `distortions` repository shows that the published
inventory mixes data versions: the archived file has 6,084 rows, including 217
exact duplicates; after deduplication it has 5,867 retained records, 397 groups,
129 reconstructed policy indices, and 2,480 valid group-index pairs.

Those inventory corrections do not erase the paper's main qualitative result.
The corrected average homogenization estimate is .01285 and the corrected
polarization estimate is -.02221. The original repository's `AUDIT.md` is the
authoritative, fully tested audit for the empirical tables.

For Cor and Sood's knowledge paper, the central reliability and learning
numbers reproduce after rounding. The companion `dp-knowledge` repository
records two changed diagnostics: LCA exceeds raw learning for 80.8% of items in
the deposited workflow rather than the paper's 78.5%, and current `guess`
classifies 75.1% of items as fitting rather than 83.1%. Mean raw, LCA, and
standard-correction learning remain .158, .210, and .182 after rounding.
