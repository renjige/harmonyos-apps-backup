import { Theme } from '../design-system/Theme'
import { SectionTitle } from './ShoppingCards'
import { ShoppingMedia } from '../../services/ShoppingMedia'

export class SceneCard {
  templateId: string = ''
  title: string = ''
  tip: string = ''
  kind: string = ''
  coverKey: string = 'tpl_daily'
}

export class SceneCatalog {
  static cards(): SceneCard[] {
    const out: SceneCard[] = []
    const a = new SceneCard()
    a.templateId = 'tpl_market'
    a.title = '超市动线'
    a.tip = '按货架顺序勾选，减少折返'
    a.kind = '日常采购'
    a.coverKey = 'tpl_daily'
    out.push(a)
    const b = new SceneCard()
    b.templateId = 'tpl_wetmarket'
    b.title = '菜市场'
    b.tip = '按摊位记生鲜，到摊再确认份量'
    b.kind = '生鲜食品'
    b.coverKey = 'tpl_breakfast'
    out.push(b)
    const c = new SceneCard()
    c.templateId = 'tpl_restock'
    c.title = '家庭补货'
    c.tip = '结合补货提醒，一周一次集中买'
    c.kind = '家庭用品'
    c.coverKey = 'tpl_family'
    out.push(c)
    const d = new SceneCard()
    d.templateId = 'tpl_trip'
    d.title = '出行打包'
    d.tip = '登机前全屏核对，避免漏带'
    d.kind = '旅行用品'
    d.coverKey = 'tpl_travel'
    out.push(d)
    const e = new SceneCard()
    e.templateId = 'tpl_weekend'
    e.title = '周末囤购'
    e.tip = '收藏方案 + 每周提醒'
    e.kind = '日常采购'
    e.coverKey = 'tpl_daily'
    out.push(e)
    return out
  }
}

@Component
export struct SceneWorkbench {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop activeId: string = ''
  onPick: (card: SceneCard) => void = () => {}

  build() {
    Column({ space: 10 }) {
      SectionTitle({ title: '采购情景工作台' })
      Text('按采购场景一键生成动线清单，区别于普通备忘列表')
        .fontSize(Theme.type.caption)
        .fontColor(Theme.paint(this.themeEpoch).textSecondary)
        .width('100%')
      Scroll() {
        Row({ space: 10 }) {
          ForEach(SceneCatalog.cards(), (card: SceneCard) => {
            Column({ space: 8 }) {
              Image(ShoppingMedia.cover(card.coverKey))
                .width(112)
                .height(72)
                .objectFit(ImageFit.Cover)
                .borderRadius(Theme.radius.lg)
              Text(card.title)
                .fontSize(Theme.type.footnote)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.paint(this.themeEpoch).textPrimary)
                .maxLines(1)
                .width(112)
                .textAlign(TextAlign.Center)
              Text(card.tip)
                .fontSize(Theme.type.overline)
                .fontColor(Theme.paint(this.themeEpoch).textSecondary)
                .maxLines(2)
                .width(112)
                .textAlign(TextAlign.Center)
            }
            .width(120)
            .padding(10)
            .backgroundColor(this.activeId === card.templateId ?
              Theme.colors().brandPrimaryContainer : Theme.paint(this.themeEpoch).surfaceCard)
            .borderRadius(Theme.radius.xl)
            .border({
              width: this.activeId === card.templateId ? 1.5 : 1,
              color: this.activeId === card.templateId ? Theme.colors().brandPrimary : Theme.colors().strokeHairline
            })
            .onClick((): void => { this.onPick(card) })
          }, (card: SceneCard) => card.templateId)
        }
        .padding({ right: 4 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
  }
}
