configfile: "Breast_Config.config.json"

SORTED_BAM_AL_DIR = "/data/storage/SAYRES/Isoforms_Breast_Prostate/Data/Breast/GRCh38_sorted_BAM/"
GTF = config["GRCh38_gtf_path"]
GRCh38_StringTie_Transcripts = "/data/storage/SAYRES/Isoforms_Breast_Prostate/Data/Breast/GRCh38_stringtie/"

XX_SAMPLES = config["Sample_Names"]
SAMPLES = XX_SAMPLES

rule all:
	input:
		expand(GRCh38_StringTie_Transcripts + "{sample}/" + "{sample}_Assembled_Transcripts_XX.gtf", GRCh38_StringTie_Transcripts=GRCh38_StringTie_Transcripts, sample=XX_SAMPLES),
		expand(GRCh38_StringTie_Transcripts + "{sample}/" + "{sample}_gene_abund_XX.tab", GRCh38_StringTie_Transcripts=GRCh38_StringTie_Transcripts, sample=XX_SAMPLES),
		expand(GRCh38_StringTie_Transcripts + "{sample}/" + "{sample}_cov_refs_XX.gtf", GRCh38_StringTie_Transcripts=GRCh38_StringTie_Transcripts, sample=XX_SAMPLES)


rule StringTie_Count_Transcripts:
	input:
		BAM = SORTED_BAM_AL_DIR + "{sample}_RNA_XX_HISAT2_GRCh38_sortedbycoord.bam",
		GTF = GTF
	output:
		GTF_out = GRCh38_StringTie_Transcripts + "{sample}/" + "{sample}_Assembled_Transcripts_XX.gtf",
		ABUND = GRCh38_StringTie_Transcripts + "{sample}/" + "{sample}_gene_abund_XX.tab",
		GTF_cov = GRCh38_StringTie_Transcripts + "{sample}/" + "{sample}_cov_refs_XX.gtf"
	params:
		f = 0.1, # Sets the minimum isoform abundance of the predicted transcripts as a fraction of the most abundant transcript assembled at a given locus
		p = 8, # Specify the number of processing threads
		m = 200, # Sets the minimum length allowed for the predicted transcripts
		M = 0.95, # Sets the maximum fraction of muliple-location-mapped reads that are allowed to be present at a given locus
		g = 50 # Minimum locus gap separation value
	message: "Assembling Transcripts from {input.BAM} using StringTie merge mode"
	shell:
		"""
		stringtie {input.BAM} \
		-e \
		-B \
		-f {params.f} \
		-p {params.p} \
		-m {params.m} \
		-M {params.M} \
		-g {params.g} \
		-G {input.GTF} \
		-o {output.GTF_out} \
		-A {output.ABUND} \
		-C {output.GTF_cov}
		"""
