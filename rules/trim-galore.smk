### TRIM-GALORE SNAKEFILE ###
from pathlib import Path

def parse_param(parameter, param_value):
    # Returns formatted parameter per trim-galore param
    if parameter == '':
        return ''

    elif parameter == 'e':
        try:
            return '-e ' + str(param_value) if str(param_value) != '' else ''
        except AttributeError:
            return ''
    
    elif parameter == 'extra':
        return param_value
    
    else:
        option = '--' + parameter
        try:
            if str(param_value) == '':
                return ''
            
            if type(param_value) == bool:
                return option if param_value else ''
            else:
                return f'{option} {param_value}'
        
        except AttributeError:
            return ''

def process_params_trim(c):
    # Retrieves all formatted params and returns params string for input into shell command
    user_params = [parse_param(parameter=param, param_value=c[param]) for param in c.keys()]
    return ' '.join([p for p in user_params if p != ''])

c = config['trim_galore']
trim_params = process_params_trim(c)

rule trim_galore:
    input:
        r1=DATA_DIR / '{sample}_1.fq.gz',
        r2=DATA_DIR / '{sample}_2.fq.gz'
    output:
        r1_trim=temp(RESULT_DIR / '01_trim_galore' / '{sample}' / '{sample}_1_val_1.fq.gz'),
        r2_trim=temp(RESULT_DIR / '01_trim_galore' / '{sample}' / '{sample}_2_val_2.fq.gz')

    threads: config['threads']['trim_galore']
    params:
        outprefix=f'{RESULT_DIR}/01_trim_galore/{{sample}}'
    log: 
        'logs/01_trim_galore/{sample}.log'
    benchmark: 
        'benchmarks/01_trim_galore/{sample}.benchmark'
    shell:
        'mkdir -p {params.outprefix} && trim_galore {trim_params} '
        '--cores {threads} '
        '--paired '
        '--output_dir {params.outprefix} '
        '{input.r1} '
        '{input.r2} &> {log}'
