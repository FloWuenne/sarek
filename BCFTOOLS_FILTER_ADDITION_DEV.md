# BCFtools Filter Addition to Sarek Pipeline (Dev Branch)

## Summary

This update adds bcftools filter functionality to the Sarek pipeline (dev branch) to filter annotated VCF files by PASS variants after VEP annotation.

## Branch Information

- **Base Branch:** `dev` (version 3.7.0dev)
- **Feature Branch:** `seqera-ai/20241218-161932-add-bcftools-filter-vep-dev`
- **Created From:** Latest dev branch commit (SHA: 42283534)

## Changes Made

### 1. Module Installation
- Installed `bcftools/filter` module from nf-core/modules using `nf-core modules install bcftools/filter`

### 2. Subworkflow Modifications (`subworkflows/local/vcf_annotate_all/main.nf`)

**Includes Added:**
```groovy
include { BCFTOOLS_FILTER as BCFTOOLS_FILTER_VEP        } from '../../../modules/nf-core/bcftools/filter'
include { BCFTOOLS_FILTER as BCFTOOLS_FILTER_MERGE      } from '../../../modules/nf-core/bcftools/filter'
```

**VEP Workflow Integration:**
- Added bcftools filter step after VEP annotation to filter variants by PASS status
- Uses alias `BCFTOOLS_FILTER_VEP` to avoid conflicts

**Merge Workflow Integration:**
- Added bcftools filter step after snpEff + VEP merge annotation
- Uses alias `BCFTOOLS_FILTER_MERGE` for the merge scenario

### 3. Configuration Updates (`conf/modules/annotate.config`)

**BCFTOOLS_FILTER_VEP Configuration:**
```groovy
withName: 'NFCORE_SAREK:SAREK:VCF_ANNOTATE_ALL:BCFTOOLS_FILTER_VEP' {
    ext.args   = { '--include \'FILTER="PASS"\' --output-type z --write-index=tbi' }
    ext.prefix = { meta.variantcaller.contains('haplotypecaller') ? "${meta.id}.filtered" : "${meta.variantcaller}_${meta.id}.filtered" }
    publishDir = [
        mode: params.publish_dir_mode,
        path: { "${params.outdir}/annotation/${meta.variantcaller}/${meta.id}/filtered/" },
        pattern: "*{vcf.gz,vcf.gz.tbi}"
    ]
}
```

**BCFTOOLS_FILTER_MERGE Configuration:**
```groovy
withName: 'NFCORE_SAREK:SAREK:VCF_ANNOTATE_ALL:BCFTOOLS_FILTER_MERGE' {
    ext.args   = { '--include \'FILTER="PASS"\' --output-type z --write-index=tbi' }
    ext.prefix = { meta.variantcaller.contains('haplotypecaller') ? "${meta.id}.filtered" : "${meta.variantcaller}_${meta.id}.filtered" }
    publishDir = [
        mode: params.publish_dir_mode,
        path: { "${params.outdir}/annotation/${meta.variantcaller}/${meta.id}/filtered/" },
        pattern: "*{vcf.gz,vcf.gz.tbi}"
    ]
}
```

## Key Features

### Filter Criteria
- **Filter Expression:** `--include 'FILTER="PASS"'`
- Only variants that passed all quality filters are retained

### Output Configuration
- **Output Format:** Compressed VCF (`.vcf.gz`)
- **Index Generation:** Tabix index (`.tbi`) created automatically
- **File Naming:** Adds `.filtered` suffix to distinguish from unfiltered files

### Publishing Structure
- **Directory:** `${params.outdir}/annotation/${meta.variantcaller}/${meta.id}/filtered/`
- **Files Published:** Both `.vcf.gz` and `.vcf.gz.tbi` files
- Creates a dedicated `filtered/` subfolder as requested

## Usage

The bcftools filter will be automatically applied when running Sarek with either:
- `--tools vep` (VEP-only annotation)
- `--tools merge` (snpEff + VEP merged annotation)

## File Structure Example

```
results/
└── annotation/
    └── haplotypecaller/
        └── sample_id/
            ├── sample_id_VEP.ann.vcf.gz          # Original VEP annotated file
            ├── sample_id_VEP.ann.vcf.gz.tbi      # Original VEP index
            └── filtered/                          # New filtered subfolder
                ├── sample_id.filtered.vcf.gz      # PASS-only filtered file
                └── sample_id.filtered.vcf.gz.tbi  # Filtered file index
```

## Development Branch Specific Notes

- Built on Sarek version 3.7.0dev (latest development version)
- Compatible with all dev branch features and improvements
- Ready for integration into the main development workflow

## Validation

The pipeline syntax has been validated and passes `nextflow run . --help` without errors, showing version 3.7.0dev confirming dev branch base.

## Differences from Master Branch Implementation

This implementation is functionally identical to the master branch version but:
- Based on the latest dev branch (3.7.0dev)
- Includes any dev branch specific improvements and features
- Uses separate feature branch name to distinguish from master-based implementation