import os
import argparse
import subprocess
from Bio import SeqIO

def get_args():
    parser = argparse.ArgumentParser(
        description = "Pipeline of all bioinformatics tools", 
        formatter_class = argparse.ArgumentDefaultsHelpFormatter)
    required = parser.add_argument_group("Required arguments")

    required.add_argument("-i", "--input_dir", action="store", 
                          required=True, 
                          help="Path to dir with input fastas")
    
    args = parser.parse_args()
    return args

def validate_directory(directory):
    fasta_files = [f for f in os.listdir(directory) if f.endswith(('.fa', '.fna', '.fasta'))]
    validated_files = []
    for fasta_file in fasta_files:
        fasta_path = os.path.join(directory, fasta_file)
        if validate_fasta_file(fasta_path):
            validated_files.append((fasta_file, fasta_path))
    return validated_files

def validate_fasta_file(fasta_file):
    with open(fasta_file, "r") as handle:
        fasta_content = list(SeqIO.parse(handle, "fasta"))
        if len(fasta_content) >= 1:
            return True
        else:
            print(f"No Records Found in {fasta_file}")
            return False

def run_amrfinder(fasta_file, amrfinder_directory):
    base_name = os.path.splitext(os.path.basename(fasta_file))[0]
    output_file = os.path.join(amrfinder_directory, f"{base_name}_amrfinder.csv")
    subprocess.run(["amrfinder", "-n", fasta_file], stdout=open(output_file, "w"))

def run_plasmidfinder(fasta_file, plasmidfinder_directory):
    output_file = os.path.join(plasmidfinder_directory, "all_results_plasmidfinder.csv")
    subprocess.run(["abricate", "--db", "plasmidfinder", fasta_file], stdout=open(output_file, "a"))


def run_sourmash(fasta_file, sourmash_directory):
    base_name = os.path.splitext(os.path.basename(fasta_file))[0]
    output_file = os.path.join(sourmash_directory, f"{base_name}_signature.sig")
    subprocess.run(["sourmash", "sketch", "dna", "-p", "scaled=1000,k=31", fasta_file, "-o", output_file])
    

def run_mlst(fasta_file, mlst_directory):
    output_file = os.path.join(mlst_directory, "all_mlst_results.csv")
    subprocess.run(["mlst", "--csv", fasta_file], stdout=open(output_file, "a"))
    
def main():
    args = get_args()
    input_dir = args.input_dir
    output_directory = "results"
    os.makedirs(output_directory, exist_ok=True)
    amrfinder_directory = "results/amrfinder"
    os.makedirs(amrfinder_directory, exist_ok=True)
    plasmidfinder_directory = os.path.join(output_directory, "plasmidfinder")
    os.makedirs(plasmidfinder_directory, exist_ok=True)
    sourmash_directory = os.path.join(output_directory, "sourmash")
    os.makedirs(sourmash_directory, exist_ok=True)
    mlst_directory = os.path.join(output_directory, "mlst")
    os.makedirs(mlst_directory, exist_ok=True)

    validated_files = validate_directory(input_dir)

    for fasta_file, fasta_path in validated_files:
        print("running AMRFinder")
        run_amrfinder(fasta_path, amrfinder_directory)
        print("running Plasmidfinder")
        run_plasmidfinder(fasta_path, plasmidfinder_directory)
        print("running Sourmash")
        run_sourmash(fasta_path, sourmash_directory)
        print("running MLST")
        run_mlst(fasta_path, mlst_directory)

if __name__ == "__main__":
    main()