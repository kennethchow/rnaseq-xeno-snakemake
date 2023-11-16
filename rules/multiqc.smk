### MULTIQC SNAKEFILE ###
from pathlib import Path

RESULT_DIR = Path(config['result_dir'])

with open(config['samples']) as f:
    SAMPLES = list(set(['_'.join(Path(line).stem.split('_')[:-1]) for line in f]))

rule multiqc:
    input:
        fastqc_html=expand(RESULT_DIR / '00_fastqc' / '{sample}' / '{sample}_1_fastqc.html', sample=SAMPLES)
    output:
        report=RESULT_DIR / '05_multiqc' / 'multiqc_report.html'
    threads:
        config['threads']['multiqc']
    params:
        outdir=RESULT_DIR / '05_multiqc',
        outname='multiqc_report.html'
    log:
        'logs/05_multiqc/multiqc.log'
    shell:
        'mkdir -p {params.outdir} && multiqc {RESULT_DIR} --force '
        '--outdir {params.outdir} --filename {output.report} &> {log}'
