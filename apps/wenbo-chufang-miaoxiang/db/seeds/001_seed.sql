-- Seed for review / local wiring (business titles only)
INSERT INTO users (id, username, password_hash, display_name, role)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  'auditor@yuanxiang.local',
  'REPLACE_WITH_BCRYPT',
  '审核演示账号',
  'manager'
) ON CONFLICT (username) DO NOTHING;

INSERT INTO projects (id, name, code, address, status, manager_id) VALUES
  ('11111111-1111-1111-1111-111111111111', '滨江综合体一期', 'BJ-A1', '滨江大道 88 号', 'active', '00000000-0000-0000-0000-000000000001'),
  ('22222222-2222-2222-2222-222222222222', '城南保障房项目', 'CN-B2', '城南路 16 号', 'active', '00000000-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;

INSERT INTO inspections (id, project_id, title, location_text, status, severity, inspector_id, findings) VALUES
  ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', '基坑支护日常巡查', '基坑东侧坡面', 'submitted', 'medium', '00000000-0000-0000-0000-000000000001', '坡面排水沟局部淤积，需清理并复查。'),
  ('44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', '外脚手架连墙件复核', '3 号楼 12 层', 'rectifying', 'high', '00000000-0000-0000-0000-000000000001', '个别连墙件间距超标，已开整改单。')
ON CONFLICT DO NOTHING;

INSERT INTO issues (id, inspection_id, title, description, severity, status) VALUES
  ('55555555-5555-5555-5555-555555555555', '44444444-4444-4444-4444-444444444444', '连墙件间距超标', '12 层北侧两处连墙件间距超过方案要求，存在坠落风险。', 'high', 'in_progress')
ON CONFLICT DO NOTHING;

INSERT INTO messages (user_id, title, body, type, read) VALUES
  ('00000000-0000-0000-0000-000000000001', '今日厨房灵感', '试试番茄鸡蛋焖面，十几分钟就能完成。', 'kitchen', FALSE),
  ('00000000-0000-0000-0000-000000000001', '清单提醒', '做饭前可以先确认厨房清单。', 'list', TRUE);
