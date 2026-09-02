import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { FormattedEssayBody } from './FormattedEssayBody'
import { MicroEssay, SenseOption } from '../../models/EssayModels'
import { DateHelper } from '../../services/DateHelper'
import { EssayStore } from '../../services/EssayStore'
import { ImagePathUtil } from '../../services/ImagePathUtil'
import { PickAlbumSheet } from './PickAlbumSheet'
import { ObserveKindBadge } from './ObserveKindBadge'

@Component
export struct EssayDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onEssayIdChange') essayId: string = ''
  @Prop fontScale: number = 1
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onDeleted: () => void = () => {}
  onChanged: () => void = () => {}
  onOpenRelated: (id: string) => void = () => {}

  @State confirmDelete: boolean = false
  @State current: MicroEssay = new MicroEssay()
  @State showAlbumPick: boolean = false
  @State sourceEssays: MicroEssay[] = []

  aboutToAppear(): void {
    void this.reload()
    void EssayStore.markOpened(this.essayId)
  }

  onEssayIdChange(): void {
    this.confirmDelete = false
    void this.reload()
    void EssayStore.markOpened(this.essayId)
  }

  private async reload(): Promise<void> {
    const found = await EssayStore.findById(this.essayId)
    if (found !== undefined) {
      this.current = found
    }
    await this.loadContrastSources()
  }

  private async loadContrastSources(): Promise<void> {
    const ids = this.current.contrastSourceIds()
    const out: MicroEssay[] = []
    for (const id of ids) {
      const it = await EssayStore.findById(id)
      if (it !== undefined) {
        out.push(it)
      }
    }
    this.sourceEssays = out
  }

  private observeDateLine(): string {
    const key = DateHelper.normalizeKey(this.current.dateKey)
    if (key.length > 0) {
      return DateHelper.displayDate(key)
    }
    return DateHelper.displayDateTime(this.current.updatedAt)
  }

  private async handleDelete(): Promise<void> {
    if (!this.confirmDelete) {
      this.confirmDelete = true
      return
    }
    await EssayStore.deleteEssay(this.current.id)
    this.onDeleted()
  }

  private async toggleFav(): Promise<void> {
    await EssayStore.toggleFavorite(this.current.id)
    await this.reload()
    this.onChanged()
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Theme.colors().overlayScrim)
        .onClick((): void => { this.onClose() })

      Column() {
        Row() {
          Row() {
            AppIcon({ name: 'close', iconSize: Theme.icon.lg, color: Theme.colors().textPrimary })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { this.onClose() })
          Blank()
          Text('观察详情')
            .fontSize(Theme.type.subhead)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
          Blank()
          Row() {
            AppIcon({
              name: 'heart',
              iconSize: Theme.icon.lg,
              color: this.current.favorite ? Theme.colors().danger : Theme.colors().textSecondary
            })
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .onClick((): void => { void this.toggleFav() })
        }
        .width('100%')
        .padding(Theme.space.pageX)

        Scroll() {
          Column({ space: Theme.space.s4 }) {
            Stack({ alignContent: Alignment.BottomStart }) {
              if (this.current.imagePath.length > 0) {
                Image(ImagePathUtil.toDisplayUri(this.current.imagePath))
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
              } else {
                Image($r('app.media.hero_ivory_desk'))
                  .width('100%')
                  .height(200)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(Theme.radius.md)
              }
              Column() {
                Blank()
                Column() {
                  Text(this.current.title.length > 0 ? this.current.title : '无标题')
                    .fontSize(Theme.type.title3 * this.fontScale)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#FFFFFF')
                  Text(`${this.observeDateLine()} · ${this.current.wordCount} 字`)
                    .fontSize(Theme.type.caption)
                    .fontColor('#FFFFFF')
                }
                .width('100%')
                .padding(Theme.space.s4)
                .linearGradient({
                  angle: 180,
                  colors: [['rgba(0,0,0,0)', 0], ['rgba(26,42,58,0.78)', 1]]
                })
              }
              .width('100%')
              .height(200)
            }
            .width('100%')
            .height(200)

            Row({ space: Theme.space.s2 }) {
              ObserveKindBadge({ kind: this.current.kind })
              if (SenseOption.labelOf(this.current.senseKey).length > 0) {
                Text(`观察维度：${SenseOption.labelOf(this.current.senseKey)}`)
                  .fontSize(Theme.type.bodyS)
                  .fontColor(Theme.colors().brandPrimary)
              }
            }
            .width('100%')

            if (this.current.kind === 'contrast' && this.sourceEssays.length > 0) {
              Column({ space: Theme.space.s2 }) {
                Text('对照来源')
                  .fontSize(Theme.type.subhead)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(Theme.colors().textPrimary)
                  .width('100%')
                Text('并排重读的两篇观察，点进可查看原文')
                  .fontSize(Theme.type.caption)
                  .fontColor(Theme.colors().textSecondary)
                  .width('100%')
                ForEach(this.sourceEssays, (src: MicroEssay, idx: number) => {
                  Row({ space: Theme.space.s2 }) {
                    Text(idx === 0 ? '左' : '右')
                      .fontSize(Theme.type.caption)
                      .fontColor(Theme.colors().brandAccent)
                      .width(28)
                    Column({ space: 2 }) {
                      Text(src.title.length > 0 ? src.title : '无标题')
                        .fontSize(Theme.type.bodyS * this.fontScale)
                        .fontWeight(FontWeight.Medium)
                        .fontColor(Theme.colors().textPrimary)
                        .width('100%')
                      Text(`${EssayStore.resolvedDateKey(src)} · ${src.previewSummary(48)}`)
                        .fontSize(Theme.type.caption)
                        .fontColor(Theme.colors().textSecondary)
                        .width('100%')
                    }
                    .layoutWeight(1)
                    .alignItems(HorizontalAlign.Start)
                  }
                  .width('100%')
                  .padding(Theme.space.s3)
                  .backgroundColor(Theme.colors().surfaceCard)
                  .borderRadius(Theme.radius.md)
                  .onClick((): void => { this.onOpenRelated(src.id) })
                }, (src: MicroEssay) => src.id)
              }
              .width('100%')
            }

            if (this.current.tagList().length > 0) {
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(this.current.tagList(), (tag: string) => {
                  Text(tag)
                    .fontSize(Theme.type.bodyS)
                    .fontColor(this.themeEpoch >= 0 ? Theme.colors().brandPrimary : Theme.colors().brandPrimary)
                    .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                    .backgroundColor(Theme.colors().brandPrimaryContainer)
                    .borderRadius(Theme.radius.pill)
                    .margin({ right: 8, bottom: 8 })
                }, (tag: string) => tag)
              }
            }

            if (MicroEssay.stripMarkup(this.current.body).trim().length === 0) {
              Text('（无正文）')
                .fontSize(Theme.type.bodyL * this.fontScale)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
            } else {
              FormattedEssayBody({
                body: this.current.body,
                fontSize: Theme.type.bodyL * this.fontScale,
                lineHeight: 26 * this.fontScale
              })
            }

            Row({ space: Theme.space.s3 }) {
              Text('编辑')
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .textAlign(TextAlign.Center)
                .layoutWeight(1)
                .padding({ top: 12, bottom: 12 })
                .backgroundColor('#1A2A3A')
                .border({ width: 1, color: '#C9A96E' })
                .borderRadius(Theme.radius.md)
                .onClick((): void => { this.onEdit() })
              Text(this.confirmDelete ? '确认删除' : '删除')
                .fontSize(Theme.type.body)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .textAlign(TextAlign.Center)
                .layoutWeight(1)
                .padding({ top: 12, bottom: 12 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.md)
                .onClick((): void => { void this.handleDelete() })
            }
            .width('100%')
            Row({ space: Theme.space.s3 }) {
              Text('加入专辑')
                .fontSize(Theme.type.bodyS)
                .fontWeight(FontWeight.Medium)
                .fontColor('#FFFFFF')
                .textAlign(TextAlign.Center)
                .layoutWeight(1)
                .padding({ top: 10, bottom: 10 })
                .backgroundColor('#1A2A3A')
                .borderRadius(Theme.radius.md)
                .onClick((): void => { this.showAlbumPick = true })
              Text('用这篇对照')
                .fontSize(Theme.type.bodyS)
                .fontWeight(FontWeight.Medium)
                .fontColor(Theme.colors().textPrimary)
                .textAlign(TextAlign.Center)
                .layoutWeight(1)
                .padding({ top: 10, bottom: 10 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.md)
                .onClick((): void => {
                  AppStorage.setOrCreate('contrastSeedId', this.current.id)
                  this.onClose()
                  AppStorage.setOrCreate('essayTabIndex', 0)
                  AppStorage.setOrCreate('openContrast', 1)
                })
            }
            .width('100%')
          }
          .width('100%')
          .padding(Theme.space.pageX)
          .padding({ bottom: Theme.space.s10 })
        }
        .layoutWeight(1)
        .edgeEffect(EdgeEffect.Spring)
      }
      .width('100%')
      .height('92%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
      .borderRadius({ topLeft: Theme.radius.xl, topRight: Theme.radius.xl })
      .position({ x: 0, y: '8%' })

      if (this.showAlbumPick) {
        PickAlbumSheet({
          essayId: this.current.id,
          onClose: (): void => { this.showAlbumPick = false },
          onPicked: (): void => {
            this.showAlbumPick = false
            this.onChanged()
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .zIndex(50)
    .onAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', true)
      void this.reload()
    })
    .onDisAppear((): void => {
      AppStorage.setOrCreate('tabBarHidden', false)
    })
  }
}
