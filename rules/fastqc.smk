### FASTQC SNAKEFILE ###
from pathlib import Path

DATA_DIR = Path(config['data_dir'])
RESULT_DIR = Path(config['result_dir'])

rule fastqc_raw:
    input:
        r1 = DATA_DIR / '{sample}_1.fq.gz',
        r2 = DATA_DIR / '{sample}_2.fq.gz',
    output:
        html = RESULT_DIR / '00_fastqc' / '{sample}' / '{sample}_1_fastqc.html',
        zip = RESULT_DIR / '00_fastqc' / '{sample}' / '{sample}_1_fastqc.zip',
    threads: 
        config['threads']['fastqc_raw']
    params:
        outprefix = f'{RESULT_DIR}/00_fastqc/{{sample}}'
    log:
        "logs/00_fastqc/{sample}.log"
    benchmark:
        'benchmarks/00_fastqc/{sample}.benchmark'
    shell:
        'mkdir -p {params.outprefix} && fastqc {input.r1} {input.r2} '
        '--threads {threads} '
        '--outdir {params.outprefix} '
        '--extract '
        '--format fastq '  
        '--dir {params.outprefix} &> {log}'

rule fastqc_trimmed:
    input:
        r1 = RESULT_DIR / '01_trim_galore' / '{sample}' / '{sample}_1_val_1.fq.gz',
        r2 = RESULT_DIR / '01_trim_galore' / '{sample}' / '{sample}_2_val_2.fq.gz',
    output:
        html = RESULT_DIR / '00_fastqc' / '{sample}' / '{sample}_1_val_1_fastqc.html',
        zip = RESULT_DIR / '00_fastqc' / '{sample}' / '{sample}_1_val_1_fastqc.zip',
    threads: 
        config['threads']['fastqc_trimmed']
    params:
        outprefix = f'{RESULT_DIR}/00_fastqc/{{sample}}'
    log:
        "logs/00_fastqc/{sample}.log"
    benchmark:
        "benchmarks/00_fastqc/{sample}.benchmark"
    shell:
        'mkdir -p {params.outprefix} && fastqc {input.r1} {input.r2} '
        '--threads {threads} '
        '--outdir {params.outprefix} '
        '--extract '
        '--format fastq '  
        '--dir {params.outprefix} &> {log}'