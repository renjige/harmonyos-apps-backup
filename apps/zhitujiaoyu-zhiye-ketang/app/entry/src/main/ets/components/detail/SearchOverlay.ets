import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { AppEmpty } from '../design-system/AppEmpty'
import { CourseListCard } from '../career/CourseListCard'
import { CourseItem, TeacherItem, ArticleItem } from '../../models/CareerModels'
import { CareerBizService } from '../../services/CareerBizService'
import { CareerDetailNav } from '../../services/CareerDetailNav'
import { DetailShell } from './DetailShell'

@Component
export struct SearchOverlay {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State query: string = ''
  @State courses: CourseItem[] = []
  @State teachers: TeacherItem[] = []
  @State articles: ArticleItem[] = []
  @State loaded: boolean = false

  aboutToAppear(): void {
    const q = AppStorage.get<string>('searchQuery')
    if (q !== undefined && q !== null) {
      this.query = q
    }
    void this.search()
  }

  private match(text: string, q: string): boolean {
    if (q.length === 0) {
      return true
    }
    return text.indexOf(q) >= 0
  }

  private async search(): Promise<void> {
    const all = await Promise.all([
      CareerBizService.loadCourses(),
      CareerBizService.loadTeachers(),
      CareerBizService.loadArticles()
    ])
    const q = this.query.trim()
    const courseOut: CourseItem[] = []
    for (let c of all[0]) {
      if (this.match(c.title, q) || this.match(c.category, q) || this.match(c.summary, q)) {
        courseOut.push(c)
      }
    }
    const teacherOut: TeacherItem[] = []
    for (let t of all[1]) {
      if (this.match(t.title, q) || this.match(t.specialty, q)) {
        teacherOut.push(t)
      }
    }
    const articleOut: ArticleItem[] = []
    for (let a of all[2]) {
      if (this.match(a.title, q) || this.match(a.summary, q)) {
        articleOut.push(a)
      }
    }
    this.courses = courseOut
    this.teachers = teacherOut
    this.articles = articleOut
    this.loaded = true
  }

  build() {
    DetailShell({
      title: '搜索',
      onBack: () => CareerDetailNav.close()
    }) {
      Column({ space: Theme.space.s3 }) {
        Row({ space: Theme.space.s2 }) {
          AppIcon({ name: 'search', iconSize: Theme.icon.sm })
          TextInput({ text: this.query, placeholder: '课程 / 讲师 / 资讯' })
            .layoutWeight(1)
            .onChange((v: string) => { this.query = v })
            .onSubmit(() => { void this.search() })
        }
        .width('100%')
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX
        })

        Scroll() {
          Column({ space: Theme.space.s3 }) {
            if (this.loaded && this.courses.length === 0 && this.teachers.length === 0 &&
              this.articles.length === 0) {
              AppEmpty({
                title: '无匹配结果',
                description: '换个关键词试试',
                actionLabel: '重新搜索',
                onAction: (): void => { void this.search() }
              })
            }
            if (this.courses.length > 0) {
              Text('课程')
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.courses, (c: CourseItem) => {
                CourseListCard({
                  item: c,
                  onTap: (): void => CareerDetailNav.open('course', c.id)
                })
              }, (c: CourseItem) => c.id)
            }
            if (this.teachers.length > 0) {
              Text('讲师')
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.teachers, (t: TeacherItem) => {
                Row({ space: Theme.space.s3 }) {
                  Text(t.title)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .layoutWeight(1)
                  AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick(() => CareerDetailNav.open('teacher', t.id))
              }, (t: TeacherItem) => t.id)
            }
            if (this.articles.length > 0) {
              Text('资讯')
                .fontSize(Theme.type.subtitleS)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
              ForEach(this.articles, (a: ArticleItem) => {
                Row({ space: Theme.space.s3 }) {
                  Text(a.title)
                    .fontSize(Theme.type.subhead)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .layoutWeight(1)
                  AppIcon({ name: 'chevron', iconSize: Theme.icon.sm })
                }
                .width('100%')
                .padding(Theme.space.s3)
                .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.lg)
                .onClick(() => CareerDetailNav.open('article', a.id))
              }, (a: ArticleItem) => a.id)
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
      }
      .width('100%')
      .layoutWeight(1)
    }
  }
}
