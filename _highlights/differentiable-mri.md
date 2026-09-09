---
title: Differentiable Physics for MRI
area: GPU-accelerated inverse problems
start_year: 2025
end_year: Present
current_institution: Stanford University
summary: Automatic differentiation through GPU-accelerated MRI simulations for inverse problems, from RF pulse and sequence design to simulation-based reconstruction.
image: /assets/images/magnus-methods-vs-rk.gif
image_alt: Animated comparison of Magnus and Runge-Kutta methods for simulating spin dynamics during RF excitation
image_caption: Magnus and Runge-Kutta methods advancing magnetization during RF excitation
image_credit: Figure 1, Castillo-Passi et al., ISMRM 2026
image_credit_url: https://echo.ismrm.org/p/ISMRM2026/352-01-002
image_source: https://echo.ismrm.org/p/ISMRM2026/352-01-002
related_outputs:
  - kind: presentation
    key: rf-design-ismrm-2026
    label: RF design abstract
  - kind: presentation
    key: magnus-ismrm-2026
    label: Magnus abstract
  - kind: presentation
    key: juliacon-2026-spins
    label: Drawing with spins
order: 2
---

## Why it matters

MRI simulation predicts the signal produced by an experiment. Inverse problems ask the reverse question: which sequence produces a desired response, or which image explains the measured data? Both require repeatedly evaluating a physical model and understanding how its output changes with its inputs. Fast, accurate simulations and automatic differentiation make these optimization problems more practical.

## Contribution

I work on making GPU-accelerated MRI simulations differentiable and accurate enough to use inside optimization loops, connecting sequence design and image reconstruction through a common physics-based approach.

### RF pulse and sequence design

With Kareem Fareed and collaborators, we use compiler-level reverse-mode automatic differentiation to optimize RF pulses through GPU-accelerated MRI simulations. Our [ISMRM abstract][rf-design] presents this approach.

My JuliaCon talk, [How I Drew the Julia Logo Using Spins in an MRI Machine][drawing-with-spins], demonstrates it on a scanner: an optimized RF pulse excites a Julia-logo pattern in a water-bottle phantom, using KomaMRI for simulation and Pulseq for acquisition.

### Accurate simulations for optimization

I developed the theory and GPU kernels behind our [Magnus-based Bloch simulations][magnus]. This work improves the speed and accuracy of RF excitation simulations and supports their use in inverse design, where numerical errors in the forward model can lead an optimizer to an incorrect solution.

[rf-design]: {{ site.data.presentations | where: 'record_key', 'rf-design-ismrm-2026' | map: 'abstract' | first }}
[magnus]: {{ site.data.presentations | where: 'record_key', 'magnus-ismrm-2026' | map: 'abstract' | first }}
[drawing-with-spins]: {{ site.data.presentations | where: 'record_key', 'juliacon-2026-spins' | map: 'abstract' | first }}
