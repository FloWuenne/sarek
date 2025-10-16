# VEP PASS Filtering Enhancement

This enhancement adds automatic filtering of VEP-annotated VCF files to retain only variants with PASS status in the FILTER column.

## Changes Made

### 1. New Module: `modules/nf-core/bcftools/filter/`
- **Purpose**: Filter VCF files using bcftools filter expressions
- **Command**: `bcftools filter --include 'FILTER="PASS"'` 
- **Output**: Compressed VCF (.vcf.gz) and index (.vcf.gz.tbi)
- **Files added**:
  - `main.nf` - Process definition
  - `environment.yml` - Conda dependencies
  - `meta.yml` - Module documentation

### 2. Updated Subworkflow: `subworkflows/local/vcf_annotate_all/`
- Added BCFTOOLS_FILTER process after VEP annotation
- Works with both `vep` and `merge` (snpeff+vep) modes
- New output channel: `vcf_filtered` for PASS-filtered VCFs

### 3. Configuration: `conf/modules/annotate.config`
- Added BCFTOOLS_FILTER process configuration
- **Filter expression**: `--include 'FILTER="PASS"'`
- **Output prefix**: `{original_name}_filtered`
- **Output directory**: `annotation/{variantcaller}/{sample_id}/filtered/`

## Usage

The filtering is automatically applied when using VEP annotation:

```bash
# Single VEP annotation with filtering
nextflow run main.nf --tools vep --input sample.csv

# Combined snpEff + VEP annotation with filtering  
nextflow run main.nf --tools merge --input sample.csv
```

## Output Structure

```
results/
└── annotation/
    └── {variantcaller}/
        └── {sample_id}/
            ├── {sample}_VEP.ann.vcf.gz          # Original VEP-annotated VCF
            ├── {sample}_VEP.ann.vcf.gz.tbi      # Index for original
            └── filtered/                         # NEW: Filtered subfolder
                ├── {sample}_VEP.ann_filtered.vcf.gz     # PASS-only variants
                └── {sample}_VEP.ann_filtered.vcf.gz.tbi # Index for filtered
```

## Technical Details

- **Filter criteria**: Only variants with `FILTER="PASS"` are retained
- **Processing order**: VCF → VEP Annotation → PASS Filtering
- **File naming**: Original filename + `_filtered` suffix
- **Indexing**: Filtered VCFs are automatically indexed with tabix

## Benefits

1. **Cleaner datasets**: Removes low-quality variants that failed filters
2. **Organized output**: Filtered variants in dedicated subfolder  
3. **Downstream analysis**: Ready-to-use high-quality variant sets
4. **Flexible**: Can be extended to other filter criteria in the future

## Testing Updates

### Updated Test Files

1. **`tests/annotation_merge.nf.test.snap`**:
   - Added filtered directory and files to expected outputs for both merge test cases
   - Updated version information to include BCFTOOLS_FILTER module
   - Both `-profile test --tools merge` and `-profile test --tools merge,snpeff,vep` now expect filtered files

2. **`tests/annotation_vep.nf.test`**:
   - Added successful VEP annotation test case: `-profile test --tools vep`
   - Retains existing failure test cases for validation

### Expected Test Outputs

For VEP annotation tests, the following additional files are now expected:
- `annotation/test/filtered/` directory
- `annotation/test/filtered/test_VEP.ann_filtered.vcf.gz`
- `annotation/test/filtered/test_VEP.ann_filtered.vcf.gz.tbi`
- `annotation/test/filtered/test_snpEff_VEP.ann_filtered.vcf.gz` (for merge tests)
- `annotation/test/filtered/test_snpEff_VEP.ann_filtered.vcf.gz.tbi` (for merge tests)

### Version Information

Tests now expect BCFTOOLS_FILTER in the version output with bcftools 1.21.