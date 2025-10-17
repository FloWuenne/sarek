//
// Filter VCF files to retain only PASS variants
//

include { VCFLIB_VCFFILTER } from '../../../modules/nf-core/vcflib/vcffilter'
include { TABIX_TABIX       } from '../../../modules/nf-core/tabix/tabix'

workflow VCF_FILTER_PASS {
    take:
    vcf // channel: [ val(meta), path(vcf), path(tbi) ]

    main:
    ch_versions = Channel.empty()

    // Filter VCF to keep only PASS variants
    VCFLIB_VCFFILTER(vcf)

    // Index the filtered VCF
    TABIX_TABIX(VCFLIB_VCFFILTER.out.vcf)

    // Join filtered VCF with its index
    ch_vcf_tbi = VCFLIB_VCFFILTER.out.vcf.join(TABIX_TABIX.out.tbi, failOnDuplicate: true, failOnMismatch: true)

    // Gather versions
    ch_versions = ch_versions.mix(VCFLIB_VCFFILTER.out.versions)
    ch_versions = ch_versions.mix(TABIX_TABIX.out.versions)

    emit:
    vcf_tbi  = ch_vcf_tbi // channel: [ val(meta), path(vcf), path(tbi) ]
    versions = ch_versions // channel: [ versions.yml ]
}