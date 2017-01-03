pkg-init:
  pkg.installed:
    - names:
      - curl
      - git
      - policycoreutils
      - postfix
  cmd.run:
    - name: curl -sS http://packages.gitlab.cc/install/gitlab-ce/script.rpm.sh | bash && yum makecache
    - unless: test -e /etc/yum.repos.d/gitlab_gitlab-ce.repo

gitlab-install:
  pkg.installed:
    - names:
      - gitlab-ce
    - unless: rpm -qa | grep gitlab
    - require:
      - cmd: pkg-init

gitlab-config:
  file.managed:
    - name: /etc/gitlab/gitlab.rb
    - source: salt://gitlab/files/gitlab.rb
    - template: jinja
    - defaults:
      LOCAL_IP: {{ grains['ipv4'][1] }}
    - require: 
      - pkg: gitlab-install

gitlab-running:
  cmd.run:
    - name: gitlab-ctl reconfigure
    - unless: netstat -anpt | grep nginx
