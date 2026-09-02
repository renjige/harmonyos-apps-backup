import { Theme } from '../design-system/Theme'
import { AppButton } from '../design-system/AppButton'
import { AppNavBar } from '../design-system/AppNavBar'
import { CollectionItem } from '../../models/AskModels'
import { AskNav } from '../../services/AskNav'
import { VaultStore } from '../../services/VaultStore'

@Component
export struct NoteEditPane {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop itemId: string = ''
  @State note: string = ''
  @State folder: string = '学习知识'
  @State userTag: string = '待了解'
  @State toastText: string = ''
  private folders: string[] = ['生活百科', '科普知识', '历史文化', '学习知识', '健康常识', '趣味知识']
  private tags: string[] = ['已学习', '待了解', '重点收藏']

  aboutToAppear(): void {
    const found: CollectionItem | undefined = VaultStore.find(this.itemId)
    if (found !== undefined) {
      this.note = found.note
      this.folder = found.folder
      this.userTag = found.userTag.length > 0 ? found.userTag : '待了解'
    }
  }

  private async save(): Promise<void> {
    await VaultStore.updateNote(this.itemId, this.note, this.folder, this.userTag)
    AskNav.bumpRefresh()
    AskNav.closeNote()
  }

  build() {
    Column() {
      AppNavBar({ title: '编辑备注', onBack: (): void => { AskNav.closeNote() } })
      Scroll() {
        Column({ space: Theme.space.s4 }) {
          Text('收藏夹')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            ForEach(this.folders, (f: string) => {
              Text(f)
                .fontSize(Theme.type.footnote)
                .fontColor(this.folder === f ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .constraintSize({ minHeight: 40 })
                .backgroundColor(this.folder === f ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.folder = f })
            }, (f: string) => f)
          }
          .width('100%')
          Text('知识标签')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          Row({ space: Theme.space.s2 }) {
            ForEach(this.tags, (f: string) => {
              Text(f)
                .fontSize(Theme.type.footnote)
                .fontColor(this.userTag === f ? Theme.colors().brandOnPrimary : Theme.colors().textPrimary)
                .padding({ left: 14, right: 14, top: 8, bottom: 8 })
                .constraintSize({ minHeight: 40 })
                .backgroundColor(this.userTag === f ?
                  Theme.colors().brandPrimary : Theme.colors().surfaceCard)
                .borderRadius(Theme.radius.pill)
                .onClick(() => { this.userTag = f })
            }, (f: string) => f)
          }
          .width('100%')
          Text('个人备注 / 学习心得')
            .fontSize(Theme.type.subhead)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .width('100%')
          TextArea({ text: this.note, placeholder: '记下你的理解、心得，或想补充的知识' })
            .height(140)
            .fontSize(Theme.type.body)
            .fontColor(this.themeEpoch >= 0 ? Theme.colors().textPrimary : Theme.colors().textPrimary)
            .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
            .onChange((v: string) => { this.note = v })
          AppButton({
            label: '保存',
            onTap: (): void => { void this.save() }
          })
        }
        .padding({
          left: Theme.space.pageX,
          right: Theme.space.pageX,
          bottom: Theme.space.s10
        })
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
