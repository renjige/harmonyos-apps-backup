import { Theme } from '../components/design-system/Theme'
import { AppIcon } from '../components/design-system/AppIcon'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppLoading } from '../components/design-system/AppLoading'
import { TaskListCard } from '../components/task/TaskListCard'
import { StatsData, TaskItem } from '../models/TaskModels'
import { TaskBizService } from '../services/TaskBizService'
import { TaskDetailNav } from '../services/TaskDetailNav'
import { AuthService } from '../services/AuthService'

@Component
export struct HistoryPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onClose: () => void = () => {}
  @Prop @Watch('onRefreshTokenChange') refreshToken: number = 0
  @State completed: TaskItem[] = []
  @State stats: StatsData = new StatsData()
  @State loading: boolean = true
  @StorageLink('currentUsername') currentUsername: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  onRefreshTokenChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.loading = true
    if (AuthService.isLoggedIn()) {
      this.completed = await TaskBizService.loadCompleted(this.currentUsername)
      this.stats = await TaskBizService.loadStats(this.currentUsername)
    } else {
      this.completed = []
      this.stats = new StatsData()
    }
    this.loading = false
  }

  build() {
    Column() {
      Row({ space: Theme.space.s2 }) {
        Column() {
          AppIcon({ name: 'chevron', iconSize: Theme.icon.md })
        }
        .width(44)
        .height(44)
        .justifyContent(FlexAlign.Center)
        .rotate({ angle: 180 })
        .onClick((): void => this.onClose())
        Text('完成记录')
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: Theme.space.pageX - 8, right: Theme.space.pageX, top: Theme.space.s2 })

      Row({ space: Theme.space.s4 }) {
        Column({ space: 4 }) {
          Text(`${this.stats.totalDone}`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(Theme.colors().success)
          Text('累计完成')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
        }
        .layoutWeight(1)
        Column({ space: 4 }) {
          Text(`${this.stats.completionRate}%`)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          Text('今日完成率')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textTertiary)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .padding(Theme.space.s5)
      .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      .borderRadius(Theme.radius.xl)
      .border({ width: 1, color: Theme.colors().strokeHairline })

      Scroll() {
        Column({ space: Theme.space.s3 }) {
          if (this.loading) {
            AppLoading({ variant: 'skeleton' })
          } else if (this.completed.length === 0) {
            AppEmpty({
              title: '暂无完成记录',
              description: AuthService.isLoggedIn() ? '完成事项后将显示在这里' : '登录后可查看个人完成记录'
            })
          } else {
            ForEach(this.completed, (item: TaskItem) => {
              TaskListCard({
                item: item,
                onTap: (): void => { TaskDetailNav.openTask(item.id, item) }
              })
            }, (item: TaskItem) => item.id)
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s4,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
