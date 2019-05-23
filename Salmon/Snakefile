# Workflow for Salmon

# Environment: Salmon

configfile: "Salmon.config.json"

rule all:
    input:
        expand(config["Output_File_Directory"]+"{sample}_salmon_quant/", sample=config["Sample_Names"])

rule salmon_quant_paired:
    input:
        Trimmed_FASTQ1 = (config["Trimmed_FastQC_Input_File_Directory"]+"{sample}_trimmomatic_trimmed_paired_1.fastq"),
        Trimmed_FASTQ2 = (config["Trimmed_FastQC_Input_File_Directory"]+"{sample}_trimmomatic_trimmed_paired_2.fastq")
    output:
        (config["Output_File_Directory"]+"{sample}_salmon_quant/")
    params:
        Salmon_Index = config["HG38_Transcriptome_Index_Path"],
        LIBTYPE = "A" # LIBTYPE A for automatic detection of library type
    shell:
        "salmon quant -i {params.Salmon_Index} -l {params.LIBTYPE} -1 {input.Trimmed_FASTQ1} -2 {input.Trimmed_FASTQ2} -o {output}"
