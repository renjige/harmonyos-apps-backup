import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { DetailShell } from './DetailShell'
import { ConfirmSheet } from '../journal/ConfirmSheet'
import { CornerEntry } from '../../models/YouyuModels'
import { MoodCatalog } from '../../services/MoodCatalog'
import { YouyuMedia } from '../../services/YouyuMedia'
import { YouyuNav } from '../../services/YouyuNav'
import { YouyuStore } from '../../services/YouyuStore'

@Component
export struct EntryDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @StorageLink('youyuRev') @Watch('onStoreRev') storeRev: number = 0
  @Prop itemId: string = ''
  @State item: CornerEntry = new CornerEntry()
  @State found: boolean = false
  @State tagsLine: string = ''
  @State confirmDelete: boolean = false
  @State toastText: string = ''

  aboutToAppear(): void {
    this.load()
  }

  onStoreRev(): void {
    this.load()
  }

  private load(): void {
    const row = YouyuStore.findEntry(this.itemId)
    if (row === null) {
      this.found = false
      return
    }
    this.item = row
    this.found = true
    this.tagsLine = this.resolveTags(row)
  }

  private resolveTags(row: CornerEntry): string {
    const names: string[] = []
    const tags = YouyuStore.tags()
    for (const id of row.tagList()) {
      for (const t of tags) {
        if (t.id === id) {
          names.push(t.name)
        }
      }
    }
    return names.join(' · ')
  }

  private showToast(msg: string): void {
    this.toastText = msg
    setTimeout(() => { this.toastText = '' }, 2200)
  }

  private async doDelete(): Promise<void> {
    const ok = await YouyuStore.deleteEntry(this.item.id)
    this.confirmDelete = false
    if (ok) {
      YouyuNav.closeDetail()
      return
    }
    this.showToast('删除失败，请重试')
  }

  build() {
    Stack() {
      DetailShell({
        title: YouyuStore.displayDate(this.item.entryDate),
        onClose: () => YouyuNav.closeDetail()
      }) {
        if (!this.found) {
          Column({ space: 12 }) {
            Text('这条记录已经不在了')
              .fontSize(Theme.type.body)
              .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
          }
          .padding(Theme.space.s6)
        } else {
          Scroll() {
            Column({ space: Theme.space.s4 }) {
              Stack() {
                if (this.item.photoPath.length > 0) {
                  Image(this.item.photoPath)
                    .width('100%')
                    .height(220)
                    .objectFit(ImageFit.Cover)
                } else {
                  Image(YouyuMedia.coverPlant())
                    .width('100%')
                    .height(220)
                    .objectFit(ImageFit.Cover)
                }
                Column()
                  .width('100%')
                  .height(110)
                  .linearGradient({
                    angle: 180,
                    colors: [['rgba(61,43,31,0)', 0], ['rgba(61,43,31,0.72)', 1]]
                  })
                  .align(Alignment.BottomStart)
                Text(`${MoodCatalog.emojiMark(this.item.mood)} ${MoodCatalog.labelOf(this.item.mood)}`)
                  .fontSize(Theme.type.subtitleM)
                  .fontColor('#F9F6F0')
                  .padding({ left: 16, bottom: 16, right: 16 })
              }
              .width('100%')
              .borderRadius(Theme.radius.md)
              .clip(true)

              Column({ space: 8 }) {
                if (this.tagsLine.length > 0) {
                  Text(this.tagsLine)
                    .fontSize(Theme.type.subhead)
                    .fontColor(Theme.colors().brandDeep)
                    .width('100%')
                }
                Text(this.item.body)
                  .fontSize(Theme.type.body)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
                  .lineHeight(24)
                  .width('100%')
              }
              .width('100%')
              .padding(Theme.space.s4)
              .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
              .borderRadius(Theme.radius.card)

              AppButton({
                label: '编辑',
                variant: 'primary',
                onTap: (): void => {
                  YouyuNav.closeDetail()
                  YouyuNav.openCompose(this.item.id)
                }
              })
              AppButton({
                label: '删除这条记录',
                variant: 'secondary',
                onTap: (): void => { this.confirmDelete = true }
              })
              Blank().height(Theme.space.s10)
            }
            .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s6 })
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }

      if (this.confirmDelete) {
        ConfirmSheet({
          title: '删除这条记录？',
          subtitle: '删除后无法从应用里找回。',
          keepLabel: '留下它',
          leaveLabel: '删除',
          onKeep: (): void => { this.confirmDelete = false },
          onLeave: (): void => { void this.doDelete() }
        })
      }

      if (this.toastText.length > 0) {
        Column() {
          Text(this.toastText)
            .fontSize(Theme.type.footnote)
            .fontColor(Theme.colors().brandOnPrimary)
            .padding({ left: 16, right: 16, top: 10, bottom: 10 })
            .backgroundColor(Theme.colors().brandPrimary)
            .borderRadius(Theme.radius.pill)
        }
        .width('100%')
        .padding({ top: 48 })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
