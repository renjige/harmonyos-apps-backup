import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { CourtyardBizService } from '../services/CourtyardBizService'
import { CourtyardDetailNav } from '../services/CourtyardDetailNav'
import { CourtyardMedia } from '../services/CourtyardMedia'
import { ArticleItem, PoemItem } from '../models/CourtyardModels'
import { PoemListCard } from '../components/courtyard/PoemListCard'

@Component
export struct AppreciatePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @State articles: ArticleItem[] = []
  @State daily: PoemItem = new PoemItem()
  @State related: PoemItem[] = []

  aboutToAppear(): void {
    void this.load()
  }

  private async load(): Promise<void> {
    this.articles = await CourtyardBizService.loadArticles()
    const d = await CourtyardBizService.loadDaily()
    if (d !== undefined) {
      this.daily = d
      this.related = await CourtyardBizService.loadPoems('', d.dynasty, '', '')
      const filtered: PoemItem[] = []
      for (const p of this.related) {
        if (p.id !== d.id) {
          filtered.push(p)
        }
      }
      this.related = filtered
    }
  }

  build() {
    Column() {
      Text('智慧品读')
        .fontSize(Theme.type.title2)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.s4 })
      Text('笺注 · 背景 · 评点 · 译文 · 关联')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
        .padding({ left: Theme.space.pageX, bottom: Theme.space.s3 })

      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('今日精读入口').fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
          if (this.daily.id.length > 0) {
            PoemListCard({
              poemId: this.daily.id,
              title: this.daily.title,
              meta: this.daily.metaLine(),
              summary: '点开可读笺注、背景、评点与白话译诗',
              coverKey: this.daily.coverKey,
              onOpen: (id: string): void => { CourtyardDetailNav.openPoem(id) }
            })
          }

          Text('赏析入门').fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
          if (this.articles.length === 0) {
            AppEmpty({ title: '暂无文章', description: '请稍后重试', actionLabel: '重试', onAction: (): void => { void this.load() } })
          }
          ForEach(this.articles, (a: ArticleItem) => {
            Row({ space: Theme.space.s3 }) {
              Image(CourtyardMedia.cover(a.coverKey))
                .width(72)
                .height(72)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.sm)
              Column({ space: 4 }) {
                Text(a.category).fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary).width('100%')
                Text(a.title).fontSize(Theme.type.bodyM).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).maxLines(1).width('100%')
                Text(a.summary).fontSize(Theme.type.caption).fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary).maxLines(2).width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(Theme.space.s3)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(Theme.radius.md)
            .onClick((): void => { CourtyardDetailNav.openArticle(a.id) })
          }, (a: ArticleItem) => a.id)

          Text('关联推荐').fontSize(Theme.type.subtitleS).fontWeight(FontWeight.Medium).fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary).width('100%')
          ForEach(this.related, (p: PoemItem) => {
            PoemListCard({
              poemId: p.id,
              title: p.title,
              meta: p.metaLine(),
              summary: p.summary,
              coverKey: p.coverKey,
              onOpen: (id: string): void => { CourtyardDetailNav.openPoem(id) }
            })
          }, (p: PoemItem) => `rel_${p.id}`)
        }
        .width('100%')
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s8 })
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
