/** 职业课堂 — art-education API 客户端模型 */

export class CourseItem {
  id: string = ''
  title: string = ''
  category: string = ''
  level: string = ''
  teacherId: string = ''
  teacherName: string = ''
  duration: string = ''
  summary: string = ''
  description: string = ''
  coverKey: string = ''
  status: string = ''
}

export class TeacherItem {
  id: string = ''
  title: string = ''
  specialty: string = ''
  years: number = 0
  bio: string = ''
  summary: string = ''
  coverKey: string = ''
}

export class ArticleItem {
  id: string = ''
  title: string = ''
  category: string = ''
  summary: string = ''
  body: string = ''
  readMinutes: number = 0
  coverKey: string = ''
}

export class ActivityItem {
  id: string = ''
  title: string = ''
  type: string = ''
  startAt: string = ''
  endAt: string = ''
  venue: string = ''
  capacity: number = 0
  summary: string = ''
  description: string = ''
  status: string = ''
  coverKey: string = ''
}

export class EnrollmentItem {
  id: string = ''
  courseId: string = ''
  courseTitle: string = ''
  userId: string = ''
  name: string = ''
  phone: string = ''
  remark: string = ''
  status: string = ''
  createdAt: string = ''
}

export class KpiItem {
  key: string = ''
  label: string = ''
  value: number = 0
}

export class CourseListData {
  list: CourseItem[] = []
}

export class TeacherListData {
  list: TeacherItem[] = []
}

export class ArticleListData {
  list: ArticleItem[] = []
}

export class ActivityListData {
  list: ActivityItem[] = []
}

export class EnrollmentListData {
  list: EnrollmentItem[] = []
}

export class KpiListData {
  items: KpiItem[] = []
}

export class EnrollmentCreateBody {
  courseId: string = ''
  name: string = ''
  phone: string = ''
  remark: string = ''
  username: string = ''

  toJsonString(): string {
    return `{"courseId":${JSON.stringify(this.courseId)},"name":${JSON.stringify(this.name)},` +
      `"phone":${JSON.stringify(this.phone)},"remark":${JSON.stringify(this.remark)},` +
      `"username":${JSON.stringify(this.username)}}`
  }
}

export class CourseWire {
  id: string = ''
  title: string = ''
  category: string = ''
  level: string = ''
  teacherId: string = ''
  teacherName: string = ''
  duration: string = ''
  summary: string = ''
  description: string = ''
  coverKey: string = ''
  status: string = ''
}

export class TeacherWire {
  id: string = ''
  title: string = ''
  specialty: string = ''
  years: number = 0
  bio: string = ''
  summary: string = ''
  coverKey: string = ''
}

export class ArticleWire {
  id: string = ''
  title: string = ''
  category: string = ''
  summary: string = ''
  body: string = ''
  readMinutes: number = 0
  coverKey: string = ''
}

export class ActivityWire {
  id: string = ''
  title: string = ''
  type: string = ''
  startAt: string = ''
  endAt: string = ''
  venue: string = ''
  capacity: number = 0
  summary: string = ''
  description: string = ''
  status: string = ''
  coverKey: string = ''
}

export class EnrollmentWire {
  id: string = ''
  courseId: string = ''
  courseTitle: string = ''
  userId: string = ''
  name: string = ''
  phone: string = ''
  remark: string = ''
  status: string = ''
  createdAt: string = ''
}

export class KpiWire {
  key: string = ''
  label: string = ''
  value: number = 0
}

export class CourseListWire {
  list: CourseWire[] = []
}

export class TeacherListWire {
  list: TeacherWire[] = []
}

export class ArticleListWire {
  list: ArticleWire[] = []
}

export class ActivityListWire {
  list: ActivityWire[] = []
}

export class EnrollmentListWire {
  list: EnrollmentWire[] = []
}

export class KpiListWire {
  items: KpiWire[] = []
}

export class DeleteResult {
  deleted: boolean = false
}

export class CourseChapterItem {
  index: number = 0
  title: string = ''
  kind: string = 'text'
  body: string = ''
  durationMin: number = 0
}

export class ActivityEnrollBody {
  activityId: string = ''
  name: string = ''
  phone: string = ''
  remark: string = ''
  username: string = ''

  toJsonString(): string {
    return `{"activityId":${JSON.stringify(this.activityId)},"name":${JSON.stringify(this.name)},` +
      `"phone":${JSON.stringify(this.phone)},"remark":${JSON.stringify(this.remark)},` +
      `"username":${JSON.stringify(this.username)}}`
  }
}

export class ActivityEnrollmentItem {
  id: string = ''
  activityId: string = ''
  activityTitle: string = ''
  userId: string = ''
  name: string = ''
  phone: string = ''
  status: string = ''
  createdAt: string = ''
}

export class ActivityEnrollmentWire {
  id: string = ''
  activityId: string = ''
  activityTitle: string = ''
  userId: string = ''
  name: string = ''
  phone: string = ''
  status: string = ''
  createdAt: string = ''
}

export class ActivityEnrollmentListWire {
  list: ActivityEnrollmentWire[] = []
}

export class BadgeItem {
  id: string = ''
  title: string = ''
  description: string = ''
  unlocked: boolean = false
  iconName: string = 'check'
}

export class WeekDayCell {
  label: string = ''
  dateKey: string = ''
  minutes: number = 0
  studied: boolean = false
  isToday: boolean = false
}
