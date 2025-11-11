# VEP PASS Filtering Enhancement

## Overview

This enhancement adds automatic PASS filtering to VEP-annotated VCF files in the Sarek pipeline. After VEP annotation, variants are automatically filtered to retain only those with `PASS` status in the FILTER column.

## Changes Made

### 1. New Module: `modules/local/bcftools_filter_pass`

A new local module that uses BCFtools view to filter VCF files:
- **Input**: VEP-annotated VCF file with index
- **Output**: Filtered VCF file containing only PASS variants
- **Tool**: BCFtools view with `--apply-filters PASS`
- **Location**: Published to `annotation/{variantcaller}/{sample}/filtered/` subdirectory

### 2. Modified Subworkflow: `subworkflows/local/vcf_annotate_all/main.nf`

Enhanced VCF annotation workflow to include PASS filtering:
- Added BCFTOOLS_FILTER_PASS module import
- Integrated filtering step after VEP annotation
- Filtered VCFs replace unfiltered ones in the main annotation output channel
- Preserves all other annotation outputs (HTML reports, TAB, JSON)

### 3. Publishing Configuration: `conf/modules/annotate.config`

Added configuration for the new filtering module:
- Custom prefix: `${meta.id}_VEP.ann`
- Output directory: `annotation/${meta.variantcaller}/${meta.id}/filtered/`
- Pattern: `*{filtered.vcf.gz,filtered.vcf.gz.tbi}`
- Only activated when `vep` tool is selected

### 4. Tests

#### Module Tests
- **Location**: `modules/local/bcftools_filter_pass/tests/main.nf.test`
- **Test data**: SARSCOV2 test VCF from nf-core test datasets
- **Validation**: Process success and output snapshot comparison

#### Pipeline Tests
- **Location**: `tests/annotation_vep.nf.test`
- **Test case**: "Test VEP annotation with PASS filtering functionality"
- **Validation**: Confirms BCFTOOLS_FILTER_PASS process is executed

## Usage

The filtering is automatically applied when using VEP annotation. No additional parameters are required:

```bash
nextflow run nf-core/sarek \
    --input samplesheet.csv \
    --genome GRCh38 \
    --step annotate \
    --tools vep \
    --vep_cache /path/to/vep_cache
```

## Output Structure

After VEP annotation with filtering, the output directory structure will be:

```
annotation/
├── {variantcaller}/
│   └── {sample}/
│       ├── {sample}_VEP.ann.vcf.gz          # Original VEP annotated (unfiltered)
│       ├── {sample}_VEP.ann.vcf.gz.tbi      # Index for original
│       └── filtered/                         # New filtered subdirectory
│           ├── {sample}_VEP.ann.filtered.vcf.gz     # PASS-only variants
│           └── {sample}_VEP.ann.filtered.vcf.gz.tbi # Index for filtered
```

## Benefits

1. **Quality Control**: Automatically removes low-quality variants
2. **Focused Analysis**: Streamlines downstream analysis on high-confidence variants  
3. **Organized Output**: Clear separation between filtered and unfiltered results
4. **Backward Compatibility**: Original VEP outputs are preserved
5. **Minimal Configuration**: No additional parameters required
6. **Pipeline Integration**: Seamlessly integrated into existing VEP workflow

## Dependencies

- BCFtools (included in existing Sarek environments)
- No additional software installations required

## Future Enhancements

Potential improvements could include:
- Configurable filter criteria beyond PASS
- Additional quality metrics filtering
- Integration with other annotation tools (SNPEff, merge mode)
- Custom filter expression support