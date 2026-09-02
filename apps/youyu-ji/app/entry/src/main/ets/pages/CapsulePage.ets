import { Theme } from '../components/design-system/Theme'
import { AppButton } from '../components/design-system/AppButton'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { CornerEntry } from '../models/YouyuModels'
import { MoodCatalog } from '../services/MoodCatalog'
import { YouyuMedia } from '../services/YouyuMedia'
import { YouyuNav } from '../services/YouyuNav'
import { YouyuStore } from '../services/YouyuStore'

@Component
export struct CapsulePage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('youyuRev') @Watch('onStoreRev') storeRev: number = 0
  @State hasDrawn: boolean = false
  @State drawn: CornerEntry = new CornerEntry()
  @State drawSeq: number = 0
  @State empty: boolean = true

  aboutToAppear(): void {
    this.syncEmpty()
  }

  onStoreRev(): void {
    this.syncEmpty()
  }

  private syncEmpty(): void {
    this.empty = YouyuStore.entries().length === 0
    if (this.empty) {
      this.hasDrawn = false
    }
  }

  private copyEntry(row: CornerEntry): CornerEntry {
    const e = new CornerEntry()
    e.id = row.id
    e.body = row.body
    e.mood = row.mood
    e.tagCsv = row.tagCsv
    e.photoPath = row.photoPath
    e.entryDate = row.entryDate
    e.createdAt = row.createdAt
    e.updatedAt = row.updatedAt
    return e
  }

  private redraw(): void {
    const exclude = this.hasDrawn ? this.drawn.id : ''
    const row = YouyuStore.pickRandomExcept(exclude)
    if (row === null) {
      this.hasDrawn = false
      AppStorage.setOrCreate('tabBarHidden', false)
      return
    }
    this.drawn = this.copyEntry(row)
    this.drawSeq += 1
    this.hasDrawn = true
    AppStorage.setOrCreate('tabBarHidden', true)
  }

  private openDetail(): void {
    const id = this.drawn.id
    this.back()
    YouyuNav.openDetail(id)
  }

  private back(): void {
    this.hasDrawn = false
    AppStorage.setOrCreate('tabBarHidden', false)
  }

  build() {
    Column() {
      if (this.hasDrawn) {
        Column() {
          Stack() {
            if (this.drawn.photoPath.length > 0) {
              Image(this.drawn.photoPath)
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
            } else {
              Image(YouyuMedia.coverLamp())
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
            }
            Column()
              .width('100%')
              .height('100%')
              .linearGradient({
                angle: 180,
                colors: [['rgba(61,43,31,0.25)', 0], ['rgba(61,43,31,0.82)', 1]]
              })
            Column({ space: Theme.space.s4 }) {
              Text(YouyuStore.displayDate(this.drawn.entryDate))
                .fontSize(Theme.type.subhead)
                .fontColor('#F9F6F0')
              Text(`${MoodCatalog.emojiMark(this.drawn.mood)}  ${MoodCatalog.labelOf(this.drawn.mood)}`)
                .fontSize(Theme.type.subtitleL)
                .fontColor('#F9F6F0')
              Text(this.drawn.body)
                .fontSize(Theme.type.body)
                .fontColor('#F9F6F0')
                .lineHeight(24)
                .maxLines(12)
                .width('100%')
              Blank().layoutWeight(1)
              Row() {
                AppButton({
                  label: '再抽一次',
                  variant: 'primary',
                  onTap: (): void => { this.redraw() }
                })
              }
              .width('100%')
              .onClick((): void => { this.redraw() })
              Row() {
                AppButton({
                  label: '打开详情',
                  variant: 'secondary',
                  onTap: (): void => { this.openDetail() }
                })
              }
              .width('100%')
              .onClick((): void => { this.openDetail() })
              Row() {
                AppIcon({ name: 'chevron', iconSize: Theme.icon.sm, color: '#F9F6F0' })
                Text('返回')
                  .fontSize(Theme.type.body)
                  .fontColor('#F9F6F0')
              }
              .height(48)
              .onClick((): void => { this.back() })
            }
            .width('100%')
            .height('100%')
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, top: 48, bottom: 32 })
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .layoutWeight(1)
        }
        .width('100%')
        .height('100%')
        .key(`capsule_${this.drawSeq}`)
      } else {
        Scroll() {
          Column({ space: Theme.space.s5 }) {
            Text('时光胶囊')
              .fontSize(Theme.type.title2)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text('从过去的记录里随机抽出一隅，遇见当时的自己。')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
            Image(YouyuMedia.bannerPaper())
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.md)
            if (this.empty) {
              AppEmpty({
                title: '还没有可以抽取的记录',
                description: '先写下第一隅，日后再回来遇见它。',
                actionLabel: '写下此刻',
                onAction: (): void => YouyuNav.openCompose('')
              })
            } else {
              Row() {
                AppButton({
                  label: '抽取一隅',
                  variant: 'primary',
                  onTap: (): void => { this.redraw() }
                })
              }
              .width('100%')
              .onClick((): void => { this.redraw() })
            }
          }
          .padding({
            left: Theme.space.pageX,
            right: Theme.space.pageX,
            top: Theme.space.s4,
            bottom: Theme.space.s10
          })
        }
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .edgeEffect(EdgeEffect.Spring)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
