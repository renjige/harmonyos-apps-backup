import { Theme } from '../design-system/Theme'
import { AppCard } from '../design-system/AppCard'
import { AppButton } from '../design-system/AppButton'
import { AppIcon } from '../design-system/AppIcon'
import { ArticleItem } from '../../models/BrochureModels'
import { BrochureDetailNav } from '../../services/BrochureDetailNav'
import { BrowseHistoryService } from '../../services/BrowseHistoryService'
import { DetailShell } from './DetailShell'

@Component
export struct ArticleDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: ArticleItem = new ArticleItem()

  aboutToAppear(): void {
    void BrowseHistoryService.record(this.item.id, this.item.title, 'article')
  }

  private handleBack(): void {
    BrochureDetailNav.close()
  }

  private metaLine(): string {
    let line = '招生资讯'
    if (this.item.tags.length > 0) {
      line = this.item.tags
    }
    if (this.item.readMinutes > 0) {
      line = `${line} · 约 ${this.item.readMinutes} 分钟`
    }
    return line
  }

  build() {
    DetailShell({
      title: '资讯详情',
      onClose: (): void => { this.handleBack() }
    }) {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Column()
              .width('100%')
              .height(180)
              .linearGradient({
                angle: 140,
                colors: [[0xFF007AFF, 0.0], [0xFF0051A8, 0.55], [0xFF0A2540, 1.0]]
              })
            Column() {
              SymbolGlyph($r('sys.symbol.book'))
                .fontSize(72)
                .fontColor(['rgba(255,255,255,0.18)'])
                .renderingStrategy(SymbolRenderingStrategy.SINGLE)
            }
            .width('100%')
            .height(180)
            .alignItems(HorizontalAlign.End)
            .padding({ top: 16, right: 20 })
            Column({ space: Theme.space.s2 }) {
              Row({ space: Theme.space.s2 }) {
                Column() {
                  AppIcon({ name: 'book', iconSize: Theme.icon.md, color: '#FFFFFF' })
                }
                .width(36)
                .height(36)
                .justifyContent(FlexAlign.Center)
                .backgroundColor('rgba(255,255,255,0.20)')
                .borderRadius(Theme.radius.pill)
                Text(this.metaLine())
                  .fontSize(Theme.type.caption)
                  .fontColor('#E8F4FF')
              }
              .alignItems(VerticalAlign.Center)
              Text(this.item.title)
                .fontSize(Theme.type.title3)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .maxLines(3)
            }
            .width('100%')
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              bottom: Theme.space.s4
            })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .height(180)
          .borderRadius(Theme.radius.card)
          .clip(true)

          Column({ space: Theme.space.s4 }) {
            AppCard({ title: '摘要', variant: 'outlined' }) {
              Text(this.item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(24)
                .width('100%')
            }
            AppCard({ title: '正文', variant: 'plain' }) {
              Text(this.item.body.length > 0 ? this.item.body : this.item.summary)
                .fontSize(Theme.type.body)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .lineHeight(24)
                .width('100%')
            }
            AppButton({
              label: '返回继续浏览',
              variant: 'secondary',
              onTap: (): void => { this.handleBack() }
            })
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            bottom: Theme.space.s10
          })
          .width('100%')
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)
    }
  }
}
