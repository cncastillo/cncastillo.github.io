---
title: KomaMRI.jl
area: Open-source MRI simulation
start_year: 2022
end_year: Present
current_institution: Stanford University
summary: Fast, accurate, Pulseq-compatible MRI simulation, with a student-friendly GUI and an extensible API for advanced research.
image: /assets/images/komamri-ui-simulation.gif
image_alt: Animated KomaUI workflow showing sequence, phantom, scanner, simulation, raw data, and MRI reconstruction
image_caption: KomaMRI user interface for configuring, simulating, and reconstructing an MRI acquisition
image_credit: KomaMRI.jl README
image_credit_url: https://github.com/JuliaHealth/KomaMRI.jl#readme
image_license: MIT License
image_license_url: https://github.com/JuliaHealth/KomaMRI.jl/blob/master/LICENSE
image_source: https://github.com/JuliaHealth/KomaMRI.jl/blob/master/docs/src/assets/ui-simulation.gif
related_outputs:
  - kind: publication
    key: komamri
    label: KomaMRI paper
  - kind: publication
    key: komamri-motion
    label: Motion paper
  - kind: presentation
    key: mrisim-ismrm-2022
    label: MRIsim abstract
  - kind: presentation
    key: magnus-ismrm-2026
    label: Magnus abstract
  - kind: presentation
    key: flow-pressure-ismrm-2026
    label: Flow & pressure abstract
  - kind: presentation
    key: mritogether-2026-phantoms
    label: MRITogether 2026 talk
  - kind: presentation
    key: ismrm-2026-reconstruction
    label: MRI reconstruction talk
  - kind: presentation
    key: juliacon-2026-spins
    label: Drawing with spins
  - kind: presentation
    key: rf-design-ismrm-2026
    label: RF design abstract
  - kind: presentation
    key: magnus-workshop-2026
    label: Magnus workshop abstract
  - kind: presentation
    key: komamri-scmr-2025
    label: SCMR 2025 abstract
  - kind: presentation
    key: juliacon-2025-komamri
    label: JuliaCon 2025 talk
  - kind: presentation
    key: mritogether-2025-flow
    label: Motion phantoms talk
  - kind: presentation
    key: ismrm-2025-open-simulation
    label: Open-source simulation talk
  - kind: presentation
    key: juliacon-2023-komamri
    label: JuliaCon 2023 talk
  - kind: presentation
    key: ismrm-2023-pulseq
    label: Pulseq workshop talk
  - kind: presentation
    key: mritogether-2023-komamri
    label: MRITogether 2023 talk
links:
  - label: Documentation
    url: https://juliahealth.org/KomaMRI.jl/
order: 1
---

## Why it matters

I started KomaMRI because MRI simulations were slow and difficult to use, and support for simulating sequences defined in the open-source Pulseq format was limited. I wanted to make it practical to test an MRI experiment before taking it to the scanner.

## Contribution

I designed the framework from the ground up for speed, extensibility, and simplicity: a graphical interface for students getting started, and a powerful API for researchers building their own methods. First presented as MRIsim.jl, it connects sequence definitions, digital phantoms, GPU-accelerated simulation, and image reconstruction.

### Speed and accuracy

In the [original validation study][original-paper], KomaMRI produced mean absolute differences below 0.1% relative to JEMRIS in the tested simulations. In a separate student experiment, it ran eight times faster than JEMRIS on participants' personal computers.

More recently, I developed the theory and high-performance GPU kernels behind our [Magnus-based Bloch simulations][magnus-abstract]. Higher-order methods improve accuracy at a given time step, or allow larger steps for comparable accuracy; the [method documentation](https://juliahealth.org/KomaMRI.jl/dev/explanation/gen-8-magnus-methods) explains this trade-off.

I also applied these methods to inverse RF pulse design, demonstrating cases where numerical inaccuracies in existing simulation methods lead to incorrect pulse designs. The key lesson is that a fast forward simulation is not enough: its accuracy matters when an optimizer uses it to design an experiment.

### Motion and flow

I was heavily involved in KomaMRI's [arbitrary-motion extension][motion-paper], which we continue to develop at Stanford. It makes motion part of the simulated experiment rather than treating the object as static.

Our [ISMRM 2026 flow study][flow-abstract] provides an initial in-silico evaluation of joint velocity–acceleration encoding for 4D-Flow MRI (4D-FlowP), toward simultaneous flow assessment and more robust pressure-gradient estimation.

### Open development

As of September 8, 2026, [KomaMRI on GitHub][code] has 220 stars and [26 contributors](https://github.com/JuliaHealth/KomaMRI.jl/graphs/contributors), excluding bot accounts. Community contributions expand the framework, including its GPU support and motion capabilities. The [documentation](https://juliahealth.org/KomaMRI.jl/dev/) brings together introductory tutorials, reproducible MRI examples, and an API reference for advanced users.

[original-paper]: {{ site.data.publications | where: 'record_key', 'komamri' | map: 'paper' | first }}
[motion-paper]: {{ site.data.publications | where: 'record_key', 'komamri-motion' | map: 'paper' | first }}
[magnus-abstract]: {{ site.data.presentations | where: 'record_key', 'magnus-ismrm-2026' | map: 'abstract' | first }}
[flow-abstract]: {{ site.data.presentations | where: 'record_key', 'flow-pressure-ismrm-2026' | map: 'abstract' | first }}
[code]: {{ site.data.publications | where: 'record_key', 'komamri' | map: 'code' | first }}
