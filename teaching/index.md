---
layout: page
title: Teaching
kicker: Courses and public materials
description: Course notes, examples, and setup guides that are useful beyond the classroom.
permalink: /teaching/
---

{% assign courses = site.pages | where: "layout", "course" | sort: "order" %}

<div class="course-list">
  {% for course in courses %}
    <article class="course-card{% if course.image %} course-card-with-image{% endif %}">
      {% if course.image %}
        <a class="course-card-media" href="{{ course.url | relative_url }}" tabindex="-1" aria-hidden="true">
          <img src="{{ course.image | relative_url }}" alt="" loading="lazy">
        </a>
      {% endif %}
      <div class="course-card-copy">
        <p class="archive-type">{{ course.term }}{% if course.institution %} · {{ course.institution }}{% endif %}</p>
        <h2><a href="{{ course.url | relative_url }}">{{ course.code }}</a></h2>
        <p>{{ course.title }}.</p>
        {% if course.program %}<div class="course-program">{{ course.program | markdownify }}</div>{% endif %}
        <a class="text-link" href="{{ course.url | relative_url }}">Course page →</a>
      </div>
    </article>
  {% endfor %}
</div>
