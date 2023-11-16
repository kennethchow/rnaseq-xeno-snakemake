### STAR SNAKEFILE ###
from pathlib import Path

def parse_param(parameter, config):
    param_value = config[parameter]

    if parameter == 'extra':
        return param_value if param_value else ''
    else:
        option = '--' + parameter
        try:
            if str(param_value) == '':
                return ''
            if isinstance(param_value, bool):
                return option if param_value else ''
            else:
                return f'{option} {param_value}'
        except AttributeError:
            return ''

def process_params(config_d):
    return ' '.join([parse_param(param, config_d) for param in config_d.keys() if parse_param(param, config_d)])

def star_2_pass_input(wildcards):
    if config['mode'] == 'xenograft':
        r1 = f'{RESULT_DIR}/02_xengsort/{{sample}}/{{sample}}_cat_1.fq.gz'
        r2 = f'{RESULT_DIR}/02_xengsort/{{sample}}/{{sample}}_cat_2.fq.gz'
        return {'in1':r1, 'in2':r2}
    
    elif config['mode'] == 'rnaseq':
        r1 = DATA_DIR / '{sample}_1.fq.gz'
        r2 = DATA_DIR / '{sample}_2.fq.gz'
        return {'in1':r1, 'in2':r2}

    else:
        raise ValueError('Config mode is not defined correctly.')

def get_mem_mb(wildcards, attempt):
    mem = config['mem_mb']['star']
    
    # Adjust memory based on attempt number
    if attempt == 1:
        return mem
    elif attempt == 2:
        return mem * 1.1
    else:
        return mem * 1.25

c_s2p = config['star_2_pass']
k = config['xengsort']['k']
star_2pass_params = process_params(c_s2p)

rule concat_filtered:
    input:
        graft1=f'{RESULT_DIR}/02_xengsort/{{sample}}/{{sample}}-k{k}-graft.1.fq.gz',
        graft2=f'{RESULT_DIR}/02_xengsort/{{sample}}/{{sample}}-k{k}-graft.2.fq.gz',
        both1=f'{RESULT_DIR}/02_xengsort/{{sample}}/{{sample}}-k{k}-both.1.fq.gz',
        both2=f'{RESULT_DIR}/02_xengsort/{{sample}}/{{sample}}-k{k}-both.2.fq.gz',
    output:
        r1_concat=f'{RESULT_DIR}/02_xengsort/{{sample}}/{{sample}}_cat_1.fq.gz',
        r2_concat=f'{RESULT_DIR}/02_xengsort/{{sample}}/{{sample}}_cat_2.fq.gz',
    log:
        'logs/03_star/{sample}_concat.log'
    shell:
        """
        cat "{input.graft1}" "{input.both1}" > "{output.r1_concat}" ;
        cat "{input.graft2}" "{input.both2}" > "{output.r2_concat}"
        """

rule star_2_pass:
    input: 
        unpack(star_2_pass_input)
    output:
        genome_alignment=RESULT_DIR / '03_star' / '{sample}' / '{sample}.Aligned.sortedByCoord.out.bam',
        transcriptome_alignment=RESULT_DIR / '03_star' / '{sample}' / '{sample}.Aligned.toTranscriptome.out.bam',
    threads: 
        config['threads']['star_2_pass']
    resources:
        mem_mb=get_mem_mb
    params:
        outprefix=f'{RESULT_DIR}/03_star/{{sample}}/{{sample}}.',
        star_index=config['star_index_dir']
    log: 
        'logs/03_star/{sample}.log'
    benchmark: 
        'benchmarks/03_star/{sample}.benchmark'
    shell:
        "STAR "
        "--runMode alignReads "
        "--twopassMode Basic "
        "--runThreadN {threads} "
        "{star_2pass_params} "
        "--readFilesIn {input.in1} {input.in2} "
        "--genomeDir {params.star_index} "
        "--outFileNamePrefix {params.outprefix} &> {log}"
