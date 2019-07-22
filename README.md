# Androden receptor positive and negative breast and prostate cancers
Here we outline the analyses and codes used to study androgen receptor (AR) positive and negative breast cancers and prostate cancer. 

## Step 1: Quality Control and Trimming
First, we checked the quality of the samples and then trimmed low-quality reads. The specified environment file, configuration file, Snakefile, and bash script are provided under the folder "`QC_Trimmomatic`". 

### Set up our environment 
Since this step uses a variety of programs, we set up a conda environment to manage all necessary packages and programs.

### Installed Anaconda or Miniconda
First, we installed Anaconda or Miniconda. We referred  Conda's documentation for steps on how to install conda. See: https://conda.io/docs/index.html

### Created the environment
We named this environment 'QC_Trimmomatic'.

Create conda environment called `QC_Trimmomatic`:
```
`conda env create --name QC_Trimmomatic --file QC_Trimmomatic_environment.yaml`
```

We activated the environment when running scripts or commands and deactivated the environment when we were done. 

To activate the `QC_Trimmomatic` environment: \
`source activate QC_Trimmomatic` 

To deactivate the `QC_Trimmomatic` environment: \
`source deactivate QC_Trimmomatic`

### Created the configuration file for the Snakefile
Associated with the Snakefile is a configuration file in json format. This file has multiple pieces of information needed to run the Snakefile. Our configuration file has a file index specified at the bottom to help locate the files.

The config file is named `QC_Trimmomatic.config.json` and is located in this folder. See below for details. We also provide an example our configuration file below:

`QC_Trimmomatic.config.json:`
```
{
  	"Comment_Directories_to_FASTQ_Files": "This section sepcifies directories to the 
	 input and output files",
  	"Directory_to_FASTQ_Files": "/mnt/storage/DATASETS/INVESTOR_DATA/BUETOW/BRCA/",
  	"FastQC_File_Output_Directory": 
		"/mnt/storage/SAYRES/Isoforms_Breast_Prostate/DATA/BREAST/fastqc/",
  	"Trimmed_FastQC_File_Output_Directory": 
		"/mnt/storage/SAYRES/Isoforms_Breast_Prostate/DATA/BREAST/trimmed_fastqc/",
  	"Adapter_FASTA": "/mnt/storage/CANCER_DOWNLOADS/PROCESSED/adapter_sequences.fa",

	"Sample_Names": ["TCGA-3C-AAAU-01A-11R-A41B-07",...,"TCGA-3C-AALI-01A-11R-A41B-07"],

	"Comment_Sample_Dictionary": "This section provides the dictionary for the samples",
	"Breast_Sample_Names":
  	{
    "TCGA-3C-AAAU-01A-11R-A41B-07": {
      "File_ID": "1cbcd09f-2824-4e99-b657-f9565e9c9372",
      "File_Name": "140821_UNC11-SN627_0377_BC5ERUACXX_ACTTGA_L003"
    	}, 
		...
	},
	
	"Prostate_Sample_Names":
  	{
    "TCGA-2A-A8VL-01A-21R-A37L-07": {
      "File_ID": "8bac314b-c994-40f7-83ca-8b8f6748967a",
      "File_Name": "140502_UNC12-SN629_0366_AC3UT1ACXX_TAGCTT_L003"
   	}
		...
	} 
}
```

### Created the Snakefile that will run FastQC, MultiQC, and Trimmomatic
We created a Snakefile that ran FastQC, MultiQC, Trimmomatic, then FastQC and MultiQC once again on the file. We provide the Snakefile in this folder. The commands were as followed:

#### FastQC
This rule will run the first pass of fastqc analysis.
```
`fastqc -o {output_directory} {FASTQ1} {FASTQ2}`
```

#### MultiQC
This rule runs multiqc to create a multiqc report.
```
`multiqc {output_directory}*_fastqc.zip --outdir {output_directory} --interactive --verbose`
```

