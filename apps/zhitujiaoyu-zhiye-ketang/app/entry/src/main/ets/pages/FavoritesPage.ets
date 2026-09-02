import { Theme } from '../components/design-system/Theme'
import { AppHeader } from '../components/design-system/AppHeader'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppButton } from '../components/design-system/AppButton'
import { CourseListCard } from '../components/career/CourseListCard'
import { CourseItem } from '../models/CareerModels'
import { CareerBizService } from '../services/CareerBizService'
import { CareerDetailNav } from '../services/CareerDetailNav'
import { FavoriteService } from '../services/FavoriteService'

@Component
export struct FavoritesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State courses: CourseItem[] = []
  @State favCourses: CourseItem[] = []
  @State loading: boolean = true
  @StorageLink('favoriteTick') @Watch('onFavTick') favoriteTick: number = 0
  @StorageLink('accessToken') accessToken: string = ''
  onRequireAuth: () => void = () => {}

  aboutToAppear(): void {
    void this.reload()
  }

  onFavTick(): void {
    void this.applyFavorites()
  }

  private isLoggedIn(): boolean {
    return this.accessToken.length > 0
  }

  private async reload(): Promise<void> {
    this.loading = true
    this.courses = await CareerBizService.loadCourses()
    this.applyFavorites()
    this.loading = false
  }

  private applyFavorites(): void {
    const ids = FavoriteService.listIds()
    const out: CourseItem[] = []
    for (let id of ids) {
      const found = CareerBizService.findCourse(this.courses, id)
      if (found !== undefined) {
        out.push(found)
      }
    }
    this.favCourses = out
  }

  build() {
    Column() {
      AppHeader({ title: '收藏', subtitle: '我收藏的职业课程' })
      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (!this.isLoggedIn()) {
            AppEmpty({
              title: '登录后同步收藏',
              description: '游客可先浏览；收藏课程需登录',
              actionLabel: '登录 / 注册',
              onAction: (): void => this.onRequireAuth()
            })
          } else if (this.loading) {
            Text('加载中…')
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          } else if (this.favCourses.length === 0) {
            AppEmpty({
              title: '暂无收藏',
              description: '在课程详情页点击「收藏课程」',
              actionLabel: '去选课',
              onAction: (): void => {
                AppStorage.setOrCreate('mainTab', 1)
              }
            })
          } else {
            ForEach(this.favCourses, (c: CourseItem) => {
              CourseListCard({
                item: c,
                showProgress: false,
                onTap: (): void => CareerDetailNav.open('course', c.id)
              })
            }, (c: CourseItem) => c.id)
            AppButton({
              label: '刷新列表',
              variant: 'secondary',
              onTap: (): void => { void this.reload() }
            })
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
