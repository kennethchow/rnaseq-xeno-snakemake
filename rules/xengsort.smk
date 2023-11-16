### XENGSORT SNAKEFILE ###
from pathlib import Path

# Define reference sequence

c = config['xengsort']
k = c['k']
RESULT_DIR = Path(config['result_dir'])
XENG_REF_PATH = Path(config['xeng_ref'])
CDNA_HUMAN = Path(config['xeng_cdna_human'])
CDNA_MOUSE = Path(config['xeng_cdna_mouse'])

rule classify_sample:
    output:
        graft1=RESULT_DIR / '02_xengsort' / '{sample}' / f'{{sample}}-k{k}-graft.1.fq.gz',
        graft2=RESULT_DIR / '02_xengsort' / '{sample}' / f'{{sample}}-k{k}-graft.2.fq.gz',
        both1=RESULT_DIR / '02_xengsort' / '{sample}' / f'{{sample}}-k{k}-both.1.fq.gz',
        both2=RESULT_DIR / '02_xengsort' / '{sample}' / f'{{sample}}-k{k}-both.2.fq.gz',
    input:
        index_info=f"{XENG_REF_PATH}/xengsort-k{k}.info",
        index_hast=f"{XENG_REF_PATH}/xengsort-k{k}.hash",
        in1=RESULT_DIR / '01_trim_galore' / '{sample}' / '{sample}_1_val_1.fq.gz',
        in2=RESULT_DIR / '01_trim_galore' / '{sample}' / '{sample}_2_val_2.fq.gz',
    log:
        "logs/02_xengsort/{sample}.log",
    benchmark:
        "benchmarks/02_xengsort/{sample}.benchmark"
    params:
        index=f"{XENG_REF_PATH}/xengsort-k{k}",
        outprefix=lambda wc: f'{RESULT_DIR}/02_xengsort/{wc.sample}/{wc.sample}-k{k}',
        chunksize=c['cl_chunksize'],
        prefetch=c['cl_prefetch'],
        debug=c['cl_debug'],
    threads:
        config['threads']['classify_sample']
    shell:
        "xengsort {params.debug} classify --out {params.outprefix} --index {params.index} "
        "--threads {threads} --fastq {input.in1} --pairs {input.in2} "
        "--chunksize {params.chunksize} --prefetch {params.prefetch} &> {log}"

rule build_index:
    input:
        cdna_human= CDNA_HUMAN,
        cdna_mouse= CDNA_MOUSE,
    output:
        f"{XENG_REF_PATH}/xengsort-k{k}.info",
        f"{XENG_REF_PATH}/xengsort-k{k}.hash",
    log:
        f"logs/02_xengsort/build_index-k{k}.log",
    benchmark:
        f"benchmarks/02_xengsort/build_index-k{k}.benchmark",
    params:
        index=f"{XENG_REF_PATH}/xengsort-k{k}",
        size=c['id_size'],
        fill=c['id_fill'],
        subtables=c['id_subtables'],
        weakthreads=c['id_weakthreads'],
        bucketsize=c['id_bucketsize'],
        hashfuncs=c['id_hashfuncs'],
        debug=c['id_debug'],
    threads:
        config['threads']['build_index']
    shell:
        "xengsort {params.debug} index  --index {params.index} "
        "-G {input.cdna_human}"
        " -H {input.cdna_mouse}"
        " -k {k} -n {params.size} "
        " -p {params.bucketsize} --fill {params.fill} -W {params.weakthreads} &> {log}"
