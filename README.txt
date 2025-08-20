Расчёт хостов:
1)Исходные данные (на 1 год)
Постов/день = 20 000 → 7.3 млн/год
Размер строки поста (OLTP) = 400 B → 2.9 GB/год

Комментариев/пост = 3 → 6.6 GB/год (=300 B/коммент)
Реакций/пост = 20 → 14.6 GB/год (=100 B/реакция)

Средний RPS (для IOPS/пропускной):
- Посты = 800 rps, payload = 2.0 KB
- Комментарии = 300 rps, payload = 0.3 KB
- Реакции = 500 rps, payload = 0.1 KB

Фото/медиа (Object Storage):
- 3 фото/пост, 1.0 MB + 0.15 MB превью = 1.15 MB/фото
- На пост = 3.45 MB → за год =25.2 TB (без RF)

2) Формулы из методички
Hosts = disks / disks_per_host
Hosts_with_replication = hosts * replication_factor
(берём целые вверх: ceil)

Для шардов:
disks_total = shards * disks_per_shard
hosts = disks_total / disks_per_host
hosts_with_replication = hosts * replication_factor


Параметры:

shards = 2
replication_factor = 3
disks_per_host = 1
NVMe: на подсистему хватает 1 диска на шард (по нашим объёмам/IOPS)

3) Подсистема «Посты» (OLTP, 2 шарда, RF=3)
disks_per_shard = 1
disks_total = shards * disks_per_shard = 2 * 1 = 2
hosts = disks_total / disks_per_host = 2 / 1 = 2
hosts_with_replication = hosts * replication_factor = 2 * 3 = 6

ИТОГО (Посты): 6 хостов

4)Подсистема «Комментарии» (OLTP, 2 шарда, RF=3)
disks_per_shard = 1
disks_total = 2
hosts = 2
hosts_with_replication = 2 * 3 = 6

ИТОГО (Комментарии): 6 хостов

5) Подсистема «Реакции» (OLTP, 2 шарда, RF=3)
disks_per_shard = 1
disks_total = 2
hosts = 2
hosts_with_replication = 2 * 3 = 6

ИТОГО (Реакции): 6 хостов

6) Подсистема «Фото/медиа» (Object Storage, RF=3):

disks = 1
hosts = disks / disks_per_host = 1 / 1 = 1
hosts_with_replication = 1 * 3 = 3

ИТОГО (Фото/медиа): 3 хоста

7) Сводка по хостам (вариант с шардированием + репликацией)
Посты       — 6 хостов
Комментарии — 6 хостов
Реакции     — 6 хостов
Фото/медиа  — 3 хоста
--------------------------------
ИТОГО       — 21 хост

8) Пояснение по стратегии шардирования/репликации (коротко, для отчёта)
• Шардирование: hash-based по author_id (2 шарда) для таблиц posts, comments, reactions.
  Это даёт равномерное распределение записи и простую маршрутизацию по ключу автора.
• Репликация: RF=3 для каждого шарда (Primary + 2 Standby). Чтения распределяем по репликам,
  записи — через Primary. При росте нагрузки шардов можно добавить (4/8), схема ключа не меняется.
• Фото/медиа: объектное хранилище с RF=3 (или EC). В расчёте по методичке — 1 диск → 3 хоста.
• Выбор носителей: NVMe (10k IOPS) позволяет уложиться в 1 диск на шард для каждой подсистемы.