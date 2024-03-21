# Домашнее задание к занятию "`Disaster recovery и Keepalived`" - `Дунаев Дмитрий`


### Инструкция по выполнению домашнего задания

   1. Сделайте `fork` данного репозитория к себе в Github и переименуйте его по названию или номеру занятия, например, https://github.com/имя-вашего-репозитория/git-hw или  https://github.com/имя-вашего-репозитория/7-1-ansible-hw).
   2. Выполните клонирование данного репозитория к себе на ПК с помощью команды `git clone`.
   3. Выполните домашнее задание и заполните у себя локально этот файл README.md:
      - впишите вверху название занятия и вашу фамилию и имя
      - в каждом задании добавьте решение в требуемом виде (текст/код/скриншоты/ссылка)
      - для корректного добавления скриншотов воспользуйтесь [инструкцией "Как вставить скриншот в шаблон с решением](https://github.com/netology-code/sys-pattern-homework/blob/main/screen-instruction.md)
      - при оформлении используйте возможности языка разметки md (коротко об этом можно посмотреть в [инструкции  по MarkDown](https://github.com/netology-code/sys-pattern-homework/blob/main/md-instruction.md))
   4. После завершения работы над домашним заданием сделайте коммит (`git commit -m "comment"`) и отправьте его на Github (`git push origin`);
   5. Для проверки домашнего задания преподавателем в личном кабинете прикрепите и отправьте ссылку на решение в виде md-файла в вашем Github.
   6. Любые вопросы по выполнению заданий спрашивайте в чате учебной группы и/или в разделе “Вопросы по заданию” в личном кабинете.
   
Желаем успехов в выполнении домашнего задания!
   
### Дополнительные материалы, которые могут быть полезны для выполнения задания

1. [Руководство по оформлению Markdown файлов](https://gist.github.com/Jekins/2bf2d0638163f1294637#Code)

---

### Задание 1
- Дана [схема](1/hsrp_advanced.pkt) для Cisco Packet Tracer, рассматриваемая в лекции.
- На данной схеме уже настроено отслеживание интерфейсов маршрутизаторов Gi0/1 (для нулевой группы)
- Необходимо аналогично настроить отслеживание состояния интерфейсов Gi0/0 (для первой группы).
- Для проверки корректности настройки, разорвите один из кабелей между одним из маршрутизаторов и Switch0 и запустите ping между PC0 и Server0.
- На проверку отправьте получившуюся схему в формате pkt и скриншот, где виден процесс настройки маршрутизатора.

------

### Решение 1
Скриншоты настройки маршрутизаторов:

![Маршрутизатор 1](https://github.com/duskdemon/sys-29-sflt-01/blob/main/img/sflt-01-cptr-rt01.png)
![Маршрутизатор 2](https://github.com/duskdemon/sys-29-sflt-01/blob/main/img/sflt-01-cptr-rt02.png)

Скриншоты прохождения пинга при целой схеме (скриншот 1) и при отсутствии одного из соединений между коммутатором и маршрутизатором (скриншот 2):

![Целая схема](https://github.com/duskdemon/sys-29-sflt-01/blob/main/img/sflt-01-cptr-norm.png)
![Минус одно соединенине](https://github.com/duskdemon/sys-29-sflt-01/blob/main/img/sflt-01-cptr-tear.png)

[Схема с настроенными маршрутизаторами в формате pkt](https://github.com/duskdemon/sys-29-sflt-01/blob/main/hsrp_advanced_hw.pkt)

---

### Задание 2
- Запустите две виртуальные машины Linux, установите и настройте сервис Keepalived как в лекции, используя пример конфигурационного [файла](1/keepalived-simple.conf).
- Настройте любой веб-сервер (например, nginx или simple python server) на двух виртуальных машинах
- Напишите Bash-скрипт, который будет проверять доступность порта данного веб-сервера и существование файла index.html в root-директории данного веб-сервера.
- Настройте Keepalived так, чтобы он запускал данный скрипт каждые 3 секунды и переносил виртуальный IP на другой сервер, если bash-скрипт завершался с кодом, отличным от нуля (то есть порт веб-сервера был недоступен или отсутствовал index.html). Используйте для этого секцию vrrp_script
- На проверку отправьте получившейся bash-скрипт и конфигурационный файл keepalived, а также скриншот с демонстрацией переезда плавающего ip на другой сервер в случае недоступности порта или файла index.html


------

### Решение 2

1. Подняты 2 виртуальные машины на Debian, ip адреса 192.168.122.231 и 192.168.122.232;
2. Настроен apache на стандартном порту 80, в файле index.html содержится ip-адрес хоста;
3. Написан скрипт на bash, который проверяет, что порт 80 на машине в состоянии LISTEN, а также, что файл index.html существует,
если условия не выполняются, выдается код выхода 1. Листинг скрипта:
```
#!/bin/bash

p80=$(ss -ltn | grep :80 | awk '{print $1}')
fe=$(ls /var/www/html/index.html)

p80r=LISTEN
fer=/var/www/html/index.html

if [ "$p80" = "$p80r" ]; then echo 'port 80 is open';
else echo 'check failed, port 80 is not open'; exit 1;
fi
if [ "$fe" = "$fer" ]; then echo 'file index.html exists';
else echo 'check failed, file index.html does not exist'; exit 1;
fi
```  
4. Установлен и настроен keepalived, машина с ip 231 сконфигурирована как MASTER, а машина с ip 232 как BACKUP, плавающий ip назначен 192.168.122.233. Настроена проверка работоспособности машины по скрипту apachek.sh каждые 3 секунды. 
Конфиг машины MASTER: 
```
vrrp_script check_apache {
    script "/home/dusk/apachek.sh"
    interval 3
}
vrrp_instance VI_1 {
        state MASTER
        interface enp1s0
        virtual_router_id 233
        priority 255
        advert_int 1

        virtual_ipaddress {
              192.168.122.233/24
        }
     
        track_script {
	           check_apache
		}
}
```
Конфиг машины BACKUP:
```
vrrp_script check_apache {
    script "/home/dusk/apachek.sh"
    interval 3
}
vrrp_instance VI_1 {
        state BACKUP
        interface enp1s0
        virtual_router_id 233
        priority 200
        advert_int 1

        virtual_ipaddress {
              192.168.122.233/24
        }
     
        track_script {
	           check_apache
		}
}
```
Вывод команды ip a на машине MASTER:
![Плавающий ip](https://github.com/duskdemon/sys-29-sflt-01/blob/main/img/sflt-01-keal-ipma.png)
5. Для проверки, машины работают в штатном режиме, сначала откроем страницу по плавающему адресу http://192.168.122.233:
![Штатный режим](https://github.com/duskdemon/sys-29-sflt-01/blob/main/img/sflt-01-keal-norm.png)
6. Переименуем файл index.html на MASTER машине, откроем страницу по плавающему адресу http://192.168.122.233, увидим, что наши настройки отработали успешно и открывается страница с машины BACKUP с адресом 232:
![переключение на BACKUP](https://github.com/duskdemon/sys-29-sflt-01/blob/main/img/sflt-01-keal-back.png)
Вывод лога keepalived при переключении:
![Вывод лога](https://github.com/duskdemon/sys-29-sflt-01/blob/main/img/sflt-01-keal-klog.png)
7. Вернем файл index.html на место и проверим, как отработает keepalived:
![Переключение обратно на MASTER](https://github.com/duskdemon/sys-29-sflt-01/blob/main/img/sflt-01-keal-sb2m.png)