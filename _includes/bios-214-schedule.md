<p class="schedule-hint course-schedule-hint">Scroll sideways to see all days.</p>
<div class="schedule-scroll course-schedule-scroll" role="region" aria-label="Weekly course schedule" tabindex="0" markdown="1">

| Week | Monday | Wednesday | Friday |
|:-----|:-------|:----------|:-------|
{% for week in course.weeks -%}
| **Week {{ week.number }}**{% if week.topic %}<br>{{ week.topic }}{% endif %} | {% if week.break %}<span class="break"><img src="/assets/icons/turkey.svg" class="course-icon" alt="" width="14" height="14"> {{ week.dates }} · {{ week.break }}</span> |  |  |{% else %}{% for day in week.days %}{% capture session %}{% include bios-214-schedule-day.md day=day %}{% endcapture %}{{ session | strip }} | {% endfor %}{% endif %}
{% endfor -%}
{: .schedule}

</div>

{% include bios-214-classroom.md %}
