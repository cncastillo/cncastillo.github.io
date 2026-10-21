---
layout: course
course_data: bios-214
order: 1
image: /assets/images/bios-214-course.png
image_alt: Illustration of a student developing an MRI sequence at a computer showing scanner and heart images.
permalink: /teaching/bios-214/
sections:
  - label: Syllabus (PDF) ↓
    href: /assets/teaching/bios-214-syllabus.pdf
    download: BIOS-214-syllabus.pdf
  - label: Overview
    href: "#overview"
  - label: Learning goals
    href: "#learning-goals"
  - label: Schedule & materials
    href: "#schedule"
  - label: Before the first class
    href: "#setup"
  - label: Canvas
    href: "#canvas"
---

{% assign course = site.data[page.course_data] %}

<div class="course-intro-grid" markdown="1">
<section aria-labelledby="overview" markdown="1">

## Overview

{% include bios-214-overview.md %}

</section>
<section aria-labelledby="learning-goals" markdown="1">

## Learning goals

{% include bios-214-learning-goals.md %}

</section>
</div>

## Schedule & materials {#schedule}

<p class="schedule-updated">Last updated: {{ course.last_updated }}</p>

{% include bios-214-materials.html %}

{% include bios-214-classroom.md %}

<img src="/assets/icons/lecture.svg" class="course-icon" alt="" width="14" height="14"> **Lecture:** {{ course.lecture_time }}<br>
<img src="/assets/icons/lab.svg" class="course-icon" alt="" width="14" height="14"> **Lab:** {{ course.lab_time }}

<img src="/assets/icons/scanner.svg" class="course-icon" alt="" width="14" height="14"> **Friday scanning:** After the lecture, we’ll head to {{ course.scanner }} in the {{ course.scanner_location }}.

## Before the first class {#setup}

{% include bios-214-setup.md %}

## Canvas

Enrolled students can access [{{ course.code }} on Canvas]({{ course.canvas }}) for announcements, submissions, grades, and any restricted material.
