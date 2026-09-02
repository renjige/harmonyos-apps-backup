import { Theme } from '../design-system/Theme'
import { AppIcon } from '../design-system/AppIcon'
import { MomentNote } from '../../models/MomentModels'
import { DateHelper } from '../../services/DateHelper'
import { MomentStore } from '../../services/MomentStore'
import { MomentNav } from '../../services/MomentNav'

@Component
export struct MemoryFlashbackCard {
  @StorageLink('momentDataEpoch') @Watch('onEpoch') dataEpoch: number = 0
  @Prop @Watch('onTokenChange') refreshToken: number = 0
  @State flash: MomentNote = new MomentNote()
  @State hasData: boolean = false
  @State flashId: string = ''

  aboutToAppear(): void {
    void this.pickRandom()
  }

  onTokenChange(): void {
    void this.refreshCurrent()
  }

  onEpoch(): void {
    void this.refreshCurrent()
  }

  private async pickRandom(): Promise<void> {
    const n = await MomentStore.randomNote()
    if (n === undefined) {
      this.hasData = false
      this.flashId = ''
      return
    }
    this.flash = n
    this.flashId = n.id
    this.hasData = true
  }

  private async refreshCurrent(): Promise<void> {
    if (this.flashId.length === 0) {
      await this.pickRandom()
      return
    }
    const n = await MomentStore.findNote(this.flashId)
    if (n === undefined) {
      await this.pickRandom()
      return
    }
    this.flash = n
    this.hasData = true
  }

  build() {
    Column() {
      if (this.hasData) {
        Column({ space: Theme.space.s2 }) {
          Row({ space: Theme.space.s2 }) {
            AppIcon({ name: 'refresh', iconSize: Theme.icon.sm, color: Theme.colors().brandAccent })
            Text('随机回忆')
              .fontSize(Theme.type.subhead)
              .fontWeight(FontWeight.Medium)
              .fontColor(Theme.colors().textPrimary)
              .layoutWeight(1)
            if (this.flash.pinned) {
              Text('星标')
                .fontSize(11)
                .fontColor('#FFFFFF')
                .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                .backgroundColor(Theme.colors().brandPrimary)
                .borderRadius(Theme.radius.pill)
            }
            Text('换一条')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().brandPrimary)
              .onClick((): void => { void this.pickRandom() })
          }
          .width('100%')
          Text(DateHelper.displayDate(this.flash.dateKey))
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().textSecondary)
            .width('100%')
          Text(this.flash.preview())
            .fontSize(Theme.type.body)
            .fontColor(Theme.colors().textPrimary)
            .lineHeight(22)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
          Text('点开查看小事见解')
            .fontSize(Theme.type.caption)
            .fontColor(Theme.colors().brandPrimary)
            .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding(Theme.space.s4)
        .backgroundColor(Theme.colors().surfaceSubtle)
        .borderRadius(16)
        .onClick((): void => { MomentNav.openNote(this.flash.id) })
      }
    }
    .width('100%')
  }
}
