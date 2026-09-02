import { Theme } from '../components/design-system/Theme'
import { AppEmpty } from '../components/design-system/AppEmpty'
import { AppIcon } from '../components/design-system/AppIcon'
import { ZhaNoteCard } from '../components/zha/ZhaNoteCard'
import { ZhaLocalStore } from '../services/ZhaLocalStore'
import { ZhaDetailNav } from '../services/ZhaDetailNav'
import { ZhaNoteItem } from '../models/ZhaModels'

@Component
export struct NotesPage {
  @StorageLink('themeEpoch') themeEpoch: number = 0
  @Prop @Watch('onRefreshChange') refreshToken: number = 0
  @State notes: ZhaNoteItem[] = []
  @State filtered: ZhaNoteItem[] = []
  @State keyword: string = ''

  aboutToAppear(): void {
    void this.loadNotes()
  }

  onRefreshChange(): void {
    if (this.refreshToken > 0) {
      void this.loadNotes()
    }
  }

  private async loadNotes(): Promise<void> {
    this.notes = await ZhaLocalStore.loadNotes()
    this.applyFilter()
  }

  private applyFilter(): void {
    const kw = this.keyword.trim()
    if (kw.length === 0) {
      this.filtered = this.notes
      return
    }
    const out: ZhaNoteItem[] = []
    for (const n of this.notes) {
      if (n.title.indexOf(kw) >= 0 || n.body.indexOf(kw) >= 0) {
        out.push(n)
      }
    }
    this.filtered = out
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Row({ space: Theme.space.s2 }) {
          AppIcon({ name: 'search', iconSize: Theme.icon.md, color: Theme.colors().textSecondary })
          TextInput({ text: this.keyword, placeholder: '搜索笔记标题或正文' })
            .layoutWeight(1)
            .fontSize(Theme.type.body)
            .backgroundColor(Color.Transparent)
            .onChange((v: string) => {
              this.keyword = v
              this.applyFilter()
            })
        }
        .width('100%')
        .padding({ left: Theme.space.s4, right: Theme.space.s4, top: Theme.space.s3, bottom: Theme.space.s3 })
        .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfaceCard : Theme.colors().surfaceCard)
        .borderRadius(Theme.radius.pill)
        .margin({ left: Theme.space.pageX, right: Theme.space.pageX, top: Theme.space.pageY })

        if (this.notes.length === 0) {
          AppEmpty({
            title: '暂无笔记',
            description: '点击右下角按钮，记录第一条灵感',
            actionLabel: '新建笔记',
            onAction: () => ZhaDetailNav.openNoteEditor('')
          }).layoutWeight(1)
        } else if (this.filtered.length === 0) {
          AppEmpty({
            title: '没有匹配的笔记',
            description: '试试其他关键词，或清空搜索',
            actionLabel: '清空搜索',
            onAction: () => {
              this.keyword = ''
              this.applyFilter()
            }
          }).layoutWeight(1)
        } else {
          Scroll() {
            Column({ space: Theme.space.s3 }) {
              ForEach(this.filtered, (n: ZhaNoteItem) => {
                ZhaNoteCard({
                  note: n,
                  onTap: () => ZhaDetailNav.openNote(n.id)
                })
              }, (n: ZhaNoteItem) => n.id)
            }
            .padding({
              left: Theme.space.pageX,
              right: Theme.space.pageX,
              top: Theme.space.s4,
              bottom: Theme.space.s10
            })
            .width('100%')
          }
          .layoutWeight(1)
          .scrollBar(BarState.Off)
          .edgeEffect(EdgeEffect.Spring)
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.themeEpoch >= 0 ? Theme.colors().surfacePage : Theme.colors().surfacePage)

      Column() {
        AppIcon({ name: 'add', iconSize: Theme.icon.lg, color: Theme.colors().brandOnPrimary })
      }
      .width(56)
      .height(56)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Theme.colors().brandPrimary)
      .borderRadius(28)
      .shadow({ radius: 12, color: 'rgba(45,90,74,0.24)', offsetY: 4 })
      .margin({ right: Theme.space.pageX, bottom: Theme.space.s10 })
      .onClick(() => ZhaDetailNav.openNoteEditor(''))
    }
    .width('100%')
    .height('100%')
  }
}
