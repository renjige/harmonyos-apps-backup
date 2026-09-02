import { Theme } from '../components/design-system/Theme'
import { AppIcon, AppIconName } from '../components/design-system/AppIcon'
import { HomePage } from './HomePage'
import { LearnPage } from './LearnPage'
import { FavoritesPage } from './FavoritesPage'
import { MinePage } from './MinePage'
import { AIAssistantPage } from './AIAssistantPage'
import { AuthService } from '../services/AuthService'
import { CareerDetailNav } from '../services/CareerDetailNav'
import { CareerBizService } from '../services/CareerBizService'
import { CourseItem, TeacherItem, ArticleItem, ActivityItem } from '../models/CareerModels'
import { CourseDetailPane } from '../components/detail/CourseDetailPane'
import { CourseLearnPane } from '../components/detail/CourseLearnPane'
import { TeacherDetailPane } from '../components/detail/TeacherDetailPane'
import { ArticleDetailPane } from '../components/detail/ArticleDetailPane'
import { ActivityDetailPane } from '../components/detail/ActivityDetailPane'
import { EnrollFormOverlay } from '../components/detail/EnrollFormOverlay'
import { ActivityEnrollOverlay } from '../components/detail/ActivityEnrollOverlay'
import { SearchOverlay } from '../components/detail/SearchOverlay'

class TabItem {
  index: number = 0
  name: AppIconName = 'home'
  label: string = ''

  static all(): TabItem[] {
    const tabs: TabItem[] = []
    const t0 = new TabItem()
    t0.index = 0
    t0.name = 'home'
    t0.label = '首页'
    tabs.push(t0)
    const t1 = new TabItem()
    t1.index = 1
    t1.name = 'chart'
    t1.label = '学习'
    tabs.push(t1)
    const t2 = new TabItem()
    t2.index = 2
    t2.name = 'ai'
    t2.label = '收藏'
    tabs.push(t2)
    const t3 = new TabItem()
    t3.index = 3
    t3.name = 'user'
    t3.label = '我的'
    tabs.push(t3)
    return tabs
  }
}

/** 四 Tab：首页 | 学习 | 收藏 | 我的；详情 Overlay 顶层 + tabBarHidden */
@Component
export struct MainTabPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State current: number = 0
  @StorageLink('tabBarHidden') tabBarHidden: boolean = false
  @StorageLink('careerRoute') @Watch('onRoute') route: string = ''
  @StorageLink('mainTab') @Watch('onMainTab') mainTab: number = 0
  @Prop company: string = '职途教育科技有限公司'
  @Prop appName: string = '职业课堂'
  @Prop tagline: string = ''
  @State course: CourseItem = new CourseItem()
  @State teacher: TeacherItem = new TeacherItem()
  @State article: ArticleItem = new ArticleItem()
  @State activity: ActivityItem = new ActivityItem()
  onOpenLogin: () => void = () => {}
  onLogout: () => void = () => {}
  onRequireAuth: () => void = () => {}
  private tabs: TabItem[] = TabItem.all()

  aboutToAppear(): void {
    this.current = this.mainTab
  }

  onMainTab(): void {
    this.current = this.mainTab
  }

  onRoute(): void {
    void this.resolveRoute()
  }

  private kind(): string {
    return CareerDetailNav.kindOf(this.route)
  }

  private async resolveRoute(): Promise<void> {
    const kind = this.kind()
    const id = CareerDetailNav.idOf(this.route)
    if (kind === 'course') {
      const row = await CareerBizService.loadCourseById(id)
      if (row !== undefined) {
        this.course = row
      }
    }
    if (kind === 'teacher') {
      const row = await CareerBizService.loadTeacherById(id)
      if (row !== undefined) {
        this.teacher = row
      }
    }
    if (kind === 'article') {
      const row = await CareerBizService.loadArticleById(id)
      if (row !== undefined) {
        this.article = row
      }
    }
    if (kind === 'activity') {
      const row = await CareerBizService.loadActivityById(id)
      if (row !== undefined) {
        this.activity = row
      }
    }
    if (kind === 'learn') {
      const row = await CareerBizService.loadCourseById(id)
      if (row !== undefined) {
        this.course = row
      }
    }
  }

  build() {
    Stack() {
      Column() {
        if (this.current === 0) {
          HomePage({
            company: this.company,
            appName: this.appName,
            tagline: this.tagline,
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 1) {
          LearnPage({
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        } else if (this.current === 2) {
          FavoritesPage({
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        } else {
          MinePage({
            appName: this.appName,
            onOpenLogin: () => this.onOpenLogin(),
            onLogout: () => {
              AuthService.logout()
              this.onLogout()
            },
            onRequireAuth: () => this.onRequireAuth()
          }).layoutWeight(1)
        }

        if (!this.tabBarHidden) {
          Row() {
            ForEach(this.tabs, (t: TabItem) => {
              this.TabBarItem(t)
            }, (t: TabItem) => `${t.index}`)
          }
          .width('100%')
          .height(Theme.nav.tabHeight)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .border({ width: { top: 1 }, color: Theme.colors().strokeHairline })
          .shadow({ radius: 16, color: 'rgba(26,42,108,0.06)', offsetY: -4, offsetX: 0 })
        }
      }
      .width('100%')
      .height('100%')

      if (this.kind() === 'enroll') {
        EnrollFormOverlay({ courseId: CareerDetailNav.idOf(this.route) })
          .width('100%').height('100%')
      } else if (this.kind() === 'activityEnroll') {
        ActivityEnrollOverlay({ activityId: CareerDetailNav.idOf(this.route) })
          .width('100%').height('100%')
      } else if (this.kind() === 'search') {
        SearchOverlay().width('100%').height('100%')
      } else if (this.kind() === 'wisdom') {
        AIAssistantPage({
          onRequireAuth: () => this.onRequireAuth(),
          onBookFromAi: (_c: string) => {
            CareerDetailNav.close()
            AppStorage.setOrCreate('mainTab', 1)
          }
        }).width('100%').height('100%')
      } else if (this.kind() === 'course') {
        CourseDetailPane({
          item: this.course,
          onRequireAuth: () => this.onRequireAuth()
        }).width('100%').height('100%')
      } else if (this.kind() === 'learn') {
        CourseLearnPane({ item: this.course }).width('100%').height('100%')
      } else if (this.kind() === 'teacher') {
        TeacherDetailPane({ item: this.teacher }).width('100%').height('100%')
      } else if (this.kind() === 'article') {
        ArticleDetailPane({ item: this.article }).width('100%').height('100%')
      } else if (this.kind() === 'activity') {
        ActivityDetailPane({
          item: this.activity,
          onRequireAuth: () => this.onRequireAuth()
        }).width('100%').height('100%')
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  TabBarItem(t: TabItem) {
    Column({ space: 2 }) {
      Column() {
        AppIcon({
          name: t.name,
          iconSize: Theme.icon.md,
          color: this.current === t.index ?
            Theme.colors().brandPrimary : Theme.colors().textSecondary
        })
      }
      .width(48)
      .height(28)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.current === t.index ?
        Theme.colors().brandPrimaryContainer : 'transparent')
      .borderRadius(Theme.radius.pill)
      Text(t.label)
        .fontSize(Theme.type.overline)
        .fontWeight(this.current === t.index ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.current === t.index ?
          Theme.colors().brandPrimary : Theme.colors().textSecondary)
    }
    .layoutWeight(1)
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 4, bottom: 4 })
    .onClick(() => {
      AppStorage.setOrCreate('tabBarHidden', false)
      AppStorage.setOrCreate('mainTab', t.index)
      this.current = t.index
    })
  }
}
