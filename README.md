# Pipeline for Antimicrobial Resistance Surveillance
This is a tool which integrates 4 different bioinformatics tools (Sourmash, MLST, AMRFinder, and ABRicate (specifically the PlasmidFinder Database))

Each of these tools have documentation, which can be found in the below links:
- Sourmash: https://sourmash.readthedocs.io/en/latest/
- MLST: https://github.com/tseemann/mlst
- AMRFinderPlus: https://github.com/ncbi/amr/wiki
- ABRicate: https://github.com/tseemann/abricate

Python will also be required on the device that you are using and download instructions can be found at the following link:
https://www.python.org

Simply go to the above link and click on the **downloads** section, and download for your system (MacOS/Windows/etc.)

---

# How to Use the Pipeline
In order to enter any fasta file into the pipeline, the tools above must be downloaded. The download instructions are found in the documentation listed above.
Assuming you have python on your system, use the following command to use the pipeline.

`python <path>/pipeline_ver2.py -i <path_to_directory_with_fasta_files>`

Alternatively, `--input_dir` can be used as opposed to `-i`

Also note that the path **must** be specified for both the downloaded pipeline and the path to the directory containing the input fasta files
