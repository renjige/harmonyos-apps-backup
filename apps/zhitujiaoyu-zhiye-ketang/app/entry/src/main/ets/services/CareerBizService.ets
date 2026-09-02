import { HttpClient } from './HttpClient'
import {
  ActivityItem,
  ActivityListData,
  ActivityListWire,
  ActivityWire,
  ArticleItem,
  ArticleListData,
  ArticleListWire,
  ArticleWire,
  CourseItem,
  CourseListData,
  CourseListWire,
  CourseWire,
  DeleteResult,
  ActivityEnrollBody,
  ActivityEnrollmentItem,
  ActivityEnrollmentListWire,
  ActivityEnrollmentWire,
  EnrollmentCreateBody,
  EnrollmentItem,
  EnrollmentListData,
  EnrollmentListWire,
  EnrollmentWire,
  KpiItem,
  KpiListData,
  KpiListWire,
  KpiWire,
  TeacherItem,
  TeacherListData,
  TeacherListWire,
  TeacherWire
} from '../models/CareerModels'

/**
 * 栏目数据走平台 /biz/art-education/*；失败返回空列表，禁止 localSeed。
 */
export class CareerBizService {
  static async loadCourses(category: string = ''): Promise<CourseItem[]> {
    let path = '/biz/art-education/courses'
    if (category.length > 0) {
      path = `${path}?category=${encodeURIComponent(category)}`
    }
    const res = await HttpClient.get<CourseListWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      return CareerBizService.mapCourses(res.data.list)
    }
    return []
  }

  static async loadCourseById(id: string): Promise<CourseItem | undefined> {
    const res = await HttpClient.get<CourseWire>(`/biz/art-education/courses/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CareerBizService.mapCourse(res.data)
    }
    const list = await CareerBizService.loadCourses()
    return CareerBizService.findCourse(list, id)
  }

  static async loadTeachers(): Promise<TeacherItem[]> {
    const res = await HttpClient.get<TeacherListWire>('/biz/art-education/teachers')
    if (res.code === 0 && res.data !== undefined) {
      return CareerBizService.mapTeachers(res.data.list)
    }
    return []
  }

  static async loadTeacherById(id: string): Promise<TeacherItem | undefined> {
    const res = await HttpClient.get<TeacherWire>(`/biz/art-education/teachers/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CareerBizService.mapTeacher(res.data)
    }
    const list = await CareerBizService.loadTeachers()
    return CareerBizService.findTeacher(list, id)
  }

  static async loadArticles(category: string = ''): Promise<ArticleItem[]> {
    let path = '/biz/art-education/articles'
    if (category.length > 0) {
      path = `${path}?category=${encodeURIComponent(category)}`
    }
    const res = await HttpClient.get<ArticleListWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      return CareerBizService.mapArticles(res.data.list)
    }
    return []
  }

  static async loadArticleById(id: string): Promise<ArticleItem | undefined> {
    const res = await HttpClient.get<ArticleWire>(`/biz/art-education/articles/${id}`)
    if (res.code === 0 && res.data !== undefined) {
      return CareerBizService.mapArticle(res.data)
    }
    const list = await CareerBizService.loadArticles()
    return CareerBizService.findArticle(list, id)
  }

  static async loadActivities(): Promise<ActivityItem[]> {
    const res = await HttpClient.get<ActivityListWire>('/biz/art-education/activities')
    if (res.code === 0 && res.data !== undefined) {
      return CareerBizService.mapActivities(res.data.list)
    }
    return []
  }

  static async loadActivityById(id: string): Promise<ActivityItem | undefined> {
    const list = await CareerBizService.loadActivities()
    return CareerBizService.findActivity(list, id)
  }

  static async loadKpis(): Promise<KpiItem[]> {
    const res = await HttpClient.get<KpiListWire>('/biz/art-education/kpis')
    if (res.code === 0 && res.data !== undefined) {
      return CareerBizService.mapKpis(res.data.items)
    }
    return []
  }

  static async loadEnrollments(username: string): Promise<EnrollmentItem[]> {
    if (username.length === 0) {
      return []
    }
    const path = `/biz/art-education/enrollments?username=${encodeURIComponent(username)}`
    const res = await HttpClient.get<EnrollmentListWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      return CareerBizService.mapEnrollments(res.data.list)
    }
    return []
  }

  static async submitEnrollment(body: EnrollmentCreateBody): Promise<EnrollmentItem | undefined> {
    const res = await HttpClient.post<EnrollmentWire>('/biz/art-education/enrollments', body)
    if (res.code === 0 && res.data !== undefined) {
      return CareerBizService.mapEnrollment(res.data)
    }
    return undefined
  }

  static async deleteEnrollment(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteResult>(`/biz/art-education/enrollments/${id}`)
    return res.code === 0
  }

  static async loadActivityEnrollments(username: string): Promise<ActivityEnrollmentItem[]> {
    if (username.length === 0) {
      return []
    }
    const path = `/biz/art-education/activity-enrollments?username=${encodeURIComponent(username)}`
    const res = await HttpClient.get<ActivityEnrollmentListWire>(path)
    if (res.code === 0 && res.data !== undefined) {
      return CareerBizService.mapActivityEnrollments(res.data.list)
    }
    return []
  }

  static async submitActivityEnrollment(body: ActivityEnrollBody): Promise<ActivityEnrollmentItem | undefined> {
    const res = await HttpClient.post<ActivityEnrollmentWire>('/biz/art-education/activity-enrollments', body)
    if (res.code === 0 && res.data !== undefined) {
      return CareerBizService.mapActivityEnrollment(res.data)
    }
    return undefined
  }

  static async deleteActivityEnrollment(id: string): Promise<boolean> {
    const res = await HttpClient.delete<DeleteResult>(`/biz/art-education/activity-enrollments/${id}`)
    return res.code === 0
  }

  static findCourse(list: CourseItem[], id: string): CourseItem | undefined {
    for (let c of list) {
      if (c.id === id) {
        return c
      }
    }
    return undefined
  }

  static findTeacher(list: TeacherItem[], id: string): TeacherItem | undefined {
    for (let t of list) {
      if (t.id === id) {
        return t
      }
    }
    return undefined
  }

  static findArticle(list: ArticleItem[], id: string): ArticleItem | undefined {
    for (let a of list) {
      if (a.id === id) {
        return a
      }
    }
    return undefined
  }

  static findActivity(list: ActivityItem[], id: string): ActivityItem | undefined {
    for (let a of list) {
      if (a.id === id) {
        return a
      }
    }
    return undefined
  }

  private static mapCourses(rows: CourseWire[]): CourseItem[] {
    const out: CourseItem[] = []
    for (let w of rows) {
      out.push(CareerBizService.mapCourse(w))
    }
    return out
  }

  private static mapCourse(w: CourseWire): CourseItem {
    const c = new CourseItem()
    c.id = w.id
    c.title = w.title
    c.category = w.category
    c.level = w.level
    c.teacherId = w.teacherId
    c.teacherName = w.teacherName
    c.duration = w.duration
    c.summary = w.summary
    c.description = w.description.length > 0 ? w.description : w.summary
    c.coverKey = w.coverKey
    c.status = w.status
    return c
  }

  private static mapTeachers(rows: TeacherWire[]): TeacherItem[] {
    const out: TeacherItem[] = []
    for (let w of rows) {
      out.push(CareerBizService.mapTeacher(w))
    }
    return out
  }

  private static mapTeacher(w: TeacherWire): TeacherItem {
    const t = new TeacherItem()
    t.id = w.id
    t.title = w.title
    t.specialty = w.specialty
    t.years = w.years
    t.bio = w.bio.length > 0 ? w.bio : w.summary
    t.summary = w.summary.length > 0 ? w.summary : w.bio
    t.coverKey = w.coverKey
    return t
  }

  private static mapArticles(rows: ArticleWire[]): ArticleItem[] {
    const out: ArticleItem[] = []
    for (let w of rows) {
      out.push(CareerBizService.mapArticle(w))
    }
    return out
  }

  private static mapArticle(w: ArticleWire): ArticleItem {
    const a = new ArticleItem()
    a.id = w.id
    a.title = w.title
    a.category = w.category
    a.summary = w.summary
    a.body = w.body
    a.readMinutes = w.readMinutes
    a.coverKey = w.coverKey
    return a
  }

  private static mapActivities(rows: ActivityWire[]): ActivityItem[] {
    const out: ActivityItem[] = []
    for (let w of rows) {
      out.push(CareerBizService.mapActivity(w))
    }
    return out
  }

  private static mapActivity(w: ActivityWire): ActivityItem {
    const a = new ActivityItem()
    a.id = w.id
    a.title = w.title
    a.type = w.type
    a.startAt = w.startAt
    a.endAt = w.endAt
    a.venue = w.venue
    a.capacity = w.capacity
    a.summary = w.summary
    a.description = w.description.length > 0 ? w.description : w.summary
    a.status = w.status
    a.coverKey = w.coverKey
    return a
  }

  private static mapEnrollments(rows: EnrollmentWire[]): EnrollmentItem[] {
    const out: EnrollmentItem[] = []
    for (let w of rows) {
      out.push(CareerBizService.mapEnrollment(w))
    }
    return out
  }

  private static mapEnrollment(w: EnrollmentWire): EnrollmentItem {
    const e = new EnrollmentItem()
    e.id = w.id
    e.courseId = w.courseId
    e.courseTitle = w.courseTitle
    e.userId = w.userId
    e.name = w.name
    e.phone = w.phone
    e.remark = w.remark
    e.status = w.status
    e.createdAt = w.createdAt
    return e
  }

  private static mapActivityEnrollments(rows: ActivityEnrollmentWire[]): ActivityEnrollmentItem[] {
    const out: ActivityEnrollmentItem[] = []
    for (let w of rows) {
      out.push(CareerBizService.mapActivityEnrollment(w))
    }
    return out
  }

  private static mapActivityEnrollment(w: ActivityEnrollmentWire): ActivityEnrollmentItem {
    const e = new ActivityEnrollmentItem()
    e.id = w.id
    e.activityId = w.activityId
    e.activityTitle = w.activityTitle
    e.userId = w.userId
    e.name = w.name
    e.phone = w.phone
    e.status = w.status
    e.createdAt = w.createdAt
    return e
  }

  private static mapKpis(rows: KpiWire[]): KpiItem[] {
    const out: KpiItem[] = []
    for (let w of rows) {
      const k = new KpiItem()
      k.key = w.key
      k.label = w.label
      k.value = w.value
      out.push(k)
    }
    return out
  }
}
