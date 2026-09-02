import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { Journey, SaituRecord } from '../../models/SaituModels'
import { DateHelper } from '../../services/DateHelper'
import { ImagePathUtil } from '../../services/ImagePathUtil'
import { SaituLocalStore } from '../../services/SaituLocalStore'
import { SaituAchievementStore } from '../../services/SaituAchievementStore'
import { pasteboard } from '@kit.BasicServicesKit'

@Component
export struct RecordDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('saituDetailRecordId') detailRecordId: string = ''
  @Prop record: SaituRecord = new SaituRecord()
  @Prop journey: Journey | null = null
  onClose: () => void = () => {}
  onEdit: () => void = () => {}
  onDelete: () => void = () => {}
  onShare: () => void = () => {}
  onFavoriteChanged: () => void = () => {}
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  private canEdit(): boolean {
    return this.detailRecordId.length > 0 && this.record.id === this.detailRecordId
  }

  private async toggleFavorite(): Promise<void> {
    this.record.favorite = !this.record.favorite
    await SaituLocalStore.saveRecord(this.record)
    await SaituAchievementStore.evaluateAndUnlock()
    this.showToast(this.record.favorite ? '已加入收藏' : '已取消收藏')
    this.onFavoriteChanged()
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout((): void => { this.toastText = '' }, 2600)
  }

  private async copyShare(): Promise<void> {
    const lines: string[] = []
    lines.push(`赛途札记 · ${DateHelper.displayDateTime(this.record.createdAt)}`)
    if (this.journey !== null) {
      lines.push(`旅途：${this.journey.name}`)
    }
    lines.push(this.record.content)
    if (this.record.tags.length > 0) {
      lines.push(`标签：${this.record.tags.join(' · ')}`)
    }
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, lines.join('\n'))
      const board = pasteboard.getSystemPasteboard()
      await board.setData(data)
      this.showToast('内容已复制，可粘贴到系统分享')
      this.onShare()
    } catch {
      this.showToast('分享复制失败')
    }
  }

  @Builder
  bodyContent() {
    Scroll() {
      Column({ space: Theme.space.s4 }) {
        Stack({ alignContent: Alignment.BottomStart }) {
          if (this.record.images.length > 0) {
            Image(ImagePathUtil.toDisplayUri(this.record.images[0]))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
          } else {
            Image($r('app.media.hero_ambient'))
              .width('100%')
              .height(200)
              .objectFit(ImageFit.Cover)
          }
          Column()
            .width('100%')
            .height(200)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(0,0,0,0.55)', 1]]
            })
          Text(DateHelper.displayDateTime(this.record.createdAt))
            .fontSize(Theme.type.title3)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .padding(Theme.space.s4)
        }
        .width('100%')
        .borderRadius(Theme.radius.lg)
        .clip(true)

        if (this.journey !== null) {
          Text(`旅途 · ${this.journey.name}`)
            .fontSize(Theme.type.bodyS)
            .fontColor(Theme.colors().brandPrimary)
        }
        if (this.record.tags.length > 0) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.record.tags, (tag: string) => {
              Text(tag)
                .fontSize(Theme.type.caption)
                .fontColor(Theme.colors().brandPrimary)
                .padding({ left: 10, right: 10, top: 4, bottom: 4 })
                .backgroundColor(Theme.colors().brandPrimaryContainer)
                .borderRadius(Theme.radius.pill)
                .margin({ right: 8, bottom: 8 })
            }, (tag: string) => tag)
          }
        }

        Column({ space: Theme.space.s2 }) {
          Text('摘要')
            .fontSize(Theme.type.overline)
            .fontColor(Theme.colors().textTertiary)
          Text(this.record.summaryLine(120))
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textSecondary)
        }
        .width('100%')
        .padding(Theme.space.cardPadding)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.lg)

        Text(this.record.content)
          .fontSize(Theme.type.body)
          .fontColor(Theme.colors().textPrimary)
          .lineHeight(24)
          .width('100%')

        if (this.record.images.length > 1) {
          Scroll() {
            Row({ space: Theme.space.s2 }) {
              ForEach(this.record.images, (uri: string, idx: number) => {
                if (idx > 0) {
                  Image(ImagePathUtil.toDisplayUri(uri))
                    .width(160)
                    .height(120)
                    .borderRadius(Theme.radius.md)
                    .objectFit(ImageFit.Cover)
                }
              }, (uri: string, idx: number) => `${idx}_${uri}`)
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
        }

        Row({ space: Theme.space.s3 }) {
          AppButton({
            label: '编辑',
            variant: 'primary',
            onTap: (): void => {
              if (this.canEdit()) {
                this.onEdit()
              } else {
                this.showToast('记录加载中，请稍后再试')
              }
            }
          })
          AppButton({ label: '分享', variant: 'secondary', onTap: (): void => { void this.copyShare() } })
          AppButton({
            label: this.record.favorite ? '已收藏' : '收藏',
            variant: 'secondary',
            onTap: (): void => { void this.toggleFavorite() }
          })
          AppButton({ label: '删除', variant: 'secondary', onTap: (): void => { this.confirmDelete = true } })
        }
        .width('100%')

        Blank().height(Theme.space.s10)
      }
      .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
    }
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.Spring)
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      DetailShell({
        title: '札记详情',
        onClose: (): void => this.onClose(),
        body: (): void => this.bodyContent()
      })

      if (this.confirmDelete) {
        Column({ space: Theme.space.s4 }) {
          Text('确认删除这条札记？')
            .fontSize(Theme.type.title3)
            .fontColor(Theme.colors().textPrimary)
          Row({ space: Theme.space.s3 }) {
            AppButton({
              label: '取消',
              variant: 'secondary',
              onTap: (): void => { this.confirmDelete = false }
            })
            AppButton({
              label: '删除',
              variant: 'primary',
              onTap: (): void => {
                this.confirmDelete = false
                this.onDelete()
              }
            })
          }
        }
        .width('80%')
        .padding(Theme.space.s6)
        .backgroundColor(Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.xl)
        .position({ x: '10%', y: '35%' })
      }

      if (this.toastText.length > 0) {
        Text(this.toastText)
          .fontSize(Theme.type.bodyS)
          .fontColor(Theme.colors().textOnInverse)
          .padding({ left: 16, right: 16, top: 10, bottom: 10 })
          .backgroundColor(Theme.colors().surfaceInverse)
          .borderRadius(Theme.radius.pill)
          .margin({ top: Theme.space.s8 })
          .zIndex(30)
      }
    }
    .width('100%')
    .height('100%')
  }
}