#### Trimmomatic
For running Trimmomatic, we using the following parameters:
```
`SPECIFIED PARAMETERS:
	threads = 4,
	seed_mismatches = 2,
	palindrome_clip_threshold = 30,
	simple_clip_threshold = 10,
	leading = 10,
	trailing = 10,
	winsize = 4,
	winqual = 15,
	minlen = 48`
```
	
This rule will run trimmomatic on the fastq files to get trimmed and paired output files.
```
`trimmomatic PE -threads {params.threads} -phred33 -trimlog {output.Log_File} \
{FASTQ1} {FASTQ2} {output.Paired_1} {output.Unpaired_1} \
{output.Paired_2} {output.Unpaired_2} \
ILLUMINACLIP:{input.Adapter_FASTA}:{params.seed_mismatches}:
{params.palindrome_clip_threshold}:{params.simple_clip_threshold} \
LEADING:{params.leading} TRAILING:{params.trailing} \
SLIDINGWINDOW:{params.winsize}:{params.winqual} MINLEN:{params.minlen}`
```

#### FastQC
This rule will run the second pass of fastqc analysis using the trimmed and paired fastq files generated after running trimmomatic.
```
`fastqc -o {output_directory} {FASTQ1} {FASTQ2}`
```

#### MultiQC
This rule runs multiqc to create a multiqc report for the trimmed and paired fastq files generated after running trimmomatic.
```
`multiqc {output_directory}*_fastqc.zip --outdir {output_directory} --interactive --verbose`
```
          
### Run the script
With our server, we chose to use an sbatch script to run PopInf. This script is provided in this folder.
```
`sbatch run_QC_Trimmomatic_snakefile.sh`
```
         
## Step 2: Alignment and Quantification
We first assured that all files were present from the quality control step. After doing so, we proceeded with the alignment and quantification of the samples. All environment files, configuration files, Snakefiles, and bash scripts are available under the folders "HISAT" and "StringTie".

### Set up and create the environment
Similar to the quality control step, we set up and created an environment
```
`conda env create --name cancer_alignment --file rnaseq_alignment_environment.yaml`
```
We activated this environment while running the alignment and quantification steps, and deactivated it when we were finished
To activate the environment: 
```
source activate cancer_alignment
```
To deactivate the environment: 
```
conda deactivate cancer_alignment
```

