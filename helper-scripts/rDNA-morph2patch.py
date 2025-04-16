# this script takes in an input.fasta file (ribotin rDNA morph), and a CNV estimate (Conkord median haplotype copy number)
# the script then outputs an output.fasta file that has the morph*CNV sequence (the patch sequence to feed to verkko)
# example usage: python rDNA-morphtpatch.py input.fasta output.fasta 110

import argparse

def replicate_fasta(input_file, output_file, copies):
    # read input file header and sequence
    with open(input_file) as f:
        header = f.readline().strip()
        sequence = f.readline().strip()

    # print input params to shell
    print("\n")
    print(f"Input FASTA file: {input_file}")
    print(f"Output FASTA file: {output_file}")
    print(f"Number of copies: {copies}")
    print(f"Length of input sequence (stripped): {len(sequence)}")

    # Repeat sequence `copies` times
    repeated_sequence = sequence * copies

    # write to output file as exactly two lines
    with open(output_file, "w") as f:
        f.write(f"{header}\n{repeated_sequence}\n")

    # print length of output sequence - sanity check
    print(f"Length of output sequence (stripped): {len(repeated_sequence)}")
    print("\n")
    

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Replicate a FASTA sequence a given number of times.")
    parser.add_argument("input_fasta", help="Input FASTA file")
    parser.add_argument("output_fasta", help="Output FASTA file")
    parser.add_argument("copies", type=int, help="Number of times to repeat the sequence")
    
    args = parser.parse_args()
    replicate_fasta(args.input_fasta, args.output_fasta, args.copies)
