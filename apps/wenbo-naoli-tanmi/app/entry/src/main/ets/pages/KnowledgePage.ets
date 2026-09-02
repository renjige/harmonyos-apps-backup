import { Theme } from '../components/design-system/Theme'
import { BrainMedia } from '../services/BrainMedia'
import { BrainNav } from '../services/BrainNav'
import { BrainBizService } from '../services/BrainBizService'
import { ArticleItem } from '../models/BrainModels'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppError } from '../components/design-system/AppError'

@Component
export struct KnowledgePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State all: ArticleItem[] = []
  @State shown: ArticleItem[] = []
  @State keyword: string = ''
  @State tag: string = '全部'
  @State err: string = ''

  aboutToAppear(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.err = ''
    const list = await BrainBizService.loadArticles()
    this.all = list
    this.apply()
    if (list.length === 0) {
      this.err = BrainBizService.lastHint()
    }
  }

  private apply(): void {
    const out: ArticleItem[] = []
    for (const a of this.all) {
      const tagOk = this.tag === '全部' || a.categoryLabel === this.tag
      const keyOk = this.keyword.length === 0 || a.title.indexOf(this.keyword) >= 0 || a.summary.indexOf(this.keyword) >= 0
      if (tagOk && keyOk) {
        out.push(a)
      }
    }
    this.shown = out
  }

  build() {
    Column({ space: 10 }) {
      Text('智慧知识库')
        .fontSize(22)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: 16, right: 16, top: 12 })
      TextInput({ text: this.keyword, placeholder: '搜索预设图文' })
        .onChange((v: string) => {
          this.keyword = v
          this.apply()
        })
        .height(44)
        .margin({ left: 16, right: 16 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
      Row({ space: 8 }) {
        this.Tag('全部')
        this.Tag('训练技巧')
        this.Tag('认知科普')
        this.Tag('生活习惯')
      }
      .padding({ left: 16, right: 16 })
      if (this.shown.length === 0) {
        if (this.err.length > 0) {
          AppError({ retryLabel: '重试', onRetry: () => { void this.reload() } })
        } else {
          AppEmpty({ title: '没有匹配条目', description: '换个关键词或分类', actionLabel: '重置', onAction: () => {
            this.keyword = ''
            this.tag = '全部'
            this.apply()
          } })
        }
      } else {
        List() {
          ForEach(this.shown, (a: ArticleItem) => {
            ListItem() {
              Row({ space: 10 }) {
                Image(BrainMedia.cover(a.coverKey))
                  .width(88)
                  .height(72)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(10)
                Column({ space: 4 }) {
                  Text(a.title)
                    .fontSize(15)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(2)
                  Text(`${a.categoryLabel} · ${a.readMinutes} 分钟`)
                    .fontSize(12)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                  Text(a.summary)
                    .fontSize(13)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                    .maxLines(2)
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
              }
              .width('100%')
              .padding(12)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(14)
              .onClick(() => BrainNav.open(BrainNav.ARTICLE, a.id))
            }
            .margin({ left: 16, right: 16, bottom: 10 })
          }, (a: ArticleItem) => a.id)
        }
        .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }

  @Builder
  Tag(name: string) {
    Text(name)
      .fontSize(13)
      .fontColor(this.tag === name ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
      .padding({ left: 10, right: 10, top: 6, bottom: 6 })
      .backgroundColor(this.tag === name ? Theme.colors().brandPrimary : Theme.colors().surfaceCard)
      .borderRadius(8)
      .onClick(() => {
        this.tag = name
        this.apply()
      })
  }
}
