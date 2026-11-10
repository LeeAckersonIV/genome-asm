#!/usr/bin/env python3
import gzip
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

vcf_path = "output/pangenome_raw.vcf.gz"
output_plot = "output/variant_size_histogram.png"
output_pdf = "output/variant_size_histogram.pdf"
output_stats = "output/all_variants_size_summary.tsv"

ins_sizes = []
del_sizes = []

print(f"[*] Processing variants from {vcf_path}...")

with gzip.open(vcf_path, "rt") as f:
    for line in f:
        if line.startswith("#"):
            continue
        parts = line.strip().split("\t")
        ref, alt_str = parts[3], parts[4]

        # Evaluate first ALT allele
        alt = alt_str.split(",")[0]
        len_ref, len_alt = len(ref), len(alt)
        diff = len_alt - len_ref

        if diff > 0:
            ins_sizes.append(diff)
        elif diff < 0:
            del_sizes.append(abs(diff))

total_ins = len(ins_sizes)
total_del = len(del_sizes)
total_vars = total_ins + total_del

print(f"[*] Total Indels/SVs (>= 1 bp): {total_vars:,}")
print(f"    - Insertions: {total_ins:,}")
print(f"    - Deletions:  {total_del:,}")

# Combine sizes for overall statistics
all_sizes = ins_sizes + del_sizes

# ------------------------------------------------------------------------------
# 1. Binned Summary Table Generation
# ------------------------------------------------------------------------------
bins_def = [
    (1, 1, "1 bp (Single bp Indel)"),
    (2, 9, "2 - 9 bp"),
    (10, 49, "10 - 49 bp"),
    (50, 499, "50 - 499 bp (Small SV)"),
    (500, 999, "500 - 999 bp"),
    (1000, 9999, "1 - 10 kb"),
    (10000, float("inf"), ">= 10 kb (Large SV)"),
]

summary_rows = []
for low, high, label in bins_def:
    ins_c = sum(1 for x in ins_sizes if low <= x <= high)
    del_c = sum(1 for x in del_sizes if low <= x <= high)
    tot_c = ins_c + del_c
    pct = (tot_c / total_vars * 100) if total_vars > 0 else 0
    summary_rows.append(
        {
            "Size Class": label,
            "Insertions": ins_c,
            "Deletions": del_c,
            "Total": tot_c,
            "Percentage (%)": f"{pct:.2f}%",
        }
    )

df_summary = pd.DataFrame(summary_rows)
df_summary.to_csv(output_stats, sep="\t", index=False)
print(f"[*] Summary table saved to: {output_stats}\n")
print(df_summary.to_string(index=False))

# ------------------------------------------------------------------------------
# 2. Histogram Plot Creation (Log10 Size Scale)
# ------------------------------------------------------------------------------
fig, ax = plt.subplots(figsize=(10, 6), dpi=300)

# Set log-spaced bin edges from 1 bp to max size
max_val = max(all_sizes) if all_sizes else 100
log_bins = np.logspace(0, np.log10(max_val), 80)

ax.hist(
    [ins_sizes, del_sizes],
    bins=log_bins,
    label=["Insertions", "Deletions"],
    color=["#2b5c8f", "#d95f02"],
    alpha=0.85,
    stacked=False,
)

ax.set_xscale("log")
ax.set_yscale("log")

ax.set_xlabel("Variant Size in Base Pairs (log scale)", fontsize=12, fontweight="bold")
ax.set_ylabel("Variant Frequency Count (log scale)", fontsize=12, fontweight="bold")
ax.set_title(
    f"Pangenome Variant Size Distribution (>= 1 bp)\nTotal Variants = {total_vars:,}",
    fontsize=14,
    fontweight="bold",
    pad=15,
)

ax.grid(True, which="both", linestyle="--", linewidth=0.5, alpha=0.5)
ax.legend(fontsize=11, frameon=True)

# Annotate structural variant cutoff threshold
ax.axvline(x=50, color="black", linestyle=":", linewidth=1.5)
ax.text(
    55,
    ax.get_ylim()[1] * 0.2,
    "SVs (>= 50 bp)",
    rotation=90,
    verticalalignment="center",
    fontsize=10,
    fontweight="bold",
)

plt.tight_layout()
plt.savefig(output_plot)
plt.savefig(output_pdf)
print(f"[*] Plot saved to: {output_plot} and {output_pdf}")