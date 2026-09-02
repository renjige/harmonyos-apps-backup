import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { CourseItem, KpiItem, TeacherItem, ArticleItem, ActivityItem } from '../models/CareerModels'
import { CareerBizService } from '../services/CareerBizService'
import { CareerDetailNav } from '../services/CareerDetailNav'
import {
  CareerHeroBanner,
  CareerKpiStrip,
  CareerQuickGrid,
  CareerWisdomBanner,
  CareerRecommendCard,
  CareerCategoryTile,
  CategoryTileItem,
  CareerTeacherCard,
  CareerArticleRow,
  CareerActivityRow,
  CareerSectionHeader
} from '../components/career/CareerHomeSections'

@Component
export struct HomePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop company: string = '职途教育科技有限公司'
  @Prop appName: string = '职业课堂'
  @Prop tagline: string = ''
  @State courses: CourseItem[] = []
  @State teachers: TeacherItem[] = []
  @State articles: ArticleItem[] = []
  @State activities: ActivityItem[] = []
  @State kpis: KpiItem[] = []
  @State loading: boolean = true
  @StorageLink('careerTick') careerTick: number = 0
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    const all = await Promise.all([
      CareerBizService.loadCourses(),
      CareerBizService.loadTeachers(),
      CareerBizService.loadArticles(),
      CareerBizService.loadActivities(),
      CareerBizService.loadKpis()
    ])
    this.courses = all[0]
    this.teachers = all[1]
    this.articles = all[2]
    this.activities = all[3]
    this.kpis = all[4]
    this.loading = false
  }

  private recommendCourses(): CourseItem[] {
    const out: CourseItem[] = []
    let n = 0
    for (let c of this.courses) {
      if (n >= 8) break
      out.push(c)
      n = n + 1
    }
    return out
  }

  private onQuick(action: string): void {
    if (action === 'learn' || action === 'catalog') {
      AppStorage.setOrCreate('mainTab', 1)
      if (action === 'catalog') {
        AppStorage.setOrCreate('learnFilterCategory', '')
      }
      return
    }
    if (action === 'fav') {
      AppStorage.setOrCreate('mainTab', 2)
      return
    }
    if (action === 'wisdom') {
      CareerDetailNav.openBare('wisdom')
    }
  }

  build() {
    Scroll() {
      Column({ space: Theme.space.s5 }) {
        Column() {
          CareerHeroBanner({
            appName: this.appName,
            tagline: this.tagline.length > 0 ? this.tagline : '面向职场人士的职业能力提升平台',
            company: this.company,
            onSearch: (): void => CareerDetailNav.openBare('search')
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s4 }) {
          CareerKpiStrip({
            kpis: this.kpis,
            courseCount: this.courses.length,
            teacherCount: this.teachers.length
          })
          CareerQuickGrid({ onTap: (a: string): void => this.onQuick(a) })
          CareerWisdomBanner({
            onTap: (): void => CareerDetailNav.openBare('wisdom')
          })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        Column({ space: Theme.space.s3 }) {
          CareerSectionHeader({
            title: '智慧推荐',
            action: '查看全部',
            onAction: (): void => {
              AppStorage.setOrCreate('mainTab', 1)
            }
          })
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

          if (this.loading) {
            AppLoading().padding({ top: Theme.space.s4 })
          } else if (this.recommendCourses().length === 0) {
            AppEmpty({
              title: '暂无课程',
              description: '请检查网络连接后重试',
              actionLabel: '重新加载',
              onAction: (): void => { void this.reload() }
            }).padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          } else {
            Scroll() {
              Row({ space: Theme.space.s3 }) {
                ForEach(this.recommendCourses(), (c: CourseItem) => {
                  CareerRecommendCard({
                    item: c,
                    onTap: (): void => CareerDetailNav.open('course', c.id)
                  })
                }, (c: CourseItem) => c.id)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }
        }
        .width('100%')

        Column({ space: Theme.space.s3 }) {
          CareerSectionHeader({
            title: '课程分类',
            action: '进入学习',
            onAction: (): void => {
              AppStorage.setOrCreate('mainTab', 1)
            }
          })
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          GridRow({ columns: 2, gutter: Theme.space.s3 }) {
            ForEach(CategoryTileItem.career(), (tile: CategoryTileItem) => {
              GridCol() {
                CareerCategoryTile({
                  tile: tile,
                  onTap: (): void => {
                    AppStorage.setOrCreate('learnFilterCategory', tile.key)
                    AppStorage.setOrCreate('mainTab', 1)
                  }
                })
              }
            }, (tile: CategoryTileItem) => tile.key)
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }
        .width('100%')

        if (this.teachers.length > 0) {
          Column({ space: Theme.space.s3 }) {
            CareerSectionHeader({ title: '明星讲师', action: '' })
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            Scroll() {
              Row({ space: Theme.space.s4 }) {
                ForEach(this.teachers, (t: TeacherItem) => {
                  CareerTeacherCard({
                    item: t,
                    onTap: (): void => CareerDetailNav.open('teacher', t.id)
                  })
                }, (t: TeacherItem) => t.id)
              }
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            }
            .scrollable(ScrollDirection.Horizontal)
            .scrollBar(BarState.Off)
            .width('100%')
          }
          .width('100%')
        }

        if (this.activities.length > 0) {
          Column({ space: Theme.space.s3 }) {
            CareerSectionHeader({ title: '线下活动', action: '' })
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            Column({ space: Theme.space.s3 }) {
              ForEach(this.activities, (a: ActivityItem) => {
                CareerActivityRow({
                  item: a,
                  onTap: (): void => CareerDetailNav.open('activity', a.id)
                })
              }, (a: ActivityItem) => a.id)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
          .width('100%')
        }

        if (this.articles.length > 0) {
          Column({ space: Theme.space.s3 }) {
            CareerSectionHeader({ title: '职场资讯', action: '更多' })
              .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
            Column({ space: Theme.space.s3 }) {
              ForEach(this.articles, (a: ArticleItem) => {
                CareerArticleRow({
                  item: a,
                  onTap: (): void => CareerDetailNav.open('article', a.id)
                })
              }, (a: ArticleItem) => a.id)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
          .width('100%')
        }
      }
      .padding({ top: Theme.space.pageY, bottom: Theme.space.s10 })
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
    .edgeEffect(EdgeEffect.Spring)
  }
}
