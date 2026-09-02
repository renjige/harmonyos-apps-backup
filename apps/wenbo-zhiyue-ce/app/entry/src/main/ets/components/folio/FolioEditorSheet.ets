import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { KnowledgeFolio } from '../../models/FolioModels'
import { FolioStore } from '../../services/FolioStore'
import { FolioMedia } from '../../services/FolioMedia'

@Component
export struct FolioEditorSheet {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop editId: string = ''
  @State title: string = ''
  @State summary: string = ''
  @State coverKey: string = 'cover_folio_study'
  @State errorText: string = ''
  private covers: string[] = FolioMedia.coverKeys()
  onClose: () => void = () => {}
  onSaved: () => void = () => {}

  aboutToAppear(): void {
    void this.prefill()
  }

  private async prefill(): Promise<void> {
    if (this.editId.length === 0) {
      return
    }
    const found = await FolioStore.findFolio(this.editId)
    if (found !== undefined) {
      this.title = found.title
      this.summary = found.summary
      this.coverKey = found.coverKey
    }
  }

  private async save(): Promise<void> {
    if (this.title.trim().length === 0) {
      this.errorText = '请填写知识册名称'
      return
    }
    if (this.editId.length > 0) {
      const found = await FolioStore.findFolio(this.editId)
      if (found !== undefined) {
        found.title = this.title.trim()
        found.summary = this.summary.trim()
        found.coverKey = this.coverKey
        await FolioStore.saveFolio(found)
        this.onSaved()
        this.onClose()
        return
      }
    }
    const item = KnowledgeFolio.create(this.title.trim(), this.summary.trim(), this.coverKey)
    await FolioStore.saveFolio(item)
    this.onSaved()
    this.onClose()
  }

  build() {
    Column() {
      AppNavBar({ title: this.editId.length > 0 ? '编辑知识册' : '新建知识册', onBack: (): void => { this.onClose() } })
      Scroll() {
        Column({ space: 12 }) {
          Text('名称')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextInput({ text: this.title, placeholder: '例如：产品方法论' })
            .onChange((v: string) => { this.title = v })
            .height(48)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
          Text('简介')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          TextArea({ text: this.summary, placeholder: '这个知识册用来沉淀什么？' })
            .onChange((v: string) => { this.summary = v })
            .height(90)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .borderRadius(12)
          Text('封面')
            .fontSize(Theme.type.caption)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
            .width('100%')
          Row({ space: 8 }) {
            ForEach(this.covers, (key: string) => {
              Column({ space: 4 }) {
                Image(FolioMedia.cover(key))
                  .width(88)
                  .height(72)
                  .objectFit(ImageFit.Cover)
                  .borderRadius(10)
                  .border({
                    width: this.coverKey === key ? 2 : 0,
                    color: Theme.colors().brandAccent
                  })
                Text(FolioMedia.coverLabel(key))
                  .fontSize(11)
                  .fontColor(this.themeEpoch >= 0 ? Theme.colors().textSecondary : Theme.colors().textSecondary)
              }
              .onClick((): void => { this.coverKey = key })
            }, (key: string) => key)
          }
          .width('100%')
          if (this.errorText.length > 0) {
            Text(this.errorText)
              .fontSize(Theme.type.footnote)
              .fontColor(Theme.colors().danger)
              .width('100%')
          }
          AppButton({ label: '保存知识册', onTap: (): void => { void this.save() } })
        }
        .padding({ left: Theme.space.pageX, right: Theme.space.pageX, bottom: Theme.space.s10 })
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)
  }
}