### Created the configuration file for the Snakefile
Again, just like in the quality control step, we set up a config file in the .json format to establish a dictionary with definitions for the samples being aligned. Additionally, it provided the pathways to the reference genomes. This is the config file for the Prostate samples, there is another config file utilized for the breast samples in the "HISAT" directory.
```
{
  "Commment_Input_Output_Directories": "The following section specifies the input and output directories for the files to be used in the script",
  "Trimmed_FastQC_Input_File_Directory": "/mnt/storage/SAYRES/Isoforms_Breast_Prostate/Data/Prostate/trimmed_fastqc/",

"XX_GRCh38_ref_path": "/mnt/storage/SAYRES/XY_Trim_Ref/references/gencode.GRCh38.p7_Ymasked/GRCh38_Ymasked_reference.fa",
    "XX_GRCh38_ref_prefix": "XX_GRCh38",
    "XX_GRCh38_ref_with_viral_genomes": "/home/hnatri/eQTL/GRCh38_Ymasked_reference_viral.fa",
    "XX_GRCh38_ref_with_viral_genomes_HISAT2_index": "/mnt/storage/CANCER_DOWNLOADS/PROCESSED/HISAT2_indices/XX_hg38_HISAT2_index/XX_hg38_viral",
    "XY_GRCh38_ref_path": "/mnt/storage/SAYRES/REFERENCE_GENOMES/UCSC_hg38/hg38.fa",
    "XY_GRCh38_ref_prefix": "GRCh38",
    "XY_GRCh38_ref_with_viral_genomes": "/home/hnatri/eQTL/GRCh38_wholegenome_reference_viral.fa",
    "XY_GRCh38_ref_with_viral_genome_HISAT2_index": "mnt/storage/CANCER_DOWNLOADS/PROCESSED/HISAT2_indices/XY_hg38_HISAT2_index/XY_hg38_viral",
    "XY_withoutYpar_GRCh38_ref_path": "/mnt/storage/SAYRES/XY_Trim_Ref/references/gencode.GRCh38.p7_minusYPARs/GRCh38_minusYPARs_reference.fa",
    "XY_withoutYpar_GRCh38_ref_with_viral_genomes": "/home/hnatri/eQTL/GRCh38_minusYpar_reference_viral.fa",
    "XY_withoutYpar_GRCh38_ref_prefix": "XY_withoutYpar_GRCh38",
    "XY_withoutYpar_GRCh38_ref_with_viral_genomes_HISAT2_index": "/mnt/storage/CANCER_DOWNLOADS/PROCESSED/HISAT2_indices/XY_withoutYpar_hg38_HISAT2_index/XY_withoutYpar_hg38_viral",
    "GRCh38_gtf_path": "/mnt/storage/SAYRES/XY_Trim_Ref/references/gencode.GRCh38.p7_wholeGenome/gencode.v25.chr_patch_hapl_scaff.annotation.gtf",
    "GRCh38_gtf_withoutXY_path": "/mnt/storage/CANCER_DOWNLOADS/PROCESSED/GTFs/gencode.v25.chr_patch_hapl_scaff.annotation.withoutxy.gtf",
    "GRCh38_proteincoding_gtf_path": "/mnt/storage/CANCER_DOWNLOADS/PROCESSED/GTFs/gencode.v25.chr_patch_hapl_scaff.annotation.proteincoding.gtf",
    "GRCh37_lite_ref_path": "/home/hnatri/eQTL/GRCh37-lite.fa",
    "GRCh37_lite_ref_prefix": "GRCh37-lite",
    "GRCh38_ref_index_path": "/mnt/storage/SAYRES/XY_Trim_Ref/references/gencode.GRCh38.p7_wholeGenome/GRCh38_wholeGenome_reference.fa.fai",
    "GRCh38_ref_path": "/mnt/storage/SAYRES/XY_Trim_Ref/references/gencode.GRCh38.p7_wholeGenome/GRCh38_wholeGenome_reference.fa",
    "GRCh38_ref_prefix": "GRCh38",

  "Comment_Sample_Info": "The following section lists the samples that are to be analyzed",
  "Sample_Names": ["TCGA-3C-AALJ-01A-31R-A41B-07",...,"TCGA-OL-A97C-01A-32R-A41B-07"]

} 
```
### Creating snakefile for alignment and quanitification
We created a snakefile that aligns with HISAT2, outputs SAM, then output BAM, indexes those BAM files, then quantifies the reads with Subread featureCounts. The necessary files are provided in the "HISAT" folder. The commands are as follows:

### HISAT2
We aligned the samples with HISAT2 to the reference genome and output SAM files.
```
hisat2 -q --phred33 --dta -p {params.threads} -x {params.hisat2_index} -s no -1 {input.fq1} -2 {input.fq2} -S {output.SAM}
```

### SAM to BAM
This command will convert the SAM files to BAM files, only outputting mapped reads.
```
samtools view -b -F 4 {input.SAM} > {output.BAM}
```

### Sorting BAM
This command will sort the BAM files.
```
samtools sort -O bam -o {output.SORTED_BAM} {input.BAM}
```

### Indexing BAM
This command will index the BAM files.
```
samtools index {input.BAM}
```

### Quantifying with Subread featureCounts
Quantifying gene read counts from BAM file with Subread featureCounts
```
featureCounts -T {params.THREADS} --primary -p -s 0 -t gene -g gene_name -a {input.GTF} -o {output.COUNTS} {input.BAM}
```

### Run the script
We made a bash script to run the snakefile on the cluster. The file can be found in the "HISAT" folder. It was run with the following command:
```
sbatch TCGA_Breast_Cancer_run_alignment_snakemake.sh
```
