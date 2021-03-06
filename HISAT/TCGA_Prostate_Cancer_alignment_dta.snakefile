# Workflow for aligning RNA sequence data to a sex specific reference with
# HISAT2, sorting and indexing BAM files with Samtools, and quantifying
# read counts with Subread featureCounts.

configfile: "TCGA_Config.config.json"

# Tools
HISAT2 = "hisat2"
SAMTOOLS = "samtools"
FEATURECOUNTS = "featureCounts"

# Reference genome files: XX with Y chromosome masked, XY with Y PAR regions masked
XX_HISAT2_INDEX_WITH_VIRAL_REF = config["XX_GRCh38_ref_with_viral_genomes_HISAT2_index"]
XY_HISAT2_INDEX_WITH_VIRAL_REF = config["XY_withoutYpar_GRCh38_ref_with_viral_genomes_HISAT2_index"]
GTF = config["GRCh38_gtf_path"]
GTF_PROTEINCODING = config["GRCh38_proteincoding_gtf_path"]
GTF_AUTOSOMAL = config["GRCh38_gtf_withoutXY_path"]

# Directories
FQ_DIR = "/data/storage/SAYRES/Isoforms_Breast_Prostate/Data/Prostate/trimmed_fastqc/" # path to directory with fastq files
SAM_AL_DIR = "/data/storage/SAYRES/Isoforms_Breast_Prostate/Data/Prostate/GRCh38_SAM_dta/" # path to directory for SAM alignment files
BAM_AL_DIR = "/data/storage/SAYRES/Isoforms_Breast_Prostate/Data/Prostate/GRCh38_BAM_dta/" # path to directory for BAM alignment files
SORTED_BAM_AL_DIR = "/data/storage/SAYRES/Isoforms_Breast_Prostate/Data/Prostate/GRCh38_sorted_BAM_dta/" # path to directory for sorted BAM alignment files
FEATURECOUNTS_DIR = "/data/storage/SAYRES/Isoforms_Breast_Prostate/Data/Prostate/GRCh38_featurecounts_dta/" # path to directory for FeatureCounts gene count files


# Samples
XX_SAMPLES = config["Sample_Names"]


