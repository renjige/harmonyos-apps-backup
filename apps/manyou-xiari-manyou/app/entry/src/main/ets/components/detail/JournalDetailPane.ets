import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppEmpty } from '../design-system/AppEmpty'
import { DetailShell } from './DetailShell'
import { JournalItem } from '../../models/WanderModels'
import { WanderDetailNav } from '../../services/WanderDetailNav'
import { WanderLocalStore } from '../../services/WanderLocalStore'
import { JournalMedia } from '../../services/JournalMedia'

@Component
export struct JournalDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop journalId: string = ''
  @Prop @Watch('onJournalIdChange') refreshToken: number = 0
  @State item: JournalItem | undefined = undefined
  @State confirmDelete: boolean = false

  aboutToAppear(): void {
    void this.reload()
  }

  onJournalIdChange(): void {
    void this.reload()
  }

  private async reload(): Promise<void> {
    this.item = await WanderLocalStore.findJournal(this.journalId)
  }

  private async doDelete(): Promise<void> {
    await WanderLocalStore.removeJournal(this.journalId)
    WanderLocalStore.notifyDataChanged()
    WanderDetailNav.close()
  }

  @Builder
  HeroImage() {
    if (this.item !== undefined && JournalMedia.hasCover(this.item)) {
      Stack({ alignContent: Alignment.BottomStart }) {
        if (JournalMedia.coverIsFile(this.item)) {
          Image(JournalMedia.coverUri(this.item))
            .width('100%')
            .height(240)
            .objectFit(ImageFit.Cover)
        } else {
          Image(JournalMedia.coverResource(this.item))
            .width('100%')
            .height(240)
            .objectFit(ImageFit.Cover)
        }
        Column()
          .width('100%')
          .height(120)
          .linearGradient({
            angle: 180,
            colors: [['rgba(45,52,54,0)', 0.05], ['rgba(45,52,54,0.82)', 1.0]]
          })
        Column({ space: 6 }) {
          Text(this.item.mood)
            .fontSize(Theme.type.caption)
            .fontColor('#F6F1E8')
          Text(this.item.title)
            .fontSize(Theme.type.title2)
            .fontWeight(FontWeight.Bold)
            .fontColor('#F6F1E8')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .padding(20)
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .height(240)
      .clip(true)
    }
  }

  build() {
    if (this.item === undefined) {
      DetailShell({ title: '记录详情', onClose: () => WanderDetailNav.close() }) {
        AppEmpty({ title: '记录不见了', description: '也许已经删过', actionLabel: '返回', onAction: () => WanderDetailNav.close() })
      }
    } else {
      DetailShell({ title: this.item.title, onClose: () => WanderDetailNav.close() }) {
        Column({ space: Theme.space.s5 }) {
          this.HeroImage()

          Column({ space: 8 }) {
            if (!JournalMedia.hasCover(this.item)) {
              Text(this.item.title)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                .width('100%')
            }
            Text(`${this.item.place}  ·  ${this.item.mood}  ·  ${this.item.dateLabel}`)
              .fontSize(Theme.type.footnote)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .width('100%')
          }
          .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          .alignItems(HorizontalAlign.Start)

          Column({ space: 8 }) {
            Text('沿途随想')
              .fontSize(Theme.type.subtitleM)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
              .width('100%')
            Text(this.item.body)
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              .lineHeight(26)
              .width('100%')
          }
          .margin({ left: Theme.space.pageX, right: Theme.space.pageX })
          .padding(18)
          .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
          .borderRadius(Theme.radius.md)
          .alignItems(HorizontalAlign.Start)

          if (this.confirmDelete) {
            Column({ space: 10 }) {
              Text('删掉这条记录？删了就找不回来了。')
                .fontSize(Theme.type.subhead)
                .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
                .width('100%')
              Row({ space: 12 }) {
                AppButton({ label: '再想想', variant: 'ghost', onTap: (): void => { this.confirmDelete = false } }).layoutWeight(1)
                AppButton({ label: '确认删除', variant: 'danger', onTap: (): void => { void this.doDelete() } }).layoutWeight(1)
              }
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          } else {
            Row({ space: 12 }) {
              AppButton({
                label: '编辑',
                variant: 'secondary',
                onTap: (): void => WanderDetailNav.openJournalEdit(this.journalId)
              }).layoutWeight(1)
              AppButton({
                label: '删除',
                variant: 'ghost',
                onTap: (): void => { this.confirmDelete = true }
              }).layoutWeight(1)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX })
          }
        }
        .width('100%')
      }
    }
  }
}
