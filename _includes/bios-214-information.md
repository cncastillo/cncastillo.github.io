## Course information

<div class="course-information" markdown="1">

| | |
|:---|:---|
| **Dates** | {{ course.dates }} · {{ course.weekdays }} |
| **Times** | <img src="/assets/icons/lecture.svg" class="course-icon" alt="" width="14" height="14"> **Lecture:** {{ course.lecture_time }} · <img src="/assets/icons/lab.svg" class="course-icon" alt="" width="14" height="14"> **Laboratory:** {{ course.lab_time }} |
| **Locations** | <img src="/assets/icons/room.svg" class="course-icon" alt="" width="14" height="14"> **Classroom:** [{{ course.classroom.name }}]({{ course.classroom.url }}), except days {{ course.alternate_classroom.days }}: [{{ course.alternate_classroom.name }}]({{ course.alternate_classroom.url }}).<br><img src="/assets/icons/scanner.svg" class="course-icon" alt="" width="14" height="14"> **Friday laboratory:** {{ course.scanner_location }} — {{ course.scanner }}. |
{% for instructor in course.instructors -%}
| {% if forloop.first %}**Instructors**{% endif %} | [{{ instructor.name }}, Ph.D.]({{ instructor.url }}), {{ instructor.position }} |
{% endfor -%}
| **TA** | [{{ course.ta.name }}, Ph.D.]({{ course.ta.url }}), {{ course.ta.position }} |

</div>

**Course links:** [Course website]({{ course.website }}) (schedule/materials) · [Canvas]({{ course.canvas }}) (announcements/submissions)
