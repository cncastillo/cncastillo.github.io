---
title: Whole-heart MR Angiography at 0.55T
area: Low-field cardiovascular MRI
start_year: 2023
end_year: 2025
summary: Free-breathing whole-heart MRI at 0.55T, combining coronary angiography with CMRA and simultaneous lumen and vessel-wall imaging with iT2prep-BOOST.
image: /assets/images/whole-heart-mra-paper.jpg
image_alt: Coronal whole-heart cardiac MRA, coronary reformats, and maximum-intensity projections from four subjects scanned at 0.55T
image_caption: Whole-heart CMRA results for four representative healthy subjects
image_credit: Figure 5, Castillo-Passi et al.
image_credit_url: https://pmc.ncbi.nlm.nih.gov/articles/PMC11604836/#mrm30316-fig-0005
image_license: CC BY 4.0
image_license_url: https://creativecommons.org/licenses/by/4.0/
related_outputs:
  - kind: publication
    key: low-field-cmra
    label: CMRA paper
  - kind: publication
    key: low-field-boost
    label: BOOST paper
  - kind: presentation
    key: low-field-cmra-ismrm
    label: CMRA abstract
  - kind: presentation
    key: it2prep-boost-scmr
    label: BOOST abstract
order: 3
---

## Why it matters

Low-field MRI can improve access to cardiovascular imaging, but reduced signal and different tissue properties require sequences to be reconsidered rather than transferred directly from higher field strengths.

## Contribution

Both studies combine simulation-guided sequence design, image navigators, nonrigid respiratory motion correction, and patch-based denoising to support free-breathing whole-heart imaging at 0.55T.

### Coronary angiography (CMRA)

The CMRA acquisition visualizes the main cardiac structures and coronary arteries without contrast agents. In the initial healthy-volunteer study, whole-heart images were acquired in approximately six minutes.

### Lumen and vessel-wall imaging (iT2prep-BOOST)

iT2prep-BOOST produces co-registered 3D bright-blood and black-blood images in a single scan, providing complementary views of the vessel lumen and wall. The initial 0.55T study demonstrated this approach in healthy volunteers with a scan time of approximately eight minutes.

The subsequent MRM study extends iT2prep-BOOST to aortic imaging at either systole or diastole. It evaluates T2-preparation pulses to reduce flow-related artifacts, demonstrating simultaneous lumen and vessel-wall imaging in approximately seven minutes.

### Resources

[Simulation tutorial for CMRA sequence optimization](https://juliahealth.org/KomaMRI.jl/dev/tutorial/pluto/gen-02-low-field-cmra-optimization)
