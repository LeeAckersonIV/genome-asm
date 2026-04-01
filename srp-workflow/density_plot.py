import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import sys
import os

def generate_joint_plot(input_file, output_file, lib_name):
    # Load SeqKit TSV
    # Expected columns: 'name', 'length', 'avg_qual'
    df = pd.read_table(input_file)
    
    # Ensure numeric types
    df['length'] = pd.to_numeric(df['length'])
    df['avg.qual'] = pd.to_numeric(df['avg.qual'])

    # Set the visual style
    sns.set_theme(style="ticks")
    
    # Create the JointPlot
    # kind="hist" creates the 2D heatmap/density look
    g = sns.jointplot(
        data=df, 
        x="length", 
        y="avg.qual", 
        kind="hist", 
        bins=100,
        cmap="Blues",
        cbar=True,
        cbar_kws={'label': 'Read Count (Density)'}
    )

    # Set Labels
    g.set_axis_labels('Read Length (bp)', 'Predicted Read Quality (Phred scale)', fontsize=12)
    g.fig.suptitle(f'Library: {lib_name}', y=1.02, fontsize=14)

    # Tight layout and save
    plt.savefig(output_file, dpi=300, bbox_inches='tight')
    plt.close()

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python3 plot_joint_qc.py <input.tsv> <output.png> <lib_name>")
    else:
        generate_joint_plot(sys.argv[1], sys.argv[2], sys.argv[3])