import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { CourseListCard } from '../components/career/CourseListCard'
import { LearnCalendarStrip } from '../components/career/LearnCalendarStrip'
import { CourseItem, EnrollmentItem, ActivityEnrollmentItem } from '../models/CareerModels'
import { CareerBizService } from '../services/CareerBizService'
import { CareerDetailNav } from '../services/CareerDetailNav'
import { LearnProgressService } from '../services/LearnProgressService'
import { AuthService } from '../services/AuthService'

class FilterChip {
  label: string = ''
  value: string = ''

  static all(): FilterChip[] {
    const out: FilterChip[] = []
    const f0 = new FilterChip()
    f0.label = '全部'
    f0.value = ''
    out.push(f0)
    const labels: string[] = ['职场技能', '管理能力', '沟通表达', '职业规划']
    for (let lb of labels) {
      const f = new FilterChip()
      f.label = lb
      f.value = lb
      out.push(f)
    }
    return out
  }
}

@Component
export struct LearnPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State courses: CourseItem[] = []
  @State enrollments: EnrollmentItem[] = []
  @State activityEnrollments: ActivityEnrollmentItem[] = []
  @State loading: boolean = true
  @State filter: string = ''
  @State segment: number = 0
  @StorageLink('careerTick') @Watch('onTick') careerTick: number = 0
  @StorageLink('progressTick') @Watch('onTick') progressTick: number = 0
  @StorageLink('learnFilterCategory') learnFilterCategory: string = ''
  @StorageLink('learnFilterTeacher') learnFilterTeacher: string = ''
  @StorageLink('accessToken') accessToken: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    if (this.learnFilterCategory.length > 0) {
      this.filter = this.learnFilterCategory
      AppStorage.setOrCreate('learnFilterCategory', '')
    }
    void this.reload()
  }

  onTick(): void {
    void this.reloadEnrollments()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private username(): string {
    const u = AppStorage.get<string>('currentUsername')
    return u !== undefined && u !== null ? u : ''
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.courses = await CareerBizService.loadCourses(this.filter)
    await this.reloadEnrollments()
    this.loading = false
  }

  private async reloadEnrollments(): Promise<void> {
    if (!this.isLoggedIn()) {
      this.enrollments = []
      this.activityEnrollments = []
      return
    }
    const user = this.username()
    this.enrollments = await CareerBizService.loadEnrollments(user)
    this.activityEnrollments = await CareerBizService.loadActivityEnrollments(user)
  }

  private async deleteActivityEnrollment(id: string): Promise<void> {
    const ok = await CareerBizService.deleteActivityEnrollment(id)
    if (ok) {
      CareerDetailNav.bump()
    }
  }

  private filteredCourses(): CourseItem[] {
    const teacherId = this.learnFilterTeacher
    if (teacherId.length === 0) {
      return this.courses
    }
    const out: CourseItem[] = []
    for (let c of this.courses) {
      if (c.teacherId === teacherId) {
        out.push(c)
      }
    }
    return out
  }

  private learningCourses(): CourseItem[] {
    const started = LearnProgressService.listStarted()
    const out: CourseItem[] = []
    for (let p of started) {
      const found = CareerBizService.findCourse(this.courses, p.courseId)
      if (found !== undefined) {
        out.push(found)
      }
    }
    return out
  }

  private async deleteEnrollment(id: string): Promise<void> {
    const ok = await CareerBizService.deleteEnrollment(id)
    if (ok) {
      CareerDetailNav.bump()
    }
  }

  build() {
    Column() {
      AppHeader({ title: '学习', subtitle: '我的进度 · 课程目录' })
      Row({ space: Theme.space.s2 }) {
        Text('我的学习')
          .fontSize(Theme.type.subhead)
          .fontWeight(this.segment === 0 ? FontWeight.Medium : FontWeight.Normal)
          .fontColor(this.segment === 0 ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
          .padding({ left: Theme.space.s4, right: Theme.space.s4, top: 8, bottom: 8 })
          .backgroundColor(this.segment === 0 ? Theme.colors().brandPrimaryContainer : Color.Transparent)
          .borderRadius(Theme.radius.pill)
          .onClick(() => { this.segment = 0 })
        Text('课程目录')
          .fontSize(Theme.type.subhead)
          .fontWeight(this.segment === 1 ? FontWeight.Medium : FontWeight.Normal)
          .fontColor(this.segment === 1 ? Theme.colors().brandPrimary : Theme.colors().textSecondary)
          .padding({ left: Theme.space.s4, right: Theme.space.s4, top: 8, bottom: 8 })
          .backgroundColor(this.segment === 1 ? Theme.colors().brandPrimaryContainer : Color.Transparent)
          .borderRadius(Theme.radius.pill)
          .onClick(() => { this.segment = 1 })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s2 })

      if (this.segment === 1) {
        Scroll() {
          Row({ space: Theme.space.s2 }) {
            ForEach(FilterChip.all(), (chip: FilterChip) => {
              Text(chip.label)
                .fontSize(Theme.type.caption)
                .fontColor(this.filter === chip.value ?
                  Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.filter === chip.value ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick(() => {
                  this.filter = chip.value
                  void this.reload()
                })
            }, (chip: FilterChip) => chip.value.length > 0 ? chip.value : 'all')
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.loading) {
            Text('加载中…')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          } else if (this.segment === 0) {
            LearnCalendarStrip()
            if (this.learningCourses().length === 0) {
              AppEmpty({
                title: '暂无学习记录',
                description: '在课程详情中记录进度，或报名后开始学习',
                actionLabel: '浏览课程',
                onAction: (): void => { this.segment = 1 }
              })
            } else {
              ForEach(this.learningCourses(), (c: CourseItem) => {
                CourseListCard({
                  item: c,
                  showProgress: true,
                  onTap: (): void => CareerDetailNav.openLearn(c.id)
                })
              }, (c: CourseItem) => c.id)
            }
            if (this.isLoggedIn()) {
              Text('我的报名')
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
                .margin({ top: Theme.space.s4 })
              if (this.enrollments.length === 0) {
                AppEmpty({
                  title: '暂无报名',
                  description: '浏览课程并提交报名后在此查看',
                  actionLabel: '去选课',
                  onAction: (): void => { this.segment = 1 }
                })
              } else {
                ForEach(this.enrollments, (e: EnrollmentItem) => {
                  Column({ space: Theme.space.s2 }) {
                    Text(e.courseTitle)
                      .fontSize(Theme.type.subhead)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .width('100%')
                    Text(`状态：${e.status} · ${e.createdAt}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                    AppButton({
                      label: '取消报名',
                      variant: 'secondary',
                      onTap: (): void => { void this.deleteEnrollment(e.id) }
                    })
                  }
                  .width('100%')
                  .padding(Theme.space.s4)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                  .border({ width: 1, color: Theme.colors().strokeHairline })
                }, (e: EnrollmentItem) => e.id)
              }
              if (this.activityEnrollments.length > 0) {
                Text('活动报名')
                  .fontSize(Theme.type.subtitleS)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .width('100%')
                  .margin({ top: Theme.space.s4 })
                ForEach(this.activityEnrollments, (e: ActivityEnrollmentItem) => {
                  Column({ space: Theme.space.s2 }) {
                    Text(e.activityTitle)
                      .fontSize(Theme.type.subhead)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                      .width('100%')
                    Text(`状态：${e.status}`)
                      .fontSize(Theme.type.caption)
                      .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                      .width('100%')
                    AppButton({
                      label: '取消报名',
                      variant: 'secondary',
                      onTap: (): void => { void this.deleteActivityEnrollment(e.id) }
                    })
                  }
                  .width('100%')
                  .padding(Theme.space.s4)
                  .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.lg)
                  .border({ width: 1, color: Theme.colors().strokeHairline })
                }, (e: ActivityEnrollmentItem) => e.id)
              }
            } else {
              AppButton({
                label: '登录查看报名记录',
                onTap: (): void => this.onRequireAuth()
              })
            }
          } else {
            if (this.filteredCourses().length === 0) {
              AppEmpty({
                title: '暂无课程',
                description: '请切换分类或检查网络',
                actionLabel: '重试',
                onAction: (): void => { void this.reload() }
              })
            } else {
              ForEach(this.filteredCourses(), (c: CourseItem) => {
                CourseListCard({
                  item: c,
                  showProgress: false,
                  onTap: (): void => CareerDetailNav.open('course', c.id)
                })
              }, (c: CourseItem) => c.id)
            }
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
