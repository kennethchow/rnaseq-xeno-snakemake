# Imports and external files
from pathlib import Path

configfile: 'config.yaml'
include: 'rules/fastqc.smk'
include: 'rules/trim-galore.smk'
include: 'rules/xengsort.smk'
include: 'rules/star.smk'
include: 'rules/rsem.smk'
include: 'rules/multiqc.smk'

def result_files():
    output = list()
    
    if config['mode'] == 'xenograft':
        output.extend([
            RAW_FASTQC,
            TRIMMED_FASTQC,
            SORTED_GRAFT_READS,
            SORTED_BOTH_READS,
            ALIGNED_BAM,
            EXPRESSIONS,
            MULTIQC
        ])
    elif config['mode'] == 'rnaseq':
        output.extend([
            RAW_FASTQC,
            ALIGNED_BAM,
            EXPRESSIONS,
            MULTIQC
        ])
    else:
        print('Mode not selected, define mode as xenograft or rnaseq in config.yaml')
    
    return output

# Config variables
RESULT_DIR = Path(config['result_dir'])
k = config['xengsort']['k']

# Generating clean sample file name list
with open(config['samples']) as f:
    SAMPLES = list(set(['_'.join(line.split('.')[0].split('_')[:-1]) for line in f]))

# Defining final output file expansions
RAW_FASTQC = expand(str(RESULT_DIR / '00_fastqc' / '{sample}' / '{sample}_1_fastqc.html'), sample=SAMPLES)
TRIMMED_FASTQC = expand(str(RESULT_DIR / '00_fastqc' / '{sample}' / '{sample}_1_val_1_fastqc.html'), sample=SAMPLES)
SORTED_GRAFT_READS = expand(str(RESULT_DIR / '02_xengsort' / '{sample}' / f'{{sample}}-k{k}-graft.1.fq.gz'), sample=SAMPLES)
SORTED_BOTH_READS = expand(str(RESULT_DIR / '02_xengsort' / '{sample}' / f'{{sample}}-k{k}-both.1.fq.gz'), sample=SAMPLES)
ALIGNED_BAM = expand(str(RESULT_DIR / '03_star' / '{sample}' / '{sample}.Aligned.sortedByCoord.out.bam'), sample=SAMPLES)
EXPRESSIONS = expand(str(RESULT_DIR / '04_rsem' / '{sample}' / '{sample}.genes.results'), sample=SAMPLES)
MULTIQC = RESULT_DIR / '05_multiqc' / 'multiqc_report.html'

RESULT_FILES = result_files()

rule all:
    input: RESULT_FILES
