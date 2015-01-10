#!jinja|yaml

{% from 'php/defaults.yaml' import rawmap with context %}
{% set datamap = salt['grains.filter_by'](rawmap, merge=salt['pillar.get']('php:lookup')) %}

include: {{ datamap.sls_include|default([]) }}
extend: {{ datamap.sls_extend|default({}) }}

php:
  pkg:
    - installed
    - pkgs: {{ datamap.pkgs }}

{% set versions = salt['pillar.get']('php:versions', {}) %}
{% for veralias, v in versions.items() %}
  {% set extensions = v.extensions|default({}) %}

php_{{ veralias }}_verpkgs:
  pkg:
    - installed
    - pkgs: {{ v.pkgs|default([]) }}

  {% for f in v.config.manage|default([]) %}
    {% set c = v.config[f]|default({}) %}

php_{{ veralias }}_config_{{ f }}:
  file:
    - {{ c.ensure|default('managed') }}
    - name: {{ c.path }}
    - source: {{ c.template_path|default('salt://php/files/configs/' ~ f) }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
      veralias: {{ veralias }}
  {% endfor %}

  {% for ealias, edata in extensions.items() %}
php_{{ veralias }} extension_{{ ealias }}:
  file:
    - {{ edata.ensure|default('managed') }}
    - name: {{ datamap.localextrootdir ~ '/' ~ veralias ~ '/' ~ edata.filename|default(ealias ~ '.so') }}
    - source: {{ edata.source }}
    - user: {{ edata.user|default('root') }}
    - group: {{ edata.group|default('root') }}
    - mode: {{ edata.mode|default(755) }}
    - makedirs: True
  {% endfor %}
{% endfor %}

{% for p in salt['pillar.get']('php:pear', []) %}
php_pear_pkg_{{ p }}:
  cmd:
    - run
    - name: pear install {{ p }}
    - unless: pear info {{ p }}
{% endfor %}

php_maillog:
  file:
    - managed
    - name: {{ datamap.maillog.path|default('/var/log/phpmail.log') }}
    - user: root
    - group: root
    - mode: 622

php_maillog_logrotate:
  file:
    - managed
    - name: {{ datamap.maillog_logrotate.path|default('/etc/logrotate.d/phpmail') }}
    - source: {{ datamap.maillog_logrotate.template_path|default('salt://php/files/phpmail_logrotate') }}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
