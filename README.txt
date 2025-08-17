Исходные допущения:

Постов/день = 20 000 → 7.3 млн/год; размер строки поста ≈ 400 B → 2.9 GB/год в OLTP

Комментариев/пост = 3; размер ≈ 300 B → 6.6 GB/год

Реакций/пост = 20; размер ≈ 100 B → 14.6 GB/год

Средний RPS (для расчёта IOPS/пропускной): Посты 800 rps, Комменты 300 rps, Реакции 500 rps

Средний полезный размер ответа: Пост 2.0 KB, Коммент 0.3 KB, Реакция 0.1 KB

Без репликации (RF не применяем)

1) Посты 

Входные величины
capacity = 2.9 GB = 0.0029 TB
rps = 800
payload = 2.0 KB

Производные
traffic_per_second = rps * payload = 800 * 2.0 KB ≈ 1600 KB/s ≈ 1.56 MB/s
iops = rps = 800

HDD
Disks_for_capacity   = capacity / disk_capacity   = 0.0029 / 32       = 0.000091  → ceil = 1
Disks_for_throughput = traffic_per_second / disk_throughput = 1.56 / 100 = 0.0156   → ceil = 1
Disks_for_iops       = iops / disk_iops          = 800 / 100          = 8         → ceil = 8
Disks = max(1, 1, 8) = 8

SSD (SATA)
cap → 0.0029/100 = 0.000029 → ceil=1
thr → 1.56/500 = 0.00312     → ceil=1
iops → 800/1000 = 0.8        → ceil=1
Disks = 1

SSD (NVMe)
cap → 0.0029/30 = 0.0000967  → ceil=1
thr → 1.56/3000 = 0.00052    → ceil=1
iops → 800/10000 = 0.08      → ceil=1
Disks = 1
Итог (Посты): HDD 8, SATA 1, NVMe 1.

2. Комментарии
# Входные величины
capacity = 6.6 GB = 0.0066 TB
rps = 300
payload = 0.3 KB

# Производные
traffic_per_second = 300 * 0.3 KB = 90 KB/s ≈ 0.088 MB/s
iops = 300

HDD
cap  = 0.0066 / 32  = 0.000206 → ceil=1
thr  = 0.088 / 100  = 0.00088  → ceil=1
iops = 300 / 100    = 3        → ceil=3
Disks = max(1,1,3) = 3

SSD (SATA)
cap → 0.0066/100 = 0.000066 → ceil=1
thr → 0.088/500  = 0.000176 → ceil=1
iops → 300/1000  = 0.3      → ceil=1
Disks = 1

SSD (NVMe)
cap → 0.0066/30 = 0.00022 → ceil=1
thr → 0.088/3000 = 0.000029 → ceil=1
iops → 300/10000 = 0.03     → ceil=1
Disks = 1
Итог (Комментарии): HDD 3, SATA 1, NVMe 1.

3. Реакции
# Входные величины
capacity = 14.6 GB = 0.0146 TB
rps = 500
payload = 0.1 KB

# Производные
traffic_per_second = 500 * 0.1 KB = 50 KB/s ≈ 0.049 MB/s
iops = 500

HDD
cap  = 0.0146 / 32  = 0.000456 → ceil=1
thr  = 0.049 / 100  = 0.00049  → ceil=1
iops = 500 / 100    = 5        → ceil=5
Disks = max(1,1,5) = 5

SSD (SATA)
cap → 0.0146/100 = 0.000146 → ceil=1
thr → 0.049/500  = 0.000098 → ceil=1
iops → 500/1000  = 0.5      → ceil=1
Disks = 1

SSD (NVMe)
cap → 0.0146/30 = 0.000487 → ceil=1
thr → 0.049/3000 = 0.000016 → ceil=1
iops → 500/10000 = 0.05     → ceil=1
Disks = 1
Итог (Реакции): HDD 5, SATA 1, NVMe 1.

без фото:
HDD   : Посты 8 + Комменты 3 + Реакции 5 = 16 дисков
SSD   : по 1 диску на подсистему = 3 диска
NVMe  : по 1 диску на подсистему = 3 диска

Допущения по фото

Фото храним в Object Storage (S3/MinIO/Ceph).

Постов в год = 7.3 млн.

Фото/пост = 3 шт.

Средний размер фото = 1 MB (оригинал) + 0.15 MB превью = 1.15 MB/фото.

Общий размер на пост = 3 × 1.15 MB ≈ 3.45 MB/пост.

Итого за день: 20 000 × 3.45 MB = 69 GB/день.

За год: 69 × 365 ≈ 25.2 TB.

Расчёты по дискам для медиа
Входные данные

Capacity = 25.2 TB/год

Payload на операцию загрузки = 1 MB (средний файл).

RPS (на запись фото):
Постов 20k/день × 3 фото = 60k фото/день → ~0.7 фото/сек (низкий write RPS).

RPS (на чтение фото):
60k × 100 = 6 млн запросов/день ≈ 70 фото/сек

HDD (32TB, 100 MB/s, 100 IOPS)

Capacity: 25.2 / 32 ≈ 0.79 → 1 диск

Throughput: 70 req/s × 1 MB = 70 MB/s → 70/100 = 0.7 → 1 диск

IOPS: 70 / 100 = 0.7 → 1 диск
Итог: 1 HDD на 1 год фото (OLTP без репликации)

SSD SATA (100TB, 500 MB/s, 1000 IOPS)

Capacity: 25.2 / 100 ≈ 0.25 → 1 диск

Throughput: 70 / 500 = 0.14 → 1 диск

IOPS: 70 / 1000 = 0.07 → 1 диск
Итог: 1 SATA SSD

NVMe (30TB, 3000 MB/s, 10k IOPS)

Capacity: 25.2 / 30 ≈ 0.84 → 1 диск

Throughput: 70 / 3000 = 0.023 → 1 диск

IOPS: 70 / 10 000 = 0.007 → 1 диск
Итог: 1 NVMe

итого:

OLTP (PostgreSQL):

Посты - HDD: 8, SSD SATA: 1, NVMe: 1

Комментарии - HDD: 3, SSD SATA: 1, NVMe: 1

Реакции - HDD: 5, SSD SATA: 1, NVMe: 1

Object Storage (Фото/медиа):

Фото - HDD: 1, SSD SATA: 1, NVMe: 1

Итого по системе:

HDD: 17

SSD SATA: 4

NVMe: 4
