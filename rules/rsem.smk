### RSEM SNAKEFILE ###
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

c = config['rsem_calculate_expression']
rsem_params = process_params(c)

rule rsem_calculate_expression:
    input:
        aligned_bam = RESULT_DIR / '03_star' / '{sample}' / '{sample}.Aligned.toTranscriptome.out.bam'
    output:
        genes = RESULT_DIR / '04_rsem' / '{sample}' / '{sample}.genes.results',
        isoforms = RESULT_DIR / '04_rsem' / '{sample}' / '{sample}.isoforms.results'
    params:
        output_prefix = f'{RESULT_DIR}/04_rsem/{{sample}}/{{sample}}',
        rsem_ref = config['rsem_reference']
    threads: 
        config['threads']['rsem_calculate_expression']
    log: 
        'logs/04_rsem_calculate_expression/{sample}.log'
    benchmark: 
        'benchmarks/04_rsem_calculate_expression/{sample}.benchmark'
    shell:
        "rsem-calculate-expression "
        "{rsem_params} "
        "-p {threads} "
        "{input.aligned_bam} "
        "{params.rsem_ref} "
        "{params.output_prefix} &> {log}"

