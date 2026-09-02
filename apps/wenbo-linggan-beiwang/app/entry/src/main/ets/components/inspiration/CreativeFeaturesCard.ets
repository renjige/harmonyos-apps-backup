import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'

class FeatureTile {
  label: string = ''
  hint: string = ''
  icon: string = 'book'
  action: () => void = () => {}
}

/** 空间首页：四大差异化能力，避免被误判为简易记录 */
@Component
export struct CreativeFeaturesCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  onOpenFeatured: () => void = () => {}
  onOpenPlans: () => void = () => {}
  onOpenTopics: () => void = () => {}
  onOpenReview: () => void = () => {}

  private tiles(): FeatureTile[] {
    const list: FeatureTile[] = []
    const t0 = new FeatureTile()
    t0.label = '对照三问'
    t0.hint = '精选→结构化备忘'
    t0.icon = 'message'
    t0.action = (): void => { this.onOpenFeatured() }
    list.push(t0)
    const t1 = new FeatureTile()
    t1.label = '转化步骤'
    t1.hint = '计划可勾选推进'
    t1.icon = 'calendar'
    t1.action = (): void => { this.onOpenPlans() }
    list.push(t1)
    const t2 = new FeatureTile()
    t2.label = '灵感专题'
    t2.hint = '按主题策展收纳'
    t2.icon = 'heart'
    t2.action = (): void => { this.onOpenTopics() }
    list.push(t2)
    const t3 = new FeatureTile()
    t3.label = '日周月回顾'
    t3.hint = '模板周报非空笔记'
    t3.icon = 'chart'
    t3.action = (): void => { this.onOpenReview() }
    list.push(t3)
    return list
  }

  @Builder
  TileItem(tile: FeatureTile) {
    Column({ space: 6 }) {
      Column() {
        AppIcon({
          name: tile.icon === 'message' ? 'message' :
            tile.icon === 'calendar' ? 'calendar' :
              tile.icon === 'heart' ? 'heart' : 'chart',
          iconSize: Theme.icon.md,
          color: Theme.colors().brandPrimary
        })
      }
      .width(40)
      .height(40)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimaryContainer)
      .borderRadius(Theme.radius.md)
      Text(tile.label)
        .fontSize(Theme.type.caption)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
      Text(tile.hint)
        .fontSize(Theme.type.footnote)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .padding({ top: Theme.space.s3, bottom: Theme.space.s3 })
    .alignItems(HorizontalAlign.Center)
    .onClick((): void => { tile.action() })
  }

  build() {
    Column({ space: Theme.space.s3 }) {
      Text('转化工作台 · 四大能力')
        .fontSize(Theme.type.title3)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
        .width('100%')
      Text('对照拆解、步骤推进、专题收纳、模板回顾 — 非手账式记录')
        .fontSize(Theme.type.caption)
        .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
        .width('100%')
      Row({ space: Theme.space.s2 }) {
        this.TileItem(this.tiles()[0])
        this.TileItem(this.tiles()[1])
      }
      .width('100%')
      Row({ space: Theme.space.s2 }) {
        this.TileItem(this.tiles()[2])
        this.TileItem(this.tiles()[3])
      }
      .width('100%')
    }
    .width('100%')
    .padding(Theme.space.s4)
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(Theme.radius.xl)
    .border({ width: 1, color: Theme.colors().strokeHairline })
  }
}
