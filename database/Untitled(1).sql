CREATE TABLE "users" (
  "id" uuid PRIMARY KEY,
  "email" varchar(320) UNIQUE NOT NULL,
  "display_name" varchar(100) NOT NULL,
  "avatar_url" varchar(500),
  "bio" text,
  "created_at" timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE "places" (
  "id" uuid PRIMARY KEY,
  "name" varchar(200) NOT NULL,
  "country" varchar(100),
  "region" varchar(100),
  "city" varchar(100),
  "lat" decimal(9,6),
  "lon" decimal(9,6),
  "popularity" int DEFAULT 0,
  "created_at" timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE "posts" (
  "id" uuid PRIMARY KEY,
  "author_id" uuid NOT NULL,
  "place_id" uuid NOT NULL,
  "description" text NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (now()),
  "updated_at" timestamp
);

CREATE TABLE "post_media" (
  "id" uuid PRIMARY KEY,
  "post_id" uuid NOT NULL,
  "media_url" varchar(1000) NOT NULL,
  "kind" varchar(20) NOT NULL,
  "width" int,
  "height" int,
  "size_bytes" bigint,
  "thumb_url" varchar(1000),
  "created_at" timestamp NOT NULL DEFAULT (now())
);

CREATE TABLE "reactions" (
  "post_id" uuid NOT NULL,
  "user_id" uuid NOT NULL,
  "kind" varchar(10) NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (now()),
  PRIMARY KEY ("post_id", "user_id")
);

CREATE TABLE "comments" (
  "id" uuid PRIMARY KEY,
  "post_id" uuid NOT NULL,
  "author_id" uuid NOT NULL,
  "text" text NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (now()),
  "updated_at" timestamp
);

CREATE TABLE "follows" (
  "follower_id" uuid NOT NULL,
  "followee_id" uuid NOT NULL,
  "created_at" timestamp NOT NULL DEFAULT (now()),
  PRIMARY KEY ("follower_id", "followee_id")
);

CREATE TABLE "feed_home" (
  "user_id" uuid NOT NULL,
  "post_id" uuid NOT NULL,
  "author_id" uuid NOT NULL,
  "created_at" timestamp NOT NULL,
  PRIMARY KEY ("user_id", "post_id")
);

CREATE TABLE "place_post_index" (
  "place_id" uuid NOT NULL,
  "post_id" uuid NOT NULL,
  "created_at" timestamp NOT NULL,
  PRIMARY KEY ("place_id", "post_id")
);

CREATE INDEX ON "places" ("popularity");

CREATE INDEX ON "places" ("name");

CREATE INDEX ON "posts" ("author_id", "created_at");

CREATE INDEX ON "posts" ("place_id", "created_at");

CREATE INDEX ON "posts" ("created_at");

CREATE INDEX ON "post_media" ("post_id");

CREATE INDEX ON "reactions" ("user_id", "created_at");

CREATE INDEX ON "comments" ("post_id", "created_at");

CREATE INDEX ON "comments" ("author_id", "created_at");

CREATE INDEX ON "follows" ("followee_id", "created_at");

CREATE INDEX ON "feed_home" ("user_id", "created_at");

CREATE INDEX ON "place_post_index" ("place_id", "created_at");

COMMENT ON TABLE "users" IS 'Пользователь';

COMMENT ON COLUMN "users"."id" IS 'User id';

COMMENT ON TABLE "places" IS 'Место путешествия';

COMMENT ON COLUMN "places"."id" IS 'Place id';

COMMENT ON TABLE "posts" IS 'Пост с описанием и привязкой к месту';

COMMENT ON COLUMN "posts"."id" IS 'Post id';

COMMENT ON COLUMN "posts"."author_id" IS 'users.id';

COMMENT ON COLUMN "posts"."place_id" IS 'places.id';

COMMENT ON TABLE "post_media" IS 'Файлы медиа поста';

COMMENT ON COLUMN "post_media"."post_id" IS 'posts.id';

COMMENT ON COLUMN "post_media"."media_url" IS 'URL в Object Storage';

COMMENT ON COLUMN "post_media"."kind" IS 'image|video';

COMMENT ON TABLE "reactions" IS 'Реакции (1 реакция на пользователя и пост)';

COMMENT ON COLUMN "reactions"."post_id" IS 'posts.id';

COMMENT ON COLUMN "reactions"."user_id" IS 'users.id';

COMMENT ON COLUMN "reactions"."kind" IS 'LIKE|DISLIKE';

COMMENT ON TABLE "comments" IS 'Комментарии к постам';

COMMENT ON COLUMN "comments"."post_id" IS 'posts.id';

COMMENT ON COLUMN "comments"."author_id" IS 'users.id';

COMMENT ON TABLE "follows" IS 'Подписки: follower -> followee';

COMMENT ON COLUMN "follows"."follower_id" IS 'users.id';

COMMENT ON COLUMN "follows"."followee_id" IS 'users.id';

COMMENT ON TABLE "feed_home" IS 'Материализованная домашняя лента (fan-out-on-write)';

COMMENT ON COLUMN "feed_home"."user_id" IS 'владелец ленты (users.id)';

COMMENT ON COLUMN "feed_home"."post_id" IS 'posts.id';

COMMENT ON COLUMN "feed_home"."author_id" IS 'users.id';

COMMENT ON COLUMN "feed_home"."created_at" IS 'время публикации поста';

COMMENT ON TABLE "place_post_index" IS 'Индекс для быстрых выборок постов по месту';

COMMENT ON COLUMN "place_post_index"."place_id" IS 'places.id';

COMMENT ON COLUMN "place_post_index"."post_id" IS 'posts.id';

ALTER TABLE "posts" ADD FOREIGN KEY ("author_id") REFERENCES "users" ("id");

ALTER TABLE "posts" ADD FOREIGN KEY ("place_id") REFERENCES "places" ("id");

ALTER TABLE "post_media" ADD FOREIGN KEY ("post_id") REFERENCES "posts" ("id");

ALTER TABLE "reactions" ADD FOREIGN KEY ("post_id") REFERENCES "posts" ("id");

ALTER TABLE "reactions" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "comments" ADD FOREIGN KEY ("post_id") REFERENCES "posts" ("id");

ALTER TABLE "comments" ADD FOREIGN KEY ("author_id") REFERENCES "users" ("id");

ALTER TABLE "follows" ADD FOREIGN KEY ("follower_id") REFERENCES "users" ("id");

ALTER TABLE "follows" ADD FOREIGN KEY ("followee_id") REFERENCES "users" ("id");

ALTER TABLE "feed_home" ADD FOREIGN KEY ("user_id") REFERENCES "users" ("id");

ALTER TABLE "feed_home" ADD FOREIGN KEY ("post_id") REFERENCES "posts" ("id");

ALTER TABLE "feed_home" ADD FOREIGN KEY ("author_id") REFERENCES "users" ("id");

ALTER TABLE "place_post_index" ADD FOREIGN KEY ("place_id") REFERENCES "places" ("id");

ALTER TABLE "place_post_index" ADD FOREIGN KEY ("post_id") REFERENCES "posts" ("id");
