---
title: Magnetic Resonance Fingerprinting
area: Quantitative MRI
start_year: 2024
end_year: 2025
summary: Motion-compensated diffusion encoding for simultaneous T1, T2, and ADC mapping, with liver validation, 0.55T feasibility studies, and open-source Julia code.
image: /assets/images/diffprep-liver-mrf-paper.jpg
image_alt: Liver T1, T2, and ADC maps from MR fingerprinting compared with reference scans in three subjects
image_caption: Liver T1, T2, and ADC maps from MR fingerprinting and reference scans
image_credit: Figure 7, Velasco, Castillo-Passi et al., MRM 2025
image_credit_url: https://pmc.ncbi.nlm.nih.gov/articles/PMC12393201/#mrm30622-fig-0007
image_license: CC BY 4.0
image_license_url: https://creativecommons.org/licenses/by/4.0/
image_source: https://cdn.ncbi.nlm.nih.gov/pmc/blobs/c1cf/12393201/e7a20199f924/MRM-94-2173-g004.jpg
related_outputs:
  - kind: publication
    key: liver-mrf
    label: MRM paper
  - kind: presentation
    key: liver-mrf-ismrm
    label: ISMRM abstract
  - kind: presentation
    key: diffusion-mrf-055t-ismrm
    label: Diffusion MRF at 0.55T
  - kind: presentation
    key: cardiac-mrf-055t-ismrm
    label: Cardiac MRF at 0.55T (ISMRM)
  - kind: presentation
    key: cardiac-mrf-055t-scmr
    label: Cardiac MRF at 0.55T (SCMR)
order: 4
---

## Why it matters

Combining relaxation and diffusion measurements can provide complementary information about liver tissue. Acquiring them together is challenging: motion during diffusion encoding can cause signal loss and unreliable measurements.

## Contribution

DiffPrep optimizes motion-compensated gradient waveforms for diffusion-preparation modules. The open-source Julia implementation makes the waveform optimization reproducible and provides the gradients used in our liver MR fingerprinting study.

Combined with peripheral pulse triggering and a breath-held acquisition, these preparations enable co-registered T1, T2, and apparent diffusion coefficient (ADC) maps in approximately 16 seconds. The method was evaluated in phantoms and healthy volunteers; evaluation in patients remains future work.

### Diffusion-prepared MRF at 0.55T

The low-field feasibility study combines radial bSSFP readouts with inversion recovery, T2 preparation, and optimized diffusion-preparation pulses over 16 heartbeats. Simultaneous T1, T2, and ADC mapping was validated in phantoms against spin-echo references at 0.55T.

### Related cardiac T1/T2 MRF at 0.55T

The cardiac studies presented at ISMRM and SCMR 2024 investigate T1 and T2 mapping without diffusion preparation or motion-compensated diffusion gradients. Radial bSSFP acquisitions over 16 heartbeats were evaluated in phantoms and healthy volunteers. These studies establish low-field cardiac MRF feasibility; they are distinct from the diffusion-prepared approach above.
