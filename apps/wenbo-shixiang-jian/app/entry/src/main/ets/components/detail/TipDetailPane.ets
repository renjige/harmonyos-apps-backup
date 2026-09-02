import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { AppLoading } from '../design-system/AppLoading'
import { DetailShell } from './DetailShell'
import { TaskItem } from '../../models/TaskModels'
import { TaskBizService } from '../../services/TaskBizService'
import { TaskMedia } from '../../services/TaskMedia'
import { TaskDetailNav } from '../../services/TaskDetailNav'

@Component
export struct TipDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @Prop @Watch('onItemIdChange') refreshToken: number = 0
  @State item: TaskItem | undefined = undefined
  @State loading: boolean = true
  @State loadFailed: boolean = false

  aboutToAppear(): void {
    void this.loadItem()
  }

  onItemIdChange(): void {
    void this.loadItem()
  }

  private async loadItem(): Promise<void> {
    this.loading = true
    this.loadFailed = false
    this.item = await TaskBizService.findTip(this.itemId)
    if (this.item === undefined) {
      this.loadFailed = true
    }
    this.loading = false
  }

  build() {
    DetailShell({
      title: '效率贴士',
      onClose: (): void => { TaskDetailNav.close() },
      body: (): void => { this.DetailBody() }
    })
  }

  @Builder
  DetailBody() {
    if (this.loading) {
      AppLoading({ label: '加载贴士…' })
    } else if (this.loadFailed || this.item === undefined) {
      Column({ space: Theme.space.s4 }) {
        AppEmpty({
          title: '暂时无法加载',
          description: '贴士可能已被删除或网络异常',
          actionLabel: '重试',
          onAction: (): void => { void this.loadItem() }
        })
        AppButton({
          label: '返回',
          variant: 'secondary',
          onTap: (): void => { TaskDetailNav.close() }
        })
      }
      .width('100%')
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
    } else {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          if (TaskMedia.coverResource(this.item.coverKey) !== undefined) {
            Image(TaskMedia.coverResource(this.item.coverKey))
              .width('100%')
              .height(200)
              .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
              .objectFit(ImageFit.Cover)
          } else {
            Column()
              .width('100%')
              .height(200)
              .linearGradient({
                angle: 135,
                colors: [[TaskMedia.heroGradient(this.item.coverKey)[0], 0],
                  [TaskMedia.heroGradient(this.item.coverKey)[1], 1]]
              })
              .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          }
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(15,23,42,0)', 0], ['rgba(15,23,42,0.78)', 1]]
            })
            .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
          Column({ space: 4 }) {
            if (this.item.subtitle.length > 0) {
              Text(this.item.subtitle)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnInverse)
            }
            Text(this.item.title)
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Bold)
              .fontColor(Theme.colors().textOnInverse)
            if (this.item.readMinutes > 0) {
              Text(`约 ${this.item.readMinutes} 分钟阅读`)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().textOnInverse)
            }
          }
          .padding(Theme.space.s5)
          .alignItems(HorizontalAlign.Start)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })

        if (this.item.summary.length > 0) {
          Column() {
            AppCard({ title: '摘要', variant: 'plain' }) {
              Text(this.item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            }
          }
          .width('100%')
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
        }

        Column() {
          AppCard({ title: '正文', variant: 'plain' }) {
            Text(this.item.body.length > 0 ? this.item.body : '（无正文）')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
              .lineHeight(24)
          }
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
      }
    }
  }
}
