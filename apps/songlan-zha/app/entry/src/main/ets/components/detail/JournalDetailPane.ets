import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { ZhaConfirmDialog } from '../zha/ZhaConfirmDialog'
import { ZhaJournalEntry } from '../../models/ZhaModels'
import { ZhaLocalStore } from '../../services/ZhaLocalStore'
import { ZhaDetailNav } from '../../services/ZhaDetailNav'

@Component
export struct JournalDetailPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onDateKeyChange') dateKey: string = ''
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State entry: ZhaJournalEntry = new ZhaJournalEntry()
  @State editContent: string = ''
  @State editMood: string = '静'
  @State saved: boolean = false
  @State confirmDelete: boolean = false
  onChanged: () => void = () => {}

  aboutToAppear(): void {
    void this.load()
  }

  onDateKeyChange(): void {
    void this.load()
  }

  onRefreshChange(): void {
    if (this.refreshToken > 0) {
      void this.load()
    }
  }

  private async load(): Promise<void> {
    if (this.dateKey.length === 0) {
      return
    }
    const found = await ZhaLocalStore.findJournal(this.dateKey)
    if (found !== undefined) {
      this.entry = found
      this.editContent = found.content
      this.editMood = found.mood.length > 0 ? found.mood : '静'
    } else {
      this.entry = ZhaJournalEntry.create(this.dateKey, '静', '')
      this.editContent = ''
      this.editMood = '静'
    }
  }

  private async save(): Promise<void> {
    const item = ZhaJournalEntry.create(this.dateKey, this.editMood, this.editContent)
    item.updatedAt = Date.now()
    await ZhaLocalStore.saveJournal(item)
    this.saved = true
    this.onChanged()
    setTimeout(() => { this.saved = false }, 1800)
    void this.load()
  }

  private async doDelete(): Promise<void> {
    this.confirmDelete = false
    await ZhaLocalStore.deleteJournal(this.dateKey)
    this.onChanged()
    ZhaDetailNav.closeJournalDetail()
  }

  build() {
    Stack() {
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Stack({ alignContent: Alignment.BottomStart }) {
            Image($r('app.media.banner_zen_01'))
              .width('100%')
              .height(160)
              .objectFit(ImageFit.Cover)
              .borderRadius(Theme.radius.lg)
            Column({ space: 4 }) {
              Text(this.dateKey)
                .fontSize(Theme.type.title2)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
              Text('每日札记回顾')
                .fontSize(Theme.type.footnote)
                .fontColor('#FFFFFF')
            }
            .width('100%')
            .padding(Theme.space.s5)
            .linearGradient({
              angle: 180,
              colors: [['rgba(0,0,0,0)', 0], ['rgba(45,90,74,0.82)', 1]]
            })
          }
          .width('100%')
          .height(160)
          .clip(true)
          .borderRadius(Theme.radius.lg)

          Row({ space: Theme.space.s2 }) {
            ForEach(['静', '喜', '思', '倦'], (m: string) => {
              Text(m)
                .fontSize(Theme.type.footnote)
                .fontColor(this.editMood === m ? Theme.colors().brandOnPrimary : Theme.colors().textSecondary)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor(this.editMood === m ? Theme.colors().brandPrimary : Theme.colors().surfaceSubtle)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.editMood = m })
            }, (m: string) => m)
          }

          TextArea({ text: this.editContent, placeholder: '这一天的札记…' })
            .height(160)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .backgroundColor(Theme.colors().surfaceSubtle)
            .borderRadius(Theme.radius.sm)
            .onChange((v: string) => { this.editContent = v })

          if (this.saved) {
            Text('已保存')
              .fontSize(Theme.type.caption)
              .fontColor(Theme.colors().success)
          }

          AppButton({
            label: '保存修改',
            variant: 'primary',
            onTap: () => { void this.save() }
          })

          if (this.entry.content.length > 0 || this.editContent.length > 0) {
            AppButton({
              label: '删除此日札记',
              variant: 'danger',
              onTap: () => { this.confirmDelete = true }
            })
          }
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          top: Theme.space.s2,
          bottom: Theme.space.s10
        })
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.Spring)

      if (this.confirmDelete) {
        ZhaConfirmDialog({
          title: '删除札记',
          message: '将删除这一天的札记，无法恢复。是否继续？',
          confirmLabel: '确认删除',
          danger: true,
          onConfirm: () => { void this.doDelete() },
          onCancel: () => { this.confirmDelete = false }
        })
      }
    }
    .width('100%')
    .height('100%')
  }
}
