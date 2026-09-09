---
layout: course
title: "Open-Source MRI Sequence Development: Simulation to Scanner"
code: BIOS 214
term: Autumn 2026
institution: Stanford School of Medicine
instructors: "**Carlos Castillo-Passi** and Daniel Ennis"
program: >-
  A Stanford School of Medicine mini-course for the Biosciences community,
  offered through the [Office of Graduate Education](https://oge.stanford.edu/academics/mini-courses-overview/).
order: 1
description: Hands-on MRI sequence design, simulation, acquisition, and reconstruction with open-source tools.
image: /assets/images/bios-214-course.png
image_alt: Illustration of a student developing an MRI sequence at a computer showing scanner and heart images.
permalink: /teaching/bios-214/
sections:
  - label: Overview
    href: "#overview"
  - label: Learning goals
    href: "#learning-goals"
  - label: Schedule & materials
    href: "#schedule"
  - label: Lab setup
    href: "#setup"
  - label: Canvas
    href: "#canvas"
---

## Overview

This interdisciplinary mini-course introduces an end-to-end workflow for rapid MRI sequence development and image reconstruction using open-source tools. Students will design pulse sequences in Pulseq, simulate and validate them with KomaMRI, and reconstruct simulated or acquired MRI data using BART and MRIReco. Students will also learn how Pulseq sequences and reconstruction workflows can be integrated directly on MRI scanners through Pulseq interpreters and OpenRecon.

The course combines short lectures with hands-on coding and lab sessions focused on rapid prototyping, simulation, acquisition, and reconstruction. It emphasizes research rigor, reproducibility, and transparency through open-source tools and reproducible workflows.

Intended for students with basic programming experience and an interest in MRI and computational methods.

**Grading:** MED S/NC (Satisfactory/No Credit).

## Learning goals

By the end of this mini-course, students will be able to:

1. Design basic MRI pulse sequences using Pulseq.
2. Simulate MRI experiments using Bloch simulations in KomaMRI.
3. Reconstruct MRI data using BART and MRIReco.
4. Analyze the impact of sequence parameters on image contrast and artifacts.
5. Implement and iterate on sequence designs using a rapid prototyping workflow.
6. Evaluate sequence performance through simulation and scanner experiments.

## Schedule & materials {#schedule}

<table>
  <thead>
    <tr><th>Week</th><th>Monday</th><th>Wednesday</th><th>Friday</th></tr>
  </thead>
  <tbody>
    <tr>
      <td markdown="span">**Week 1**</td>
      <td markdown="span"><span class="course-day-header">**Nov 9<sup>*</sup>**</span><span class="course-session"><span>![][lecture-icon]{: .course-icon} Lecture:</span> <a role="link" aria-disabled="true">Coming soon</a></span><span class="course-session"><span>![][lab-icon]{: .course-icon} Lab:</span> <a role="link" aria-disabled="true">Coming soon</a></span></td>
      <td markdown="span"><span class="course-day-header">**Nov 11**</span><span class="course-session"><span>![][lecture-icon]{: .course-icon} Lecture:</span> <a role="link" aria-disabled="true">Coming soon</a></span><span class="course-session"><span>![][lab-icon]{: .course-icon} Lab:</span> <a role="link" aria-disabled="true">Coming soon</a></span></td>
      <td markdown="span"><span class="course-day-header">**Nov 13<sup>*</sup>**</span><span class="course-session"><span>![][lecture-icon]{: .course-icon} Lecture:</span> <a role="link" aria-disabled="true">Coming soon</a></span><span class="course-session"><span>![][scanner-icon]{: .course-icon} Lab:</span> <a role="link" aria-disabled="true">Coming soon</a></span></td>
    </tr>
    <tr>
      <td markdown="span">**Week 2**</td>
      <td markdown="span"><span class="course-day-header">**Nov 16**</span><span class="course-session"><span>![][lecture-icon]{: .course-icon} Lecture:</span> <a role="link" aria-disabled="true">Coming soon</a></span><span class="course-session"><span>![][lab-icon]{: .course-icon} Lab:</span> <a role="link" aria-disabled="true">Coming soon</a></span></td>
      <td markdown="span"><span class="course-day-header">**Nov 18**</span><span class="course-session"><span>![][lecture-icon]{: .course-icon} Lecture:</span> <a role="link" aria-disabled="true">Coming soon</a></span><span class="course-session"><span>![][lab-icon]{: .course-icon} Lab:</span> <a role="link" aria-disabled="true">Coming soon</a></span></td>
      <td markdown="span"><span class="course-day-header">**Nov 20**</span><span class="course-session"><span>![][lecture-icon]{: .course-icon} Lecture:</span> <a role="link" aria-disabled="true">Coming soon</a></span><span class="course-session"><span>![][scanner-icon]{: .course-icon} Lab:</span> <a role="link" aria-disabled="true">Coming soon</a></span></td>
    </tr>
    <tr>
      <td markdown="span">**Week 3**</td>
      <td colspan="3" class="course-break"><img class="course-icon" src="{{ '/assets/icons/turkey.svg' | relative_url }}" alt="" width="24" height="24"> Thanksgiving break</td>
    </tr>
    <tr>
      <td markdown="span">**Week 4**</td>
      <td markdown="span"><span class="course-day-header">**Nov 30**</span><span class="course-session"><span>![][lecture-icon]{: .course-icon} Lecture:</span> <a role="link" aria-disabled="true">Coming soon</a></span><span class="course-session"><span>![][lab-icon]{: .course-icon} Lab:</span> <a role="link" aria-disabled="true">Coming soon</a></span></td>
      <td markdown="span"><span class="course-day-header">**Dec 2**</span><span class="course-session"><span>![][lecture-icon]{: .course-icon} Lecture:</span> <a role="link" aria-disabled="true">Coming soon</a></span><span class="course-session"><span>![][lab-icon]{: .course-icon} Lab:</span> <a role="link" aria-disabled="true">Coming soon</a></span></td>
      <td markdown="span"><span class="course-day-header">**Dec 4**</span><span class="course-session"><span>![][lecture-icon]{: .course-icon} Lecture:</span> <a role="link" aria-disabled="true">Coming soon</a></span><span class="course-session"><span>![][scanner-icon]{: .course-icon} Lab:</span> <a role="link" aria-disabled="true">Coming soon</a></span></td>
    </tr>
  </tbody>
</table>

**Classroom:** ![][room-icon]{: .course-icon} [CCSR4107][ccsr4107]. \*November 9 and 13: ![][room-icon]{: .course-icon} [M218/218A][m218].

![][lecture-icon]{: .course-icon} **Lecture:** 9:30–10:20 a.m.<br>
![][lab-icon]{: .course-icon} **Lab:** 10:30–11:50 a.m.

![][scanner-icon]{: .course-icon} **Friday scanning:** After the lecture, we’ll head to Cima.X (3T3) in the Lucas Center.

[m218]: https://25live.collegenet.com/pro/stanfordsom#!/home/location/1454 "M218/218A room details"
[ccsr4107]: https://25live.collegenet.com/pro/stanfordsom#!/home/location/1431 "CCSR4107 room details"
[lecture-icon]: {{ '/assets/icons/lecture.svg' | relative_url }}
[lab-icon]: {{ '/assets/icons/lab.svg' | relative_url }}
[scanner-icon]: {{ '/assets/icons/scanner.svg' | relative_url }}
[room-icon]: {{ '/assets/icons/room.svg' | relative_url }}

## Lab setup {#setup}

Before the first lab, please have:

- [Julia 1.12](https://julialang.org/downloads/) installed.
- A coding agent installed and ready to use, such as [Codex](https://learn.chatgpt.com/docs/codex/cli) or [Claude Code](https://code.claude.com/docs/en/quickstart). Complete its sign-in or account setup beforehand.

## Canvas

Enrolled students can access [BIOS 214 on Canvas](https://canvas.stanford.edu/courses/233500) for announcements, submissions, grades, and any restricted material.
