---
layout: page
page_class: teaching-page
title: Teaching & Mentorship
kicker: Education and community
description: Courses, public learning materials, and mentorship in MRI research and open-source software.
permalink: /teaching/
---

{% assign courses = site.pages | where: "layout", "course" | sort: "order" %}

<nav class="section-nav" aria-label="Page sections">
  <a href="#courses">Courses</a>
  {% if site.data.mentorship.size > 0 %}<a href="#mentorship">Mentorship</a>{% endif %}
</nav>

<div class="course-list" id="courses">
  {% for course in courses %}
    <article class="course-card{% if course.image %} course-card-with-image{% endif %}">
      {% if course.image %}
        <a class="course-card-media" href="{{ course.url | relative_url }}" tabindex="-1" aria-hidden="true">
          <img src="{{ course.image | relative_url }}" alt="" loading="lazy">
        </a>
      {% endif %}
      <div class="course-card-copy">
        <p class="archive-type">{{ course.code }} · {{ course.term }}{% if course.institution %} · {{ course.institution }}{% endif %}</p>
        <h2><a href="{{ course.url | relative_url }}">{{ course.title }}</a></h2>
        <p>{{ course.description }}</p>
        <a class="text-link" href="{{ course.url | relative_url }}">Course page →</a>
      </div>
    </article>
  {% endfor %}
</div>

{% if site.data.mentorship.size > 0 %}
<section id="mentorship" aria-labelledby="mentorship-heading">
  <h2 id="mentorship-heading">Mentorship</h2>
  <div class="archive-list">
    {% assign people = site.data.mentorship | sort: "order" | group_by: "name" %}
    {% for person in people %}
      <article class="archive-item mentorship-person">
        <div>
          <h3>{{ person.name | escape }}</h3>
          {% assign affiliations = person.items | map: "home_affiliation" | compact | uniq %}
          {% for affiliation in affiliations %}<p class="venue">{{ affiliation | escape }}</p>{% endfor %}
        </div>
        <div>
          {% assign years = person.items | group_by: "year" | sort: "name" | reverse %}
          {% for year in years %}
            {% assign entries = year.items | sort: "order" %}
            {% for entry in entries %}
              <div class="mentorship-entry">
                <p class="archive-type">
                  {{ entry.year }} ·
                  {% if entry.program_logo %}<span class="mentorship-logo" style="--mentorship-logo: url('{{ entry.program_logo | relative_url | escape }}');" aria-hidden="true"></span>{% endif %}
                  {{ entry.program | escape }} ·
                  {% if entry.organization_logo %}<span class="mentorship-logo" style="--mentorship-logo: url('{{ entry.organization_logo | relative_url | escape }}');" aria-hidden="true"></span>{% endif %}
                  {{ entry.organization | escape }}
                </p>
                {% if entry.project %}<p class="venue">{{ entry.project | escape }}</p>{% endif %}
                {% if entry.role %}<p class="venue">{{ entry.role | escape }}</p>{% endif %}
                {% if entry.links.size > 0 %}
                  <div class="item-links archive-item-links">
                    {% for link in entry.links %}<a href="{{ link.url | escape }}">{{ link.label | escape }}</a>{% endfor %}
                  </div>
                {% endif %}
              </div>
            {% endfor %}
          {% endfor %}
        </div>
      </article>
    {% endfor %}
  </div>
</section>
{% endif %}
