import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { StatusChip } from './StatusChip'
import { QualityMedia } from '../../services/QualityMedia'
import { ProjectItem } from '../../models/QualityModels'
import { QualityService } from '../../services/QualityService'

@Component
export struct ProjectCard {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop item: ProjectItem = new ProjectItem()
  @Prop refreshToken: number = 0
  @State pressed: boolean = false
  onOpen: (id: string) => void = (_id: string) => {}

  private countsText(): string {
    const _keep = this.refreshToken
    const s = QualityService.projectCounts(this.item.id)
    return `发现问题 ${s.foundToday}  ·  整改中 ${s.rectifying}  ·  已闭环 ${s.closed}`
  }

  private health(): string {
    const _keep = this.refreshToken
    const s = QualityService.projectCounts(this.item.id)
    if (s.foundToday + s.rectifying === 0) {
      return '巡查正常'
    }
    return '整改跟进中'
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.BottomStart }) {
        Image(QualityMedia.cover(this.item.coverKey))
          .width('100%')
          .height(132)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 18, topRight: 18 })
          .alt('项目封面')
        Column()
          .width('100%')
          .height(72)
          .linearGradient({
            angle: 180,
            colors: [['#00000000', 0], ['#990F172A', 1]]
          })
          .borderRadius({ topLeft: 18, topRight: 18 })
        Text(this.item.title)
          .fontSize(Theme.type.title3)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .margin({ left: 14, bottom: 12, right: 14 })
      }
      Column({ space: 8 }) {
        Row() {
          StatusChip({ label: this.health() })
          Blank()
          if (this.item.isSample) {
            Text('示例')
              .fontSize(Theme.type.caption)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
        }
        .width('100%')
        Text(this.countsText())
          .fontSize(Theme.type.footnote)
          .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row() {
          Text('查看详情')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
          AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: Theme.colors().brandPrimary })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .padding(14)
      .width('100%')
    }
    .width('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
    .borderRadius(18)
    .clip(true)
    .shadow({ radius: 12, color: 'rgba(15,23,42,0.06)', offsetY: 2, offsetX: 0 })
    .opacity(this.pressed ? 0.92 : 1)
    .scale({ x: this.pressed ? 0.98 : 1, y: this.pressed ? 0.98 : 1 })
    .animation({ duration: Theme.motion.instant, curve: Curve.EaseOut })
    .onTouch((e: TouchEvent) => {
      if (e.type === TouchType.Down) {
        this.pressed = true
      }
      if (e.type === TouchType.Up || e.type === TouchType.Cancel) {
        this.pressed = false
      }
    })
    .onClick(() => this.onOpen(this.item.id))
  }
}
