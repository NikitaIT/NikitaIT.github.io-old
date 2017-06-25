---
layout: post
title:  "Jakyll и Windows 10"
date:   2017-06-25 16:19:23 +0700
image: jakyll-blog-logo.jpg
categories: [jakyll]
---
![Jakyll logo]({{ site.url }}/static/img/posts/jakyll-blog-logo.jpg  "Jakyll logo")
[Jekyll](https://jekyllrb.com/) - это генератор статического сайта, разработанный на `ruby`, который генерирует веб-сайты из `markdown` и многих других форматов.

## Почему стоит использовать именно его?

+ Вы программист, любите свободу и хотите использовать современные походы

+ Прост в использовании и настройке, есть [перевод](http://prgssr.ru/documentation/) документации

+ Поддерживает дополнения на `ruby` и использует [Liquid](https://github.com/Shopify/liquid/wiki) для создания шаблонов

+ Простая интеграция с `julp`(есть готовые [решения](https://github.com/shakyShane/jekyll-gulp-sass-browser-sync))

+ `--watch` из коробки

+ Добавление поста из черновика одной командой `--drafts`

+ Хороший выбор [тем](http://jekyllthemes.org/) и возможность создать свою


## Проблемы с Windows 10
Есть много подходов. Я лично использовал `bash` и мне не понравилось.

- На лето 2017 `bash не поддерживает --watch`.

- Файлы темы лежат вместе с остальными камнями, а значит, если вы хотите больше контроля, то рекомендую прямое скачивание и ручную установку.

Чего не сказано в доках? После развёртывания необходимо обновить `Gemfile.lock`.
{% highlight bash %}
$ sudo jekyll new . 
$ sudo bundle update
$ sudo jekyll serve --no-watch
{% endhighlight %}
И установить `nodejs` тоже не забудьте.
