@startuml
!includeurl https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml
LAYOUT_WITH_LEGEND()

Person(user,  "Путешественник", "Публикует посты с фото и местами, ставит лайки/дизлайки, пишет комментарии, смотрит ленты.")
Person(admin, "Администратор",  "Модерация контента и пользователей.")

System(travel, "TravelFeed", "Соцсеть для путешественников: посты с фото и местами, комментарии, реакции, подписки, ленты и поиск популярных мест.")

System_Ext(s3,   "S3-совместимое хранилище", "Файлы медиа (фото/видео).")
System_Ext(cdn,  "CDN", "Раздача медиа пользователям.")
System_Ext(maps, "Картографический сервис", "Геокодирование/поиск мест.")
System_Ext(email,"E-mail/SMS провайдер", "Почта/смс-уведомления.")
System_Ext(push, "Push провайдер (FCM/APNs)", "Пуш-уведомления на устройства.")

Rel(user,  travel, "Создаёт/читает контент", "HTTPS/JSON")
Rel(admin, travel, "Модерирует", "HTTPS/JSON")

Rel(travel, s3,   "Загрузка/чтение по presigned URL", "S3 API")
Rel(user,   cdn,  "Скачивает медиа", "HTTPS")
Rel(travel, cdn,  "Инвалидация кэша", "API")
Rel(travel, maps, "Поиск мест/геокодирование", "HTTPS")
Rel(travel, email,"Отправка уведомлений", "HTTP/SMTP")
Rel(travel, push, "Пуш-уведомления", "HTTP/JSON")

SHOW_LEGEND()
@enduml


@startuml
!includeurl https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Container.puml
 

Person(user,  "Путешественник", "Мобильное и веб-приложение.")
Person(admin, "Администратор",  "Модерация.")

System_Boundary(sys, "TravelFeed") {

  Container(web,    "Web SPA",       "React/TS", "Веб-интерфейс. JWT.")
  Container(mobile, "Mobile App",    "iOS/Android", "Клиент с оффлайн-кэшем (SQLite).")

  Container(api,     "API Gateway / BFF", "Node.js/Go", "Точка входа, аутентификация, агрегация.")
  Container(auth,    "Auth Service",      "Keycloak/Custom", "Регистрация/логин, JWT/refresh.")
  Container(userSvc, "User Service",      "Go/Java", "Профили пользователей.")
  Container(social,  "SocialGraph Service","Go/Java", "Подписки (follow/unfollow).")
  Container(post,    "Post Service",      "Go/Java", "Посты, метаданные фото (post_media).")
  Container(media,   "Media Service",     "Go/Java", "Presigned URL для загрузки/чтения из S3.")
  Container(comment, "Comment Service",   "Go/Java", "Комментарии.")
  Container(react,   "Reaction Service",  "Go/Java", "Лайки/дизлайки, счётчики.")
  Container(feed,    "Feed Service",      "Go/Java", "Fan-out-on-write, формирование лент.")
  Container(place,   "Place Service",     "Go/Java", "Справочник мест, популярность.")
  Container(notify,  "Notification Service","Go/Java","E-mail/SMS/Push по событиям.")

  Container(redis, "Redis Cluster", "Redis", "Кэш лент feed:{user_id} и счётчиков post:stats.")
  Container(kafka, "Event Bus",     "Kafka", "PostCreated/CommentCreated/ReactionUpdated.")
  ContainerDb(usersDb,   "UsersDB",   "PostgreSQL", "Пользователи.")
  ContainerDb(followsDb, "FollowsDB", "PostgreSQL", "Подписки.")
  ContainerDb(postsDb,   "PostsDB Cluster",   "PostgreSQL", "Посты/post_media (2 шарда × RF=3).")
  ContainerDb(comDb,     "CommentsDB Cluster","PostgreSQL", "Комментарии (2 шарда × RF=3).")
  ContainerDb(reactDb,   "ReactionsDB Cluster","PostgreSQL","Реакции (2 шарда × RF=3).")
  ContainerDb(feedDb,    "FeedDB",    "PostgreSQL", "Материализованные ленты (feed_home).")
  ContainerDb(placesDb,  "PlacesDB",  "PostgreSQL", "Места/координаты.")
  Container(s3,   "Object Storage", "S3-совместимое", "Фото/видео объекты.")
  Container(cdn,  "CDN",            "Edge", "Раздача медиа.")

  Container_Ext(maps,  "Картографический сервис", "External", "Геокодирование/Places API.")
  Container_Ext(email, "E-mail/SMS провайдер",    "External", "Рассылка уведомлений.")
  Container_Ext(push,  "Push-провайдер (FCM/APNs)","External","Пуш-уведомления.")
}

Rel(user,   web,    "Использует", "HTTPS")
Rel(user,   mobile, "Использует", "HTTPS")
Rel(admin,  api,    "Модерация",  "HTTPS")
Rel(web,    api, "REST/JSON")
Rel(mobile, api, "REST/JSON")

Rel(api, auth,    "Логин/refresh, валидация JWT", "HTTPS")
Rel(api, userSvc, "Профиль", "gRPC/HTTP")
Rel(api, social,  "Follow/Unfollow, списки", "gRPC/HTTP")
Rel(api, post,    "CRUD постов (метаданные)", "gRPC/HTTP")
Rel(api, media,   "Presigned URL", "HTTP")
Rel(api, comment, "CRUD комментариев", "gRPC/HTTP")
Rel(api, react,   "Лайк/дизлайк", "gRPC/HTTP")
Rel(api, feed,    "Домашняя/авторская ленты", "gRPC/HTTP")
Rel(api, place,   "Поиск/популярные места", "gRPC/HTTP")

Rel(userSvc, usersDb,   "CRUD")
Rel(social,  followsDb, "CRUD")
Rel(post,    postsDb,   "CRUD")
Rel(comment, comDb,     "CRUD")
Rel(react,   reactDb,   "CRUD")
Rel(feed,    feedDb,    "Запись/чтение feed_home")
Rel(place,   placesDb,  "CRUD")

Rel(media, s3,  "Выдаёт presigned PUT/GET", "S3 API")
Rel(user,  cdn, "Читает фото/видео", "HTTPS")
Rel(s3,    cdn, "Origin pull / инвалидация", "HTTP")

Rel(post,    kafka, "PostCreated", "Avro/JSON")
Rel(comment, kafka, "CommentCreated", "Avro/JSON")
Rel(react,   kafka, "ReactionUpdated", "Avro/JSON")
Rel(kafka,   feed,  "Подписан (fan-out)")

Rel(feed,  redis, "Кэш лент feed:{user_id}", "ZSET")
Rel(react, redis, "Счётчики post:stats", "HASH")
Rel(place, redis, "Кэш hot:places", "ZSET")

Rel(place, maps,   "Геокодирование/Places", "HTTPS")
Rel(kafka, notify, "События → уведомления")
Rel(notify, email, "E-mail/SMS", "HTTP/SMTP")
Rel(notify, push,  "Push", "HTTP/JSON")

legend right
  == Потоки данных (вкратце)
  1. Публикация поста → PostsDB → событие PostCreated → Feed Service
     → материализация в FeedDB → кэш ленты в Redis.
  2. Фото: Media Service выдаёт presigned URL → клиент грузит в S3 → раздача через CDN.
  3. Реакции/Комментарии: запись в DB → событие в Kafka → счётчики в Redis и уведомления.
endlegend
@enduml
