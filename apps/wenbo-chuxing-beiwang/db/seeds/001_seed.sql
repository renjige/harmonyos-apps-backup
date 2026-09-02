-- 商户栏目模板种子；用户行程、清单、提醒与备忘保持为空。
CREATE TABLE IF NOT EXISTS trip_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(128) NOT NULL,
  summary TEXT,
  days INT NOT NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'published'
);

CREATE TABLE IF NOT EXISTS checklist_presets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category VARCHAR(32) NOT NULL,
  title VARCHAR(128) NOT NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'published'
);

INSERT INTO trip_templates (title, summary, days) VALUES
  ('城市周末', '适合两天一夜的城市漫游与轻量安排。', 2),
  ('家庭度假', '围绕住宿、交通和家庭用品整理出行准备。', 5),
  ('商务出行', '集中记录交通、入住、会议与证件事项。', 3);

INSERT INTO checklist_presets (category, title) VALUES
  ('证件', '身份证件'),
  ('证件', '交通凭证'),
  ('衣物', '换洗衣物'),
  ('衣物', '舒适鞋履'),
  ('设备', '手机充电器'),
  ('设备', '移动电源'),
  ('用品', '洗护用品'),
  ('用品', '常用药品');
