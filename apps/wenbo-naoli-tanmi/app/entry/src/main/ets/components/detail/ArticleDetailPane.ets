import { Theme } from '../design-system/Theme'
import { DetailShell } from './DetailShell'
import { BrainMedia } from '../../services/BrainMedia'
import { BrainNav } from '../../services/BrainNav'
import { BrainBizService } from '../../services/BrainBizService'
import { BrainProgress } from '../../services/BrainProgress'
import { ArticleItem } from '../../models/BrainModels'
import { AppEmpty } from '../design-system/AppEmpty'

@Component
export struct ArticleDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('brainEntityId') entityId: string = ''
  @State item: ArticleItem = new ArticleItem()
  @State ready: boolean = false

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    const row = await BrainBizService.resolveArticle(this.entityId)
    if (row !== undefined) {
      this.item = row
      await BrainProgress.markRead(row.id)
    }
    this.ready = true
  }

  build() {
    Column() {
      DetailShell({ title: '知识详情', onBack: () => BrainNav.close() })
      if (!this.ready) {
        Text('加载中').fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).padding(20)
      } else if (this.item.id.length === 0) {
        AppEmpty({ title: '未找到条目', description: '请返回重试', actionLabel: '返回', onAction: () => BrainNav.close() })
      } else {
        Scroll() {
          Column({ space: 14 }) {
            Stack() {
              Image(BrainMedia.cover(this.item.coverKey))
                .width('100%')
                .height(200)
                .objectFit(ImageFit.Cover)
              Column()
                .width('100%')
                .height(200)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0.08)', 0], ['rgba(10,22,40,0.88)', 1]]
                })
              Text(this.item.title)
                .fontSize(20)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .width('100%')
                .padding({ left: 16, right: 16, bottom: 16 })
            }
            .width('100%')
            .height(200)

            Text(`${this.item.categoryLabel} · ${this.item.readMinutes} 分钟阅读`)
              .fontSize(13)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
              .padding({ left: 16, right: 16 })

            Column({ space: 6 }) {
              Text('导语').fontSize(14).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              Text(this.item.summary)
                .fontSize(16)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(24)
            }
            .width('100%')
            .padding(16)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(16)
            .margin({ left: 16, right: 16 })

            Text(this.item.body)
              .fontSize(16)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .lineHeight(24)
              .width('100%')
              .padding({ left: 16, right: 16, bottom: Theme.space.s10 })
          }
          .width('100%')
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
