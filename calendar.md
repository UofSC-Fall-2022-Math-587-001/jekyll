---
layout: page
title: Schedule
description: Listing of course modules and topics.
nav_order: 1
---

# Schedule
{% assign modules = site.modules | where: "ended", "false" %}
{% for module in modules %}
{{ module }}
{% endfor %}

{% assign past_modules = site.modules | where: "ended", "true" %}

{% if past_modules.size != 0 %}
## Past topics

----------
{% endif %}

{% for module in past_modules reversed %}
{{ module }}
{% endfor %}