rule all:
	input:
		# Defining the files that snakemake will attempt to produce as an output.
		# If there is no rule defined to produce the file, or if the file already
		# exists, snakemake will throw "Nothing to be done"
		expand(SAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_dta.sam", SAM_AL_DIR=SAM_AL_DIR, sample=XX_SAMPLES),
		expand(BAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_dta.bam", BAM_AL_DIR=BAM_AL_DIR, sample=XX_SAMPLES),
		expand(SORTED_BAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_sortedbycoord_dta.bam", SORTED_BAM_AL_DIR=SORTED_BAM_AL_DIR, sample=XX_SAMPLES),
		expand(SORTED_BAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_sortedbycoord_dta.bam.bai", SORTED_BAM_AL_DIR=SORTED_BAM_AL_DIR, sample=XX_SAMPLES),
#		expand(FEATURECOUNTS_DIR + "{sample}_RNA_XX_HISAT2_transcript_featurecounts_dta.tsv", FEATURECOUNTS_DIR=FEATURECOUNTS_DIR, sample=XX_SAMPLES),
		expand(FEATURECOUNTS_DIR + "{sample}_RNA_XX_HISAT2_gene_featurecounts_dta.tsv", FEATURECOUNTS_DIR=FEATURECOUNTS_DIR, sample=XX_SAMPLES),
		expand(FEATURECOUNTS_DIR + "{sample}_RNA_XX_HISAT2_gene_autosomal_featurecounts_dta.tsv", FEATURECOUNTS_DIR=FEATURECOUNTS_DIR, sample=XX_SAMPLES),
#		expand(FEATURECOUNTS_DIR + "{sample}_RNA_XX_HISAT2_transcript_featurecounts_dta.tsv", FEATURECOUNTS_DIR=FEATURECOUNTS_DIR, sample=XX_SAMPLES),
#		expand(FEATURECOUNTS_DIR + "{sample}_RNA_XX_HISAT2_transcript_proteincoding_featurecounts_dta.tsv", FEATURECOUNTS_DIR=FEATURECOUNTS_DIR, sample=XX_SAMPLES)
		


rule hisat2_align_reads:
	input:
		fq1 = FQ_DIR + "{sample}_trimmomatic_trimmed_paired_1.fastq",
		fq2 = FQ_DIR + "{sample}_trimmomatic_trimmed_paired_2.fastq"
	output:
		SAM = SAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_dta.sam"
	params:
		hisat2_index = XX_HISAT2_INDEX_WITH_VIRAL_REF,
		threads = 8
	message: "Mapping {wildcards.sample} reads to {params.hisat2_index} with HISAT2."
	shell:
		"""
		hisat2 -q --phred33 --dta -p {params.threads} -x {params.hisat2_index} -s no -1 {input.fq1} -2 {input.fq2} -S {output.SAM}
		"""

rule sam_to_bam:
	input:
		SAM = SAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_dta.sam"
	output:
		BAM = BAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_dta.bam"
	params:
	message: "Converting {input.SAM} to BAM, only outputting mapped reads."
	shell:
		"""
		samtools view -b -F 4 {input.SAM} > {output.BAM}
		"""

rule sort_bam:
	input:
		BAM = BAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_dta.bam"
	output:
		SORTED_BAM = SORTED_BAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_sortedbycoord_dta.bam"
	params:
	message: "Sorting BAM file {input.BAM}"
	shell:
		"""
		samtools sort -O bam -o {output.SORTED_BAM} {input.BAM}
		"""

rule index_bam:
	input:
		BAM = SORTED_BAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_sortedbycoord_dta.bam"
	output: SORTED_BAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_sortedbycoord_dta.bam.bai"
	message: "Indexing BAM file {input.BAM} with Samtools."
	params:
	shell:
		"""
		samtools index {input.BAM}
		"""

rule featurecounts_gene:
	input:
		BAM = SORTED_BAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_sortedbycoord_dta.bam",
		GTF = GTF
	output:
		COUNTS = FEATURECOUNTS_DIR + "{sample}_RNA_XX_HISAT2_gene_featurecounts_dta.tsv"
	params:
		THREADS = 5
	message: "Quantifying gene read counts from BAM file {input.BAM} with Subread featureCounts"
	shell:
		"""
		featureCounts -T {params.THREADS} --primary -p -s 0 -t gene -g gene_name -a {input.GTF} -o {output.COUNTS} {input.BAM}
		"""

rule featurecounts_gene_autosomal:
	input:
		BAM = SORTED_BAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_sortedbycoord_dta.bam",
		GTF = GTF_AUTOSOMAL
	output:
		COUNTS = FEATURECOUNTS_DIR + "{sample}_RNA_XX_HISAT2_gene_autosomal_featurecounts_dta.tsv"
	params:
		THREADS = 5
	message: "Quantifying autosomal gene read counts from BAM file {input.BAM} with Subread featureCounts"
	shell:
		"""
		featureCounts -T {params.THREADS} --primary -p -s 0 -t gene -g gene_name -a {input.GTF} -o {output.COUNTS} {input.BAM}
		"""

#rule featurecounts_transcript:
#	input:
#		BAM = SORTED_BAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_sortedbycoord_dta.bam",
#		GTF = GTF
#	output:
#		COUNTS = FEATURECOUNTS_DIR + "{sample}_RNA_XX_HISAT2_transcript_featurecounts_dta.tsv"
#	params:
#		THREADS = 5
#	message: "Quantifying transcript read counts from BAM file {input.BAM} with Subread featureCounts"
#	shell:
#		"""
#		featureCounts -T {params.THREADS} --primary -p -s 0 -t transcript -g transcript_name -a {input.GTF} -o {output.COUNTS} {input.BAM}
#		"""

#rule featurecounts_transcript_proteincoding:
#	input:
#		BAM = SORTED_BAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_sortedbycoord_dta.bam",
#		GTF = GTF_PROTEINCODING
#	output:
#		COUNTS = FEATURECOUNTS_DIR + "{sample}_RNA_XX_HISAT2_transcript_proteincoding_featurecounts_dta.tsv"
#	params:
#		THREADS = 5
#	message: "Quantifying protein coding transript read counts from BAM file {input.BAM} with Subread featureCounts"
#	shell:
#		"""
#		featureCounts -T {params.THREADS} --primary -p -s 0 -t transcript -g transcript_name -a {input.GTF} -o {output.COUNTS} {input.BAM}
#		"""
